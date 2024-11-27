const Request = (function () {
  function Request(urlOrRequest, options) {
    _wpJSCoreEnsureMinArgConstructor("Request", [urlOrRequest, options], 1);
    if (options !== undefined && typeof options !== "object") {
      throw _wpJSCoreFailedToConstruct(
        "Request",
        "The provided value is not of type 'RequestInit'.",
      );
    }
    const formDataBoundary = _wpJSCoreFormDataBoundary();
    const { requestOptions, ...rest } =
      urlOrRequest instanceof Request
        ? {
            url: urlOrRequest[Symbol._wpJSCorePrivate].url,
            bodyUsed: urlOrRequest[Symbol._wpJSCorePrivate].bodyUsed,
            formDataBoundary,
            requestOptions: {
              ...urlOrRequest[Symbol._wpJSCorePrivate].options,
              ...options,
            },
          }
        : {
            url: urlOrRequest.toString(),
            formDataBoundary,
            bodyUsed: false,
            requestOptions: options,
          };
    const method = requestOptions?.method ?? "GET";
    if (requestOptions?.body !== undefined && !canHaveBody(method)) {
      throw _wpJSCoreFailedToConstruct(
        "Request",
        "Request with GET/HEAD method cannot have body.",
      );
    }
    const body = _wpJSCoreHTTPBody(requestOptions?.body, "Request");
    this[Symbol._wpJSCorePrivate] = {
      ...rest,
      body,
      options: {
        ...requestOptions,
        headers: requestHeaders(requestOptions?.headers, body),
      },
    };
  }

  function requestHeaders(headers, body) {
    try {
      const newHeaders = new Headers(headers);
      if (newHeaders.has("Content-Type") || !body.contentTypeHeader) {
        return newHeaders;
      }
      newHeaders.set("Content-Type", body.contentTypeHeader);
      return newHeaders;
    } catch (e) {
      throw new TypeError(
        e.message.replace(
          "Failed to construct 'Headers':",
          "Failed to construct 'Request': Failed to read the 'headers' property from 'RequestInit':",
        ),
      );
    }
  }

  function canHaveBody(method) {
    return method !== "GET" && method !== "HEAD";
  }

  const OPTIONS_PROPERTY_MAPPINGS = {
    keepalive: (value) => !!value,
    headers: (value) => value,
  };
  const DEFAULT_OPTIONS_PROPERTY_MAPPING = (value) => value.toString();

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
    method: optionsProperty("method", "GET"),
    headers: optionsProperty("headers", new Headers()),
    signal: optionsProperty("signal"),
    credentials: optionsProperty("credentials", "same-origin"),
    cache: optionsProperty("cache", "default"),
    integrity: optionsProperty("integrity", ""),
    keepalive: optionsProperty("keepalive", false),
    mode: optionsProperty("mode", "cors"),
    redirect: optionsProperty("redirect", "follow"),
    referrer: optionsProperty("referrer", "about:client"),
    referrerPolicy: optionsProperty("referrerPolicy"),
    clone: {
      value: function () {
        return new Request(this);
      },
      enumerable: false,
      configurable: false,
    },
    blob: _wpJSCoreHTTPBodyConsumerProperty("blob"),
    arrayBuffer: _wpJSCoreHTTPBodyConsumerProperty("arrayBuffer"),
    bytes: _wpJSCoreHTTPBodyConsumerProperty("bytes"),
    text: _wpJSCoreHTTPBodyConsumerProperty("text"),
    json: _wpJSCoreHTTPBodyConsumerProperty("json"),
    formData: _wpJSCoreHTTPBodyConsumerProperty("formData"),
  });

  function optionsProperty(path, defaultValue) {
    const mapping =
      OPTIONS_PROPERTY_MAPPINGS[path] ?? DEFAULT_OPTIONS_PROPERTY_MAPPING;
    return {
      get: function () {
        const value = this[Symbol._wpJSCorePrivate].options[path];
        return value === undefined ? defaultValue : mapping(value);
      },
      enumerable: true,
      configurable: true,
    };
  }

  return Request;
})();
