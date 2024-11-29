function Request(urlOrRequest, options) {
  _wpJSCoreEnsureMinArgConstructor("Request", [urlOrRequest, options], 1);
  if (options !== undefined && typeof options !== "object") {
    throw _wpJSCoreFailedToConstruct(
      "Request",
      "The provided value is not of type 'RequestInit'.",
    );
  }
  const { requestOptions, ...rest } =
    urlOrRequest instanceof Request
      ? {
          url: urlOrRequest[Symbol._wpJSCorePrivate].url,
          bodyUsed: urlOrRequest[Symbol._wpJSCorePrivate].bodyUsed,
          requestOptions: {
            ...urlOrRequest[Symbol._wpJSCorePrivate].options,
            ...options,
          },
        }
      : {
          url: urlOrRequest.toString(),
          bodyUsed: false,
          requestOptions: options,
        };
  const method = requestOptions?.method ?? "GET";
  const canHaveBody = method !== "GET" && method !== "HEAD";
  if (requestOptions?.body !== undefined && !canHaveBody) {
    throw _wpJSCoreFailedToConstruct(
      "Request",
      "Request with GET/HEAD method cannot have body.",
    );
  }
  const body = _wpJSCoreHTTPBody(
    requestOptions?.body,
    _WPJSCoreBodyKind.Request,
  );
  this[Symbol._wpJSCorePrivate] = {
    ...rest,
    body,
    options: {
      ...requestOptions,
      headers: _wpJSCoreHTTPHeaders(
        requestOptions?.headers,
        body,
        _WPJSCoreBodyKind.Request,
      ),
    },
  };
}

Object.defineProperties(Request.prototype, {
  url: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].url;
    },
    enumerable: true,
    configurable: true,
  },
  bodyUsed: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].bodyUsed;
    },
    enumerable: true,
    configurable: true,
  },
  method: _wpJSCoreHTTPOptionsProperty("method", "GET"),
  headers: _wpJSCoreHTTPOptionsProperty("headers", new Headers()),
  signal: _wpJSCoreHTTPOptionsProperty("signal"),
  credentials: _wpJSCoreHTTPOptionsProperty("credentials", "same-origin"),
  cache: _wpJSCoreHTTPOptionsProperty("cache", "default"),
  integrity: _wpJSCoreHTTPOptionsProperty("integrity", ""),
  keepalive: _wpJSCoreHTTPOptionsProperty("keepalive", false),
  mode: _wpJSCoreHTTPOptionsProperty("mode", "cors"),
  redirect: _wpJSCoreHTTPOptionsProperty("redirect", "follow"),
  referrer: _wpJSCoreHTTPOptionsProperty("referrer", "about:client"),
  referrerPolicy: _wpJSCoreHTTPOptionsProperty("referrerPolicy"),
  clone: {
    value: function () {
      return new Request(this);
    },
    enumerable: false,
    configurable: false,
  },
  blob: _wpJSCoreHTTPBodyConsumerProperty("blob", _WPJSCoreBodyKind.Request),
  arrayBuffer: _wpJSCoreHTTPBodyConsumerProperty(
    "arrayBuffer",
    _WPJSCoreBodyKind.Request,
  ),
  bytes: _wpJSCoreHTTPBodyConsumerProperty("bytes", _WPJSCoreBodyKind.Request),
  text: _wpJSCoreHTTPBodyConsumerProperty("text", _WPJSCoreBodyKind.Request),
  json: _wpJSCoreHTTPBodyConsumerProperty("json", _WPJSCoreBodyKind.Request),
  formData: _wpJSCoreHTTPBodyConsumerProperty(
    "formData",
    _WPJSCoreBodyKind.Request,
  ),
});
