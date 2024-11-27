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
    method: _wpJSCoreRequestOptionsProperty("method", "GET"),
    headers: _wpJSCoreRequestOptionsProperty("headers", new Headers()),
    signal: _wpJSCoreRequestOptionsProperty("signal"),
    credentials: _wpJSCoreRequestOptionsProperty("credentials", "same-origin"),
    cache: _wpJSCoreRequestOptionsProperty("cache", "default"),
    integrity: _wpJSCoreRequestOptionsProperty("integrity", ""),
    keepalive: _wpJSCoreRequestOptionsProperty("keepalive", false),
    mode: _wpJSCoreRequestOptionsProperty("mode", "cors"),
    redirect: _wpJSCoreRequestOptionsProperty("redirect", "follow"),
    referrer: _wpJSCoreRequestOptionsProperty("referrer", "about:client"),
    referrerPolicy: _wpJSCoreRequestOptionsProperty("referrerPolicy"),
    clone: {
      value: function () {
        return new Request(this);
      },
      enumerable: false,
      configurable: false,
    },
    blob: bodyConsumer("blob"),
    arrayBuffer: bodyConsumer("arrayBuffer"),
    bytes: bodyConsumer("bytes"),
    text: bodyConsumer("text"),
    json: bodyConsumer("json"),
    formData: bodyConsumer("formData"),
  });

  function _wpJSCoreRequestOptionsProperty(path, defaultValue) {
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

  function bodyConsumer(methodName) {
    return {
      value: function () {
        if (this[Symbol._wpJSCorePrivate].bodyUsed) {
          throw _wpJSCoreFailedToExecute(
            "Request",
            methodName,
            "body stream already read",
          );
        }
        this[Symbol._wpJSCorePrivate].bodyUsed = true;
        return this[Symbol._wpJSCorePrivate].body[methodName]();
      },
      enumerable: false,
      configurable: false,
    };
  }

  return Request;
})();
