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
    const path = req.body?.path || req.query?.path;
    const method = (req.body?.method || req.method || "GET").toUpperCase();
    const query = req.body?.query;
    const body = req.body?.body;

    if (!sessionId) {
      sendJson(res, 401, { error: "Missing sessionId" });
      return;
    }
    if (!isAllowedPath(path)) {
      sendJson(res, 400, { error: "Invalid path" });
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
    const respSetCookies = getSetCookieList(forwardResp.headers);
    if (respSetCookies.length > 0) {
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
    }

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
