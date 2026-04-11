const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const crypto = require("crypto");

setGlobalOptions({ region: "europe-west1" });

initializeApp();
const db = getFirestore();

const RMS_BASE_URL = "https://rms.armtech.online";

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
    "content-type, x-rms-session, x-requested-with",
  );
  if (origin) {
    res.set("access-control-allow-credentials", "true");
  }
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

function normalizeRequestBody(req) {
  const raw = req?.body;
  if (!raw) return {};
  if (typeof raw === "object") return raw;
  if (typeof raw !== "string") return {};

  const trimmed = raw.trim();
  if (!trimmed) return {};

  try {
    const json = JSON.parse(trimmed);
    if (json && typeof json === "object") {
      return json;
    }
  } catch (e) {
  }

  try {
    const params = new URLSearchParams(trimmed);
    const obj = {};
    for (const [k, v] of params.entries()) {
      obj[k] = v;
    }
    if (typeof obj.query === "string" && obj.query.trim().startsWith("{")) {
      try {
        obj.query = JSON.parse(obj.query);
      } catch (e) {
      }
    }
    if (typeof obj.body === "string" && obj.body.trim().startsWith("{")) {
      try {
        obj.body = JSON.parse(obj.body);
      } catch (e) {
      }
    }
    return obj;
  } catch (e) {
    return {};
  }
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
    .replaceAll("&nbsp;", " ")
    .replace(/&#(\d+);/g, (_, code) => {
      const n = Number(code);
      if (!Number.isFinite(n)) return _;
      try {
        return String.fromCodePoint(n);
      } catch (e) {
        return _;
      }
    })
    .replace(/&#x([0-9a-fA-F]+);/g, (_, hex) => {
      const n = Number.parseInt(hex, 16);
      if (!Number.isFinite(n)) return _;
      try {
        return String.fromCodePoint(n);
      } catch (e) {
        return _;
      }
    });
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

function splitOptionLabel(label) {
  const normalized = String(label ?? "").replace(/\s+/g, " ").trim();
  if (!normalized) {
    return { code: null, name: "" };
  }
  const match = normalized.match(/^(.+?)\s*-\s*(.+)$/);
  if (!match) {
    return { code: null, name: normalized };
  }
  const code = match[1].trim();
  const name = match[2].trim();
  return { code: code || null, name };
}

function extractSelectOptionsById(html, selectId) {
  const source = String(html ?? "");
  const selectTagRegex = new RegExp(
    `<select\\b[^>]*\\bid=(?:\"${String(selectId)}\"|'${String(selectId)}')[^>]*>`,
    "i",
  );
  const startMatch = source.match(selectTagRegex);
  if (!startMatch) {
    return [];
  }

  const startIndex = source.indexOf(startMatch[0]);
  if (startIndex < 0) {
    return [];
  }
  const afterStart = startIndex + startMatch[0].length;
  const endIndex = source.indexOf("</select>", afterStart);
  if (endIndex < 0) {
    return [];
  }

  const chunk = source.slice(afterStart, endIndex);
  const optionRegex = /<option\b[^>]*>[\s\S]*?<\/option>/gi;

  const items = [];
  let match;
  while ((match = optionRegex.exec(chunk)) !== null) {
    const tag = match[0];
    const openTagMatch = tag.match(/<option\b[^>]*>/i);
    const openTag = openTagMatch ? openTagMatch[0] : "<option>";
    const attrs = parseTagAttributes(openTag);
    const value = String(attrs.value ?? "").trim();
    if (!value) continue;

    const labelHtml = tag
      .replace(/<option\b[^>]*>/i, "")
      .replace(/<\/option>/i, "");
    const labelText = decodeHtmlEntities(stripHtmlTags(labelHtml));
    const normalizedLabel = String(labelText).replace(/\s+/g, " ").trim();
    if (!normalizedLabel) continue;

    const id = Number.parseInt(value, 10);
    if (!Number.isFinite(id)) continue;

    const { code, name } = splitOptionLabel(normalizedLabel);
    items.push({
      id,
      code,
      name,
      label: normalizedLabel,
    });
  }

  return items;
}

