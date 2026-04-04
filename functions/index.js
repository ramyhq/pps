const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const crypto = require("crypto");

setGlobalOptions({ region: "europe-west1" });

initializeApp();
const db = getFirestore();

const RMS_BASE_URL = "https://rms.armtech.online";
const RMS_PROXY_KEY = defineSecret("RMS_PROXY_KEY");

function sendJson(res, status, data) {
  res.status(status);
  res.set("content-type", "application/json; charset=utf-8");
  res.send(JSON.stringify(data));
}

function applyCors(req, res) {
  const origin = req.get("origin");
  res.set("access-control-allow-origin", origin || "*");
  res.set("vary", "origin");
  res.set("access-control-allow-methods", "GET,POST,OPTIONS");
  res.set(
    "access-control-allow-headers",
    "content-type, x-rms-proxy-key, x-rms-session",
  );
  res.set("access-control-max-age", "3600");
}

function parseRequestVerificationToken(html) {
  const match = html.match(
    /name="__RequestVerificationToken"[^>]*value="([^"]+)"/,
  );
  return match ? match[1] : null;
}

function parseSetCookieToPair(setCookie) {
  const firstPart = String(setCookie).split(";")[0].trim();
  const eqIndex = firstPart.indexOf("=");
  if (eqIndex <= 0) {
    return null;
  }
  const name = firstPart.substring(0, eqIndex).trim();
  const value = firstPart.substring(eqIndex + 1).trim();
  if (!name) {
    return null;
  }
  return { name, value };
}

function parseCookieHeaderToPairs(cookieHeader) {
  const parts = String(cookieHeader).split(";");
  const map = new Map();
  for (const part of parts) {
    const trimmed = part.trim();
    if (!trimmed) continue;
    const eqIndex = trimmed.indexOf("=");
    if (eqIndex <= 0) continue;
    const name = trimmed.substring(0, eqIndex).trim();
    const value = trimmed.substring(eqIndex + 1).trim();
    if (!name) continue;
    map.set(name, value);
  }
  return map;
}

function cookiePairsToHeader(pairsMap) {
  return Array.from(pairsMap.entries())
    .map(([k, v]) => `${k}=${v}`)
    .join("; ");
}

function mergeSetCookieIntoCookieHeader(currentCookieHeader, setCookieList) {
  const pairs = currentCookieHeader
    ? parseCookieHeaderToPairs(currentCookieHeader)
    : new Map();
  for (const setCookie of setCookieList || []) {
    const pair = parseSetCookieToPair(setCookie);
    if (pair) {
      pairs.set(pair.name, pair.value);
    }
  }
  return cookiePairsToHeader(pairs);
}

function upsertCookiePair(cookieHeader, name, value) {
  const pairs = cookieHeader
    ? parseCookieHeaderToPairs(cookieHeader)
    : new Map();
  pairs.set(String(name), String(value));
  return cookiePairsToHeader(pairs);
}

function getSetCookieList(headers) {
  if (headers && typeof headers.getSetCookie === "function") {
    return headers.getSetCookie();
  }
  const raw = headers && headers.get ? headers.get("set-cookie") : null;
  if (!raw) {
    return [];
  }
  return [raw];
}

function decodeHtmlEntities(input) {
  if (!input) return "";
  return String(input)
    .replaceAll("&amp;", "&")
    .replaceAll("&quot;", '"')
    .replaceAll("&#34;", '"')
    .replaceAll("&#39;", "'")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replaceAll("&nbsp;", " ");
}

function parseTagAttributes(tag) {
  const attrs = {};
  const attrRegex =
    /([A-Za-z_:][A-Za-z0-9_:.:-]*)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+))/g;
  let match;
  while ((match = attrRegex.exec(tag)) !== null) {
    const key = match[1];
    const rawVal = match[2] ?? match[3] ?? match[4] ?? "";
    attrs[key] = decodeHtmlEntities(rawVal);
  }
  return attrs;
}

