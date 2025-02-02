const _WPJSCORE_OPTIONS_PROPERTY_MAPPINGS = {
  keepalive: (value) => !!value,
  redirected: (value) => !!value,
  headers: (value) => value,
  status: (value) => value,
  signal: (value) => value,
};

function _wpJSCoreHTTPOptionsProperty(path, defaultValue) {
  const mapping = _WPJSCORE_OPTIONS_PROPERTY_MAPPINGS[path];
  return _wpJSCoreReadonlyProperty(function () {
    const value = this[Symbol._wpJSCorePrivate].options[path];
    return value === undefined
      ? defaultValue
      : (mapping?.(value) ?? value.toString());
  });
}
