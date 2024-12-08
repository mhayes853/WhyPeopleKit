function Crypto(key) {
  _wpJSCoreInternalConstructorCheck(key);
}

Object.defineProperties(Crypto.prototype, {
  randomUUID: _wpJSCoreFunctionProperty(_wpJSCoreRandomUUID),
  getRandomValues: _wpJSCoreFunctionProperty(function (view) {
    _wpJSCoreEnsureMinArgCount("getRandomValues", "Crypto", [view], 1);
    if (!ArrayBuffer.isView(view)) {
      throw _wpJSCoreFailedToExecute(
        "Crypto",
        "getRandomValues",
        "parameter 1 is not of type 'ArrayBufferView'.",
      );
    }
    const dataView = new DataView(view.buffer);
    const bytes = _wpJSCoreRandomBytes(view.byteLength);
    for (let i = 0; i < view.byteLength; i++) {
      dataView.setUint8(i, bytes[i]);
    }
    return view;
  }),
});

const crypto = new Crypto(Symbol._wpJSCorePrivate);