function extractTitle(html) {
  const match = String(html).match(/<title[^>]*>([\s\S]*?)<\/title>/i);
  return match ? decodeHtmlEntities(match[1].trim()) : null;
}

function extractInputs(html) {
  const byId = {};
  const byName = {};
  const inputRegex = /<input\b[^>]*>/gi;
  let match;
  while ((match = inputRegex.exec(String(html))) !== null) {
    const tag = match[0];
    const attrs = parseTagAttributes(tag);
    const value = attrs.value ?? "";
    if (attrs.id) {
      byId[attrs.id] = value;
    }
    if (attrs.name) {
      byName[attrs.name] = value;
    }
  }
  return { byId, byName };
}

function parseBool(input) {
  const v = String(input ?? "").trim().toLowerCase();
  if (v === "true" || v === "1" || v === "yes") return true;
  if (v === "false" || v === "0" || v === "no") return false;
  return null;
}

function extractReservationNoFromTitle(title) {
  const match = String(title ?? "").match(/view\s*res\.\s*(\d+)/i);
  return match ? match[1] : null;
}

function buildReservationDetailsFromInputs(inputs, title) {
  const byId = inputs?.byId ?? {};

  const reservationId = byId.ReservationId ? String(byId.ReservationId) : null;
  const clientId = byId.clientId ? String(byId.clientId) : null;
  const reservationNo = extractReservationNoFromTitle(title);

  const flags = {
    isManager: parseBool(byId.IsManager),
    isOfficer: parseBool(byId.IsOfficer),
    isClient: parseBool(byId.IsClient),
    exceedCheckCreditLimit: parseBool(byId.ExceedCheckCreditLimit),
    officerSaveAvailability: parseBool(byId.OfficerSaveAvailability),
  };

  const segments = new Map();
  for (const [key, value] of Object.entries(byId)) {
    const match = String(key).match(
      /^(AttachmentId|ArrivalDate|DepartureDate|myHotelId|AvailabilityType)_(\d+)$/,
    );
    if (!match) continue;
    const field = match[1];
    const id = match[2];
    if (!segments.has(id)) {
      segments.set(id, { referenceId: id });
    }
    const segment = segments.get(id);
    if (field === "AttachmentId") {
      segment.attachmentId = String(value);
    } else if (field === "ArrivalDate") {
      segment.arrivalDate = String(value);
    } else if (field === "DepartureDate") {
      segment.departureDate = String(value);
    } else if (field === "myHotelId") {
      segment.hotelId = String(value);
    } else if (field === "AvailabilityType") {
      segment.availabilityType = String(value);
    }
  }

  const hotelSegments = Array.from(segments.values()).sort((a, b) => {
    const an = Number(a.referenceId);
    const bn = Number(b.referenceId);
    if (Number.isFinite(an) && Number.isFinite(bn)) return an - bn;
    return String(a.referenceId).localeCompare(String(b.referenceId));
  });

  return {
    reservation: {
      reservationId,
      reservationNo,
      clientId,
      flags,
    },
    hotelSegments,
  };
}