function extractJsVarJsonArray(html, varName) {
  const source = String(html ?? "");
  const varIndex = source.indexOf(`var ${String(varName)} =`);
  if (varIndex < 0) {
    return null;
  }

  const arrayStart = source.indexOf("[", varIndex);
  if (arrayStart < 0) {
    return null;
  }

  let depth = 0;
  let inString = false;
  let stringQuote = null;
  let isEscaped = false;
  let arrayEnd = -1;

  for (let i = arrayStart; i < source.length; i++) {
    const ch = source[i];

    if (inString) {
      if (isEscaped) {
        isEscaped = false;
        continue;
      }
      if (ch === "\\") {
        isEscaped = true;
        continue;
      }
      if (ch === stringQuote) {
        inString = false;
        stringQuote = null;
      }
      continue;
    }

    if (ch === '"' || ch === "'") {
      inString = true;
      stringQuote = ch;
      continue;
    }

    if (ch === "[") {
      depth += 1;
      continue;
    }
    if (ch === "]") {
      depth -= 1;
      if (depth === 0) {
        arrayEnd = i;
        break;
      }
    }
  }

  if (arrayEnd < 0) {
    return null;
  }

  const jsonText = source.slice(arrayStart, arrayEnd + 1);
  try {
    const parsed = JSON.parse(jsonText);
    return Array.isArray(parsed) ? parsed : null;
  } catch (e) {
    try {
      const fn = new Function(`"use strict"; return (${jsonText});`);
      const parsed = fn();
      return Array.isArray(parsed) ? parsed : null;
    } catch (_) {
      return null;
    }
  }
}

function buildLookupItemsFromReservationList(list) {
  if (!Array.isArray(list)) return [];
  const items = [];
  for (const raw of list) {
    if (!raw || typeof raw !== "object") continue;
    const idValue = raw.id;
    const id =
      typeof idValue === "number"
        ? idValue
        : typeof idValue === "string"
          ? Number.parseInt(idValue.trim(), 10)
          : null;
    if (!Number.isFinite(id)) continue;

    const displayName = String(raw.displayName ?? "").trim();
    if (!displayName) continue;

    const displayNumberRaw =
      raw.displayNumber === null || raw.displayNumber === undefined
        ? null
        : String(raw.displayNumber).trim();
    const { code: labelCode, name } = splitOptionLabel(displayName);
    const code = displayNumberRaw && displayNumberRaw.length > 0
      ? displayNumberRaw
      : labelCode;

    const nationalityRaw = raw.nationalityId;
    const nationalityId =
      typeof nationalityRaw === "number"
        ? nationalityRaw
        : typeof nationalityRaw === "string"
          ? Number.parseInt(nationalityRaw.trim(), 10)
          : null;

    items.push({
      id,
      code: code || null,
      name,
      label: displayName,
      nationalityId: Number.isFinite(nationalityId) ? nationalityId : null,
    });
  }
  return items;
}

function extractSelectOptionsByIdWithKey(html, selectId) {
  const source = String(html ?? "");
  const selectTagRegex = new RegExp(
    `<select\\b[^>]*\\bid=(?:\"${String(selectId)}\"|'${String(selectId)}')[^>]*>`,
    "i",
  );
  const startMatch = source.match(selectTagRegex);
  if (!startMatch) {
    return [];
  }

  const startIndex = source.indexOf(startMatch[0]);
  if (startIndex < 0) {
    return [];
  }
  const afterStart = startIndex + startMatch[0].length;
  const endIndex = source.indexOf("</select>", afterStart);
  if (endIndex < 0) {
    return [];
  }

  const chunk = source.slice(afterStart, endIndex);
  const optionRegex = /<option\b[^>]*>[\s\S]*?<\/option>/gi;

  const items = [];
  let match;
  while ((match = optionRegex.exec(chunk)) !== null) {
    const tag = match[0];
    const openTagMatch = tag.match(/<option\b[^>]*>/i);
    const openTag = openTagMatch ? openTagMatch[0] : "<option>";
    const attrs = parseTagAttributes(openTag);
    const value = String(attrs.value ?? "").trim();
    if (!value) continue;

    const labelHtml = tag
      .replace(/<option\b[^>]*>/i, "")
      .replace(/<\/option>/i, "");
    const labelText = decodeHtmlEntities(stripHtmlTags(labelHtml));
    const normalizedLabel = String(labelText).replace(/\s+/g, " ").trim();
    if (!normalizedLabel) continue;

    const { code, name } = splitOptionLabel(normalizedLabel);
    const id = Number.parseInt(value, 10);
    items.push({
      key: value,
      id: Number.isFinite(id) ? id : null,
      code,
      name,
      label: normalizedLabel,
    });
  }

  return items;
}

