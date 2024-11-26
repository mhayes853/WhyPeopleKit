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