function stripHtmlTags(input) {
  return String(input ?? "")
    .replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, " ")
    .replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function extractHotelReservationCards(html) {
  const source = String(html ?? "");
  const startRegex =
    /<div class="row reservation-details-card Hotel-Reservation-Detail[^"]*" id="(\d+)">/gi;

  const starts = [];
  let match;
  while ((match = startRegex.exec(source)) !== null) {
    starts.push({ index: match.index, id: match[1] });
  }

  const cards = [];
  for (let i = 0; i < starts.length; i++) {
    const start = starts[i];
    const end = i + 1 < starts.length ? starts[i + 1].index : source.length;
    const chunk = source.slice(start.index, end);

    const headerSpan = chunk.match(
      /<span class="span-resInfo">([\s\S]*?)<\/span>/i,
    );
    const label = headerSpan ? stripHtmlTags(headerSpan[1]) : null;

    const badgeSpan = chunk.match(
      /<span class="badge[^"]*">([\s\S]*?)<\/span>/i,
    );
    const type = badgeSpan ? stripHtmlTags(badgeSpan[1]) : null;

    const sellMatch = chunk.match(
      /<span class="ReservationItemSellPrice">\s*([^<]+)\s*<\/span>/i,
    );
    const buyMatch = chunk.match(
      /<span class="ReservationItemBuyPrice">\s*([^<]+)\s*<\/span>/i,
    );

    cards.push({
      referenceId: String(start.id),
      label,
      type,
      totals: {
        totalSale: sellMatch ? String(sellMatch[1]).trim() : null,
        totalCost: buyMatch ? String(buyMatch[1]).trim() : null,
      },
    });
  }

  return cards;
}

