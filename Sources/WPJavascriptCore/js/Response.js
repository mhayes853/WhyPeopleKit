function Response(responseBody, options) {
  if (options !== undefined && typeof options !== "object") {
    throw _wpJSCoreFailedToConstruct(
      "Response",
      "The provided value is not of type 'ResponseInit'.",
    );
  }
  const body = _wpJSCoreHTTPBody(responseBody, _WPJSCoreBodyKind.Response);
  this[Symbol._wpJSCorePrivate] = {
    body,
    rawBody: responseBody,
    bodyUsed: false,
    options: {
      ...options,
      headers: _wpJSCoreHTTPHeaders(options?.headers, body),
    },
  };
}

Response.error = function () {
  const resp = new Response();
  const state = resp[Symbol._wpJSCorePrivate];
  resp[Symbol._wpJSCorePrivate] = {
    ...state,
    options: { ...state.options, status: 0, type: "error" },
  };
  return resp;
};

const _WPJSCORE_REDIRECT_STATUS_CODES = new Set([301, 302, 303, 307, 308]);

Response.redirect = function (url, status) {
  _wpJSCoreEnsureMinArgCount("redirect", "Response", [url, status], 1);
  const statusCode = status ?? 302;
  if (!_WPJSCORE_REDIRECT_STATUS_CODES.has(statusCode)) {
    throw _wpJSCoreFailedToExecute(
      "Response",
      "redirect",
      "Invalid status code",
    );
  }
  const resp = new Response();
  const state = resp[Symbol._wpJSCorePrivate];
  resp[Symbol._wpJSCorePrivate] = {
    ...state,
    options: { ...state.options, url, status: statusCode, redirected: true },
  };
  return resp;
};

Response.json = function (jsonSerializeable, options) {
  _wpJSCoreEnsureMinArgCount(
    "json",
    "Response",
    [jsonSerializeable, options],
    1,
  );
  const rawBody = JSON.stringify(jsonSerializeable);
  const headers = _wpJSCoreHTTPHeaders(
    options?.headers,
    _WPJSCoreNullishBody.Response,
  );
  if (!headers.has("content-type")) {
    headers.set("content-type", "application/json");
  }
  return new Response(rawBody, { ...options, headers });
};

Object.defineProperties(Response.prototype, {
  bodyUsed: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].bodyUsed;
    },
    enumerable: true,
    configurable: false,
  },
  clone: {
    value: function () {
      const response = new Response();
      const state = this[Symbol._wpJSCorePrivate];
      response[Symbol._wpJSCorePrivate] = {
        ...state,
        body: _wpJSCoreHTTPBody(state.rawBody, _WPJSCoreBodyKind.Response),
      };
      return response;
    },
    enumerable: false,
    configurable: false,
  },
  ok: {
    get: function () {
      return this.status >= 200 && this.status < 300;
    },
    enumerable: false,
    configurable: false,
  },
  status: _wpJSCoreHTTPOptionsProperty("status", 200),
  headers: _wpJSCoreHTTPOptionsProperty("headers", new Headers()),
  statusText: _wpJSCoreHTTPOptionsProperty("statusText", ""),
  type: _wpJSCoreHTTPOptionsProperty("type", "defaut"),
  redirected: _wpJSCoreHTTPOptionsProperty("redirected", false),
  url: _wpJSCoreHTTPOptionsProperty("url", ""),
  blob: _wpJSCoreHTTPBodyConsumerProperty("blob", _WPJSCoreBodyKind.Response),
  arrayBuffer: _wpJSCoreHTTPBodyConsumerProperty(
    "arrayBuffer",
    _WPJSCoreBodyKind.Response,
  ),
  bytes: _wpJSCoreHTTPBodyConsumerProperty("bytes", _WPJSCoreBodyKind.Response),
  text: _wpJSCoreHTTPBodyConsumerProperty("text", _WPJSCoreBodyKind.Response),
  json: _wpJSCoreHTTPBodyConsumerProperty("json", _WPJSCoreBodyKind.Response),
  formData: _wpJSCoreHTTPBodyConsumerProperty(
    "formData",
    _WPJSCoreBodyKind.Response,
  ),
});