function buildLookupItemsFromGenericList(list, mapping) {
  if (!Array.isArray(list)) return [];
  const items = [];
  for (const raw of list) {
    if (!raw || typeof raw !== "object") continue;

    const rawObj = raw;
    const idValue = rawObj[mapping.idKey ?? "id"];
    const id =
      typeof idValue === "number"
        ? idValue
        : typeof idValue === "string"
          ? Number.parseInt(idValue.trim(), 10)
          : null;

    const keyValue =
      mapping.keyKey && rawObj[mapping.keyKey] !== undefined
        ? rawObj[mapping.keyKey]
        : id;
    const key =
      typeof keyValue === "string"
        ? keyValue.trim()
        : typeof keyValue === "number"
          ? String(keyValue)
          : null;
    if (!key || key.trim().length === 0) continue;

    const labelValue = mapping.labelKeys
      .map((k) => rawObj[k])
      .find((v) => typeof v === "string" && v.trim().length > 0);
    const label = String(labelValue ?? "").trim();
    if (!label) continue;

    const codeValue = mapping.codeKeys
      .map((k) => rawObj[k])
      .find((v) => v !== undefined && v !== null);
    const code = codeValue === undefined || codeValue === null
      ? null
      : String(codeValue).trim() || null;

    const nameValue = mapping.nameKeys
      .map((k) => rawObj[k])
      .find((v) => typeof v === "string" && v.trim().length > 0);
    const name = String(nameValue ?? "").trim() || label;

    items.push({
      key,
      id: Number.isFinite(id) ? id : null,
      code,
      name,
      label,
    });
  }
  return items;
}

