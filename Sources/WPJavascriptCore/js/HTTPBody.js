const _WPJSCoreBodyKind = { Request: "Request", Response: "Response" };

class _WPJSCoreHTTPBody {
  bodyKind = _WPJSCoreBodyKind.Request;

  get contentTypeHeader() {
    return null;
  }

  async bytes() {
    this.#subclassResponsibility();
  }

  async text() {
    this.#subclassResponsibility();
  }

  async blob() {
    this.#subclassResponsibility();
  }

  async formData() {
    throw _wpJSCoreFailedToExecute(
      this.bodyKind,
      "formData",
      "Failed to fetch",
    );
  }

  async arrayBuffer() {
    return await this.bytes().then((b) => b.buffer);
  }

  async json() {
    return await this.text().then(JSON.parse);
  }

  #subclassResponsibility() {
    throw new Error("Subclass Responsibility");
  }
}

class _WPJSCoreNullishBody extends _WPJSCoreHTTPBody {
  static Request = _WPJSCoreNullishBody.ofKind(_WPJSCoreBodyKind.Request);
  static Response = _WPJSCoreNullishBody.ofKind(_WPJSCoreBodyKind.Response);

  static ofKind(bodyKind) {
    const body = new _WPJSCoreNullishBody();
    body.bodyKind = bodyKind;
    return body;
  }

  async text() {
    return "";
  }

  async blob() {
    return new Blob([""]);
  }

  async bytes() {
    return new Uint8Array([]);
  }
}

class _WPJSCoreToStringableBody extends _WPJSCoreHTTPBody {
  #value;

  get contentTypeHeader() {
    return "text/plain; charset=UTF-8";
  }

  constructor(value) {
    super();
    this.#value = value;
  }

  async text() {
    return this.#value.toString();
  }

  async bytes() {
    return _wpJSCoreStringToUint8Array(this.#value.toString());
  }

  async blob() {
    return new Blob([this.#value.toString()]);
  }
}

class _WPJSCoreBlobBody extends _WPJSCoreHTTPBody {
  #blob;

  get contentTypeHeader() {
    return this.#blob.type;
  }

  constructor(blob) {
    super();
    this.#blob = blob;
  }

  async text() {
    return await this.#blob.text();
  }

  async bytes() {
    return await this.#blob.bytes();
  }

  async blob() {
    return this.#blob;
  }
}

class _WPJSCoreArrayBufferBody extends _WPJSCoreHTTPBody {
  #buffer;

  get #text() {
    return _wpJSCoreUint8ArrayToString(new Uint8Array(this.#buffer));
  }

  constructor(buffer) {
    super();
    this.#buffer = buffer.transfer();
  }

  async text() {
    return this.#text;
  }

  async bytes() {
    return new Uint8Array(this.#buffer);
  }

  async blob() {
    return new Blob([this.#text]);
  }
}

class _WPJSCoreFormDataBody extends _WPJSCoreHTTPBody {
  #formData;
  #boundary;

  get contentTypeHeader() {
    return `multipart/form-data; boundary=${this.#boundary}`;
  }

  constructor(formData) {
    super();
    this.#formData = formData._wpJSCoreCopy();
    this.#boundary = _wpJSCoreFormDataBoundary();
  }

  async text() {
    return await this.#formData._wpJSCoreEncoded(this.#boundary);
  }

  async bytes() {
    return _wpJSCoreStringToUint8Array(await this.text());
  }

  async blob() {
    return new Blob([await this.text()]);
  }

  async formData() {
    return this.#formData;
  }
}

function _wpJSCoreHTTPBodyConsumerProperty(methodName, bodyKind) {
  return _wpJSCoreFunctionProperty(function () {
    if (this[Symbol._wpJSCorePrivate].bodyUsed) {
      throw _wpJSCoreFailedToExecute(
        bodyKind,
        methodName,
        "body stream already read",
      );
    }
    this[Symbol._wpJSCorePrivate].bodyUsed = true;
    return this[Symbol._wpJSCorePrivate].body[methodName]();
  });
}

function _wpJSCoreHTTPHeaders(headers, body) {
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
        `Failed to construct '${body.bodyKind}': Failed to read the 'headers' property from '${body.bodyKind}Init':`,
      ),
    );
  }
}

function _wpJSCoreHTTPBody(rawBody, bodyKind) {
  let body;
  if (rawBody instanceof Blob) {
    body = new _WPJSCoreBlobBody(rawBody);
  } else if (rawBody === undefined || rawBody === null) {
    body = _WPJSCoreNullishBody[bodyKind];
  } else if (ArrayBuffer.isView(rawBody)) {
    body = new _WPJSCoreArrayBufferBody(rawBody.buffer);
  } else if (rawBody instanceof ArrayBuffer) {
    body = new _WPJSCoreArrayBufferBody(rawBody);
  } else if (rawBody instanceof FormData) {
    body = new _WPJSCoreFormDataBody(rawBody);
  } else {
    body = new _WPJSCoreToStringableBody(rawBody);
  }
  body.bodyKind = bodyKind;
  return body;
}
