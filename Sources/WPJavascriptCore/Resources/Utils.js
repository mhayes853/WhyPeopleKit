function _wpJSCoreFailedToExecute(name, method, message) {
  return new TypeError(
    `Failed to execute '${method}' on '${name}': ${message}`,
  );
}

function _wpJSCoreFailedToConstruct(name, message) {
  return new TypeError(`Failed to construct '${name}': ${message}`);
}

function _wpJSCoreEnsureMinArgCount(name, clazz, args, expected) {
  if (args.length < expected) {
    const argName = expected === 2 ? "arguments" : "argument";
    throw new TypeError(
      `Failed to execute '${name}' on '${clazz}': ${expected} ${argName} required, but only ${args.length} present.`,
    );
  }
}

function _wpJSCoreEnsureMinArgConstructor(clazz, args, expected) {
  if (args.length < expected) {
    const argName = expected === 2 ? "arguments" : "argument";
    throw new TypeError(
      `Failed to construct '${clazz}': ${expected} ${argName} required, but only ${args.length} present.`,
    );
  }
}

function _wpJSCoreUint8ArrayToString(array) {
  return Array.prototype.map
    .call(array, (c) => String.fromCharCode(c))
    .join("");
}

function _wpJSCoreStringToUint8Array(str) {
  const uint8Array = new Uint8Array(str.length);
  for (let i = 0; i < str.length; i++) {
    uint8Array[i] = str.charCodeAt(i);
  }
  return uint8Array;
}
