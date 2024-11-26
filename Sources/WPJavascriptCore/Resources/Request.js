const Request = (function () {
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
    if (requestOptions?.body !== undefined && !canHaveBody(method)) {
      throw _wpJSCoreFailedToConstruct(
        "Request",
        "Request with GET/HEAD method cannot have body.",
      );
    }
    this[Symbol._wpJSCorePrivate] = {
      ...rest,
      options: {
        ...requestOptions,
        headers: convertHeaders(requestOptions?.headers),
        body: initialBody(requestOptions?.body),
      },
    };
  }

  function convertHeaders(headers) {
    try {
      return new Headers(headers);
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

  function initialBody(body) {
    if (body instanceof FormData) return _wpJSCoreCopyFormData(body);
    return body;
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
    blob: bodyConsumer("blob", bodyBlob),
    arrayBuffer: bodyConsumer("arrayBuffer", async (b) => {
      return (await bodyBytes(b)).buffer;
    }),
    bytes: bodyConsumer("bytes", bodyBytes),
    text: bodyConsumer("text", bodyText),
    json: bodyConsumer("json", (b) => bodyText(b).then(JSON.parse)),
    formData: bodyConsumer("formData", bodyFormData),
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

  function bodyConsumer(methodName, consume) {
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
        return consume(this[Symbol._wpJSCorePrivate].options.body);
      },
      enumerable: false,
      configurable: false,
    };
  }

  function stringToUint8Array(str) {
    const uint8Array = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      uint8Array[i] = str.charCodeAt(i);
    }
    return uint8Array;
  }

  function uint8ArrayToString(array) {
    return Array.prototype.map
      .call(array, (c) => String.fromCharCode(c))
      .join("");
  }

  async function bodyBytes(body) {
    if (body instanceof Blob) {
      return await body.bytes();
    } else if (body === undefined) {
      return new Uint8Array([]);
    } else if (ArrayBuffer.isView(body)) {
      return new Uint8Array(body.buffer);
    } else {
      return stringToUint8Array(body.toString());
    }
  }

  async function bodyText(body) {
    if (body instanceof Blob) {
      return await body.text();
    } else if (body === undefined) {
      return "";
    } else if (ArrayBuffer.isView(body)) {
      return uint8ArrayToString(new Uint8Array(body.buffer));
    } else {
      return body.toString();
    }
  }

  async function bodyBlob(body) {
    if (body instanceof Blob) {
      return body;
    } else if (body === undefined) {
      return new Blob();
    } else if (ArrayBuffer.isView(body)) {
      return new Blob([await bodyText(body)]);
    } else {
      return new Blob([body.toString()]);
    }
  }

  async function bodyFormData(body) {
    if (body instanceof FormData) return body;
    throw _wpJSCoreFailedToExecute("Request", "formData", "Failed to fetch");
  }

  return Request;
})();
