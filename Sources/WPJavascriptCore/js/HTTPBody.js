class _WPJSCoreHTTPBody {
  bodyKind = "Request";

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
  static Request = new _WPJSCoreNullishBody();
  static Response = new _WPJSCoreNullishBody();

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
    this.#buffer = buffer;
  }

  async text() {
    return this.#text;
  }

  async bytes() {
    return new Uint8Array(this.#buffer.transfer());
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
    this.#formData = _wpJSCoreCopyFormData(formData);
    this.#boundary = _wpJSCoreFormDataBoundary();
  }

  async text() {
    return await _wpJSCoreEncodedFormData(this.#formData, this.#boundary);
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

function _wpJSCoreHTTPBodyConsumerProperty(methodName) {
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