exports.rmsLogin = onRequest(async (req, res) => {
  try {
    applyCors(req, res);
    if (req.method === "OPTIONS") {
      res.status(204).send("");
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

exports.rmsLogout = onRequest(async (req, res) => {
  try {
    applyCors(req, res);
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      sendJson(res, 405, { error: "Method not allowed" });
      return;
    }

    const bodyObj = normalizeRequestBody(req);
    const sessionId = req.get("x-rms-session") || bodyObj.sessionId;
    if (!sessionId) {
      sendJson(res, 401, { error: "Missing sessionId" });
      return;
    }

    const sessionRef = db.collection("rms_sessions").doc(String(sessionId));
    const sessionSnap = await sessionRef.get();
    if (sessionSnap.exists) {
      const session = sessionSnap.data();
      const cookieHeader = session?.cookieHeader;
      const xsrfToken = session?.xsrfToken;
      if (cookieHeader && xsrfToken) {
        try {
          await fetch(buildRmsUrl("/Account/Logout"), {
            method: "GET",
            redirect: "manual",
            headers: {
              accept: "application/json, text/javascript, */*; q=0.01",
              "x-requested-with": "XMLHttpRequest",
              "x-xsrf-token": xsrfToken,
              cookie: cookieHeader,
            },
          });
        } catch (e) { }
      }
    }

    await sessionRef.delete();
    sendJson(res, 200, { ok: true });
  } catch (e) {
    console.error("rmsLogout failed", e);
    sendJson(res, 500, { error: "Internal Server Error" });
  }
});

exports.rmsProxy = onRequest(async (req, res) => {
  try {
    applyCors(req, res);
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    const bodyObj = normalizeRequestBody(req);
    const sessionId = req.get("x-rms-session") || bodyObj.sessionId;
    const action = String(bodyObj.action ?? "").trim();
    const path = bodyObj.path || req.query?.path;
    const method = (bodyObj.method || req.method || "GET").toUpperCase();
    const query = bodyObj.query;
    const body = bodyObj.body;

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

    if (action === "extractCreateOrEditLookups") {
      const rms = bodyObj.rms ? String(bodyObj.rms).trim() : "";
      const createUrl = buildRmsUrl(
        "/App/Reservations/CreateOrEdit",
        rms ? { rms } : null,
      );
      const createResp = await fetch(createUrl, {
        method: "GET",
        redirect: "manual",
        headers: {
          accept:
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "x-xsrf-token": xsrfToken,
          cookie: cookieHeader,
        },
      });
      const html = await createResp.text();
      await updateSessionCookieHeader(sessionId, cookieHeader, createResp.headers);

      if (!createResp.ok) {
        sendJson(res, createResp.status, {
          error: "Failed to fetch CreateOrEdit HTML",
          status: createResp.status,
        });
        return;
      }

      const agentList = extractJsVarJsonArray(html, "ReservationAgentList");
      let clients = buildLookupItemsFromReservationList(agentList);
      if (clients.length === 0) {
        clients = extractSelectOptionsById(html, "clientId");
      }
      const hotels = extractSelectOptionsById(html, "myHotelId");

      const supplierList = extractJsVarJsonArray(html, "ReservationSupplierList");
      let suppliers = buildLookupItemsFromReservationList(supplierList);
      if (suppliers.length === 0) {
        const supplierSelectIds = [
          "Reservation_SupplierId",
          "ChangeTypeSupplierId",
          "newSupplierId",
        ];
        for (const id of supplierSelectIds) {
          suppliers = extractSelectOptionsById(html, id);
          if (suppliers.length > 0) break;
        }
      }

      sendJson(res, 200, {
        result: {
          source: {
            url: createUrl,
            title: extractTitle(html),
          },
          clients,
          hotels,
          suppliers,
        },
      });
      return;
    }

    if (action === "extractAdditionalLookups") {
      const extraServiceUrl = buildRmsUrl(
        "/App/Reservations/CreateOrEditExtraService",
      );
      const transportServiceUrl = buildRmsUrl(
        "/App/Reservations/CreateOrEditTransportationService",
      );

      const [extraResp, transportResp] = await Promise.all([
        fetch(extraServiceUrl, {
          method: "GET",
          redirect: "manual",
          headers: {
            accept:
              "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "x-xsrf-token": xsrfToken,
            cookie: cookieHeader,
          },
        }),
        fetch(transportServiceUrl, {
          method: "GET",
          redirect: "manual",
          headers: {
            accept:
              "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "x-xsrf-token": xsrfToken,
            cookie: cookieHeader,
          },
        }),
      ]);

      const extraHtml = await extraResp.text();
      const transportHtml = await transportResp.text();

      await updateSessionCookieHeader(
        sessionId,
        cookieHeader,
        extraResp.headers,
      );
      await updateSessionCookieHeader(
        sessionId,
        cookieHeader,
        transportResp.headers,
      );

      if (!extraResp.ok) {
        sendJson(res, extraResp.status, {
          error: "Failed to fetch CreateOrEditExtraService HTML",
          status: extraResp.status,
        });
        return;
      }
      if (!transportResp.ok) {
        sendJson(res, transportResp.status, {
          error: "Failed to fetch CreateOrEditTransportationService HTML",
          status: transportResp.status,
        });
        return;
      }

      const nationalityList = extractJsVarJsonArray(
        extraHtml,
        "ReservationNationalityList",
      );
      let nationalities = buildLookupItemsFromGenericList(nationalityList, {
        labelKeys: ["name", "displayName", "label", "text"],
        nameKeys: ["name", "displayName", "label", "text"],
        codeKeys: ["code", "displayNumber", "number"],
        idKey: "id",
      });
      if (nationalities.length === 0) {
        const createUrl = buildRmsUrl("/App/Reservations/CreateOrEdit");
        const createResp = await fetch(createUrl, {
          method: "GET",
          redirect: "manual",
          headers: {
            accept:
              "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "x-xsrf-token": xsrfToken,
            cookie: cookieHeader,
          },
        });
        const createHtml = await createResp.text();
        await updateSessionCookieHeader(
          sessionId,
          cookieHeader,
          createResp.headers,
        );
        if (createResp.ok) {
          nationalities = extractSelectOptionsByIdWithKey(
            createHtml,
            "guestNationalityId",
          );
        }
      }

      const extraServiceTypes = extractSelectOptionsByIdWithKey(
        extraHtml,
        "ExtraServiceTypeId",
      );
      const termsAndConditions = extractSelectOptionsByIdWithKey(
        extraHtml,
        "termsAndCondionId",
      );

      const routeList = extractJsVarJsonArray(transportHtml, "RouteList");
      let routes = buildLookupItemsFromGenericList(routeList, {
        labelKeys: ["displayName", "name", "label", "text"],
        nameKeys: ["name", "displayName", "label", "text"],
        codeKeys: ["displayNumber", "code", "number"],
        idKey: "id",
      });
      if (routes.length === 0) {
        routes = extractSelectOptionsByIdWithKey(transportHtml, "RouteId");
      }

      const vehicleTypeList = extractJsVarJsonArray(
        transportHtml,
        "VehicleTypeList",
      );
      let vehicleTypes = buildLookupItemsFromGenericList(vehicleTypeList, {
        labelKeys: ["displayName", "name", "label", "text"],
        nameKeys: ["name", "displayName", "label", "text"],
        codeKeys: ["displayNumber", "code", "number"],
        idKey: "id",
      });
      if (vehicleTypes.length === 0) {
        vehicleTypes = extractSelectOptionsByIdWithKey(transportHtml, "VehicleId");
      }

      const tripTypes = extractSelectOptionsByIdWithKey(transportHtml, "TripType");

      sendJson(res, 200, {
        result: {
          source: {
            extraServiceUrl,
            extraServiceTitle: extractTitle(extraHtml),
            transportServiceUrl,
            transportServiceTitle: extractTitle(transportHtml),
          },
          nationalities,
          extraServiceTypes,
          termsAndConditions,
          routes,
          vehicleTypes,
          tripTypes,
        },
      });
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