function extractJsonParsePayloads(html) {
  const results = [];
  const source = String(html);
  const patterns = [
    /JSON\.parse\(\s*'((?:\\'|[^'])*)'\s*\)/g,
    /JSON\.parse\(\s*"((?:\\"|[^"])*)"\s*\)/g,
  ];

  for (const pattern of patterns) {
    let match;
    while ((match = pattern.exec(source)) !== null) {
      const raw = match[1] ?? "";
      const unescaped = raw
        .replaceAll("\\\\", "\\")
        .replaceAll('\\"', '"')
        .replaceAll("\\'", "'");
      try {
        const parsed = JSON.parse(unescaped);
        results.push(parsed);
      } catch (e) {
        continue;
      }
    }
  }

  return results;
}

async function updateSessionCookieHeader(sessionId, cookieHeader, respHeaders) {
  const respSetCookies = getSetCookieList(respHeaders);
  if (respSetCookies.length === 0) {
    return cookieHeader;
  }
  const merged = mergeSetCookieIntoCookieHeader(cookieHeader, respSetCookies);
  try {
    await db.collection("rms_sessions").doc(sessionId).set(
      {
        cookieHeader: merged,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  } catch (e) {
    console.error("Failed to update rms_sessions cookieHeader", e);
  }
  return merged;
}

function ensureProxyKey(req) {
  const expected = RMS_PROXY_KEY.value();
  if (!expected) {
    return { ok: true };
  }
  const received = req.get("x-rms-proxy-key");
  if (!received || received !== expected) {
    return { ok: false };
  }
  return { ok: true };
}

function buildRmsUrl(path, query) {
  const url = new URL(RMS_BASE_URL);
  url.pathname = path;
  if (query && typeof query === "object") {
    for (const [k, v] of Object.entries(query)) {
      if (v === undefined || v === null) continue;
      url.searchParams.set(k, String(v));
    }
  }
  return url.toString();
}

function isAllowedPath(path) {
  if (typeof path !== "string") return false;
  if (!path.startsWith("/")) return false;
  if (path.startsWith("/api/")) return true;
  if (path.startsWith("/Account/")) return true;
  if (path.startsWith("/App/Reservations/")) return true;
  return false;
}

exports.rmsLogin = onRequest({ secrets: [RMS_PROXY_KEY] }, async (req, res) => {
  try {
    applyCors(req, res);
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    const keyCheck = ensureProxyKey(req);
    if (!keyCheck.ok) {
      sendJson(res, 401, { error: "Unauthorized" });
      return;
    }

    if (req.method !== "POST") {
      sendJson(res, 405, { error: "Method not allowed" });
      return;
    }

    const username = String(req.body?.username ?? "").trim();
    const password = String(req.body?.password ?? "");
    const rememberMe = Boolean(req.body?.rememberMe ?? true);
    const tenantId = String(req.body?.tenantId ?? "87").trim();
    if (!username || !password) {
      sendJson(res, 400, { error: "Missing username/password" });
      return;
    }

    const loginPageResp = await fetch(buildRmsUrl("/Account/Login"), {
      method: "GET",
      redirect: "manual",
    });
    const loginPageHtml = await loginPageResp.text();
    const token = parseRequestVerificationToken(loginPageHtml);
    if (!token) {
      sendJson(res, 502, { error: "Failed to fetch verification token" });
      return;
    }

    const loginPageSetCookies = getSetCookieList(loginPageResp.headers);
    const loginPageCookieHeader = mergeSetCookieIntoCookieHeader(
      null,
      loginPageSetCookies,
    );
    const tenantCookieHeader =
      tenantId && tenantId !== "null" && tenantId !== "undefined"
        ? upsertCookiePair(loginPageCookieHeader, "Abp.TenantId", tenantId)
        : loginPageCookieHeader;

    const params = new URLSearchParams();
    params.set("returnUrl", "/App");
    params.set("returnUrlHash", "");
    params.set("ss", "");
    params.set("usernameOrEmailAddress", username);
    params.set("password", password);
    if (rememberMe) {
      params.set("rememberMe", "true");
    }
    params.set("__RequestVerificationToken", token);

    const loginResp = await fetch(buildRmsUrl("/Account/Login"), {
      method: "POST",
      redirect: "manual",
      headers: {
        accept: "application/json, text/javascript, */*; q=0.01",
        "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "x-requested-with": "XMLHttpRequest",
        "x-xsrf-token": token,
        ...(tenantCookieHeader ? { cookie: tenantCookieHeader } : {}),
      },
      body: params.toString(),
    });

    const setCookieList = getSetCookieList(loginResp.headers);
    const cookieHeader = mergeSetCookieIntoCookieHeader(
      tenantCookieHeader,
      setCookieList,
    );
    const verifyResp = await fetch(
      buildRmsUrl("/api/services/app/Session/GetCurrentLoginInformations"),
      {
        method: "GET",
        redirect: "manual",
        headers: {
          accept: "application/json, text/javascript, */*; q=0.01",
          "x-requested-with": "XMLHttpRequest",
          "x-xsrf-token": token,
          ...(cookieHeader ? { cookie: cookieHeader } : {}),
        },
      },
    );
    const verifyText = await verifyResp.text();
    let verifyJson = null;
    try {
      verifyJson = JSON.parse(verifyText);
    } catch (e) {
      verifyJson = null;
    }
    const verifyUser = verifyJson?.result?.user;
    if (!verifyUser) {
      sendJson(res, 401, {
        error: "Login failed",
        status: loginResp.status,
      });
      return;
    }

    const sessionId = crypto.randomUUID();
    try {
      await db.collection("rms_sessions").doc(sessionId).set({
        cookieHeader,
        xsrfToken: token,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      console.error("Failed to write rms_sessions to Firestore", e);
      sendJson(res, 503, {
        error: "Firestore is not ready",
        hint: "Enable Cloud Firestore API and create Firestore database in Firebase Console.",
      });
      return;
    }

    sendJson(res, 200, { sessionId });
  } catch (e) {
    console.error("rmsLogin failed", e);
    sendJson(res, 500, { error: "Internal Server Error" });
  }
});

exports.rmsProxy = onRequest({ secrets: [RMS_PROXY_KEY] }, async (req, res) => {
  try {
    applyCors(req, res);
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    const keyCheck = ensureProxyKey(req);
    if (!keyCheck.ok) {
      sendJson(res, 401, { error: "Unauthorized" });
      return;
    }

    const sessionId = req.get("x-rms-session") || req.body?.sessionId;
    const action = String(req.body?.action ?? "").trim();
    const path = req.body?.path || req.query?.path;
    const method = (req.body?.method || req.method || "GET").toUpperCase();
    const query = req.body?.query;
    const body = req.body?.body;

    if (!sessionId) {
      sendJson(res, 401, { error: "Missing sessionId" });
      return;
    }

    const sessionSnap = await db.collection("rms_sessions").doc(sessionId).get();
    if (!sessionSnap.exists) {
      sendJson(res, 401, { error: "Invalid sessionId" });
      return;
    }
    const session = sessionSnap.data();
    const cookieHeader = session?.cookieHeader;
    const xsrfToken = session?.xsrfToken;
    if (!cookieHeader || !xsrfToken) {
      sendJson(res, 401, { error: "Session is incomplete" });
      return;
    }

    if (action === "extractReservationView") {
      const reservationIdRaw = req.body?.reservationId ?? req.body?.id;
      const reservationId = reservationIdRaw
        ? String(reservationIdRaw).trim()
        : "";
      const rms = req.body?.rms ? String(req.body.rms).trim() : "";
      if (!reservationId && !rms) {
        sendJson(res, 400, { error: "Missing reservationId or rms" });
        return;
      }

      const viewQuery = reservationId ? { id: reservationId } : { rms };
      const viewUrl = buildRmsUrl("/App/Reservations/ViewReservation", viewQuery);
      const viewResp = await fetch(viewUrl, {
        method: "GET",
        redirect: "manual",
        headers: {
          accept:
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "x-xsrf-token": xsrfToken,
          cookie: cookieHeader,
        },
      });
      const html = await viewResp.text();
      await updateSessionCookieHeader(sessionId, cookieHeader, viewResp.headers);

      if (!viewResp.ok) {
        sendJson(res, viewResp.status, {
          error: "Failed to fetch ViewReservation HTML",
          status: viewResp.status,
        });
        return;
      }

      const title = extractTitle(html);
      const inputs = extractInputs(html);
      const cards = extractHotelReservationCards(html);
      const details = buildReservationDetailsFromInputs(inputs, title);
      const cardsById = new Map(cards.map((c) => [c.referenceId, c]));
      const mergedSegments = details.hotelSegments.map((seg) => {
        const card = cardsById.get(seg.referenceId);
        if (!card) return seg;
        return {
          ...seg,
          label: card.label,
          type: card.type,
          totals: card.totals,
        };
      });

      const extracted = {
        reservation: {
          reservationId: reservationId || null,
          rms: rms || null,
        },
        page: {
          title,
        },
        inputs,
        json: {
          parsed: extractJsonParsePayloads(html),
        },
        details: {
          ...details,
          hotelSegments: mergedSegments,
          hotelCards: cards,
        },
      };

      sendJson(res, 200, { result: extracted });
      return;
    }

    if (!isAllowedPath(path)) {
      sendJson(res, 400, { error: "Invalid path" });
      return;
    }

    const targetUrl = buildRmsUrl(path, query);
    const forwardHeaders = {
      accept: "application/json, text/javascript, */*; q=0.01",
      "x-requested-with": "XMLHttpRequest",
      "x-xsrf-token": xsrfToken,
      cookie: cookieHeader,
    };

    let forwardBody;
    if (method !== "GET" && method !== "HEAD") {
      if (typeof body === "string") {
        forwardBody = body;
        forwardHeaders["content-type"] =
          req.get("content-type") || "application/json; charset=utf-8";
      } else if (body && typeof body === "object") {
        forwardBody = JSON.stringify(body);
        forwardHeaders["content-type"] = "application/json; charset=utf-8";
      }
    }

    const forwardResp = await fetch(targetUrl, {
      method,
      redirect: "manual",
      headers: forwardHeaders,
      body: forwardBody,
    });

    const respText = await forwardResp.text();
    await updateSessionCookieHeader(sessionId, cookieHeader, forwardResp.headers);

    res.status(forwardResp.status);
    const contentType = forwardResp.headers.get("content-type");
    if (contentType) {
      res.set("content-type", contentType);
    }
    res.send(respText);
  } catch (e) {
    console.error("rmsProxy failed", e);
    sendJson(res, 500, { error: "Internal Server Error" });
  }
});
