const _WPJSCORE_OPTIONS_PROPERTY_MAPPINGS = {
  keepalive: (value) => !!value,
  redirected: (value) => !!value,
  headers: (value) => value,
  status: (value) => value,
};

function _wpJSCoreHTTPOptionsProperty(path, defaultValue) {
  const mapping = _WPJSCORE_OPTIONS_PROPERTY_MAPPINGS[path];
  return {
    get: function () {
      const value = this[Symbol._wpJSCorePrivate].options[path];
      return value === undefined
        ? defaultValue
        : (mapping?.(value) ?? value.toString());
    },
    enumerable: true,
    configurable: true,
  };
}
