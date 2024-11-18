function File(
  fileBits,
  fileName,
  options = { lastModified: Date.now(), type: "", endings: "transparent" },
) {
  let count = 2;
  if (fileBits === undefined) count -= 1;
  if (fileName === undefined) count -= 1;
  if (count < 2) {
    throw new TypeError(
      `Failed to construct 'File': 2 arguments required, but only ${count} present.`,
    );
  }
  try {
    // NB: Grab the native blob out of the bits because Blob cannot be constructed from another
    // Blob instance, but can with the native blob object.
    const bits =
      fileBits instanceof Blob
        ? fileBits[Symbol._wpJSCorePrivate].nativeBlob
        : fileBits;
    Blob.call(this, bits, options);
    this[Symbol._wpJSCorePrivate].file = {
      fileName: fileName.toString(),
      ...options,
      lastModified:
        options.lastModified instanceof Date
          ? options.lastModified.getTime()
          : options.lastModified,
    };
  } catch (e) {
    throw new TypeError(e.message.replace("Blob", "File"));
  }
}

File.prototype = Object.create(Blob.prototype);
File.prototype.constructor = File;

Object.defineProperties(File.prototype, {
  lastModified: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].file.lastModified;
    },
    enumerable: false,
    configurable: true,
  },
  name: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].file.fileName;
    },
    enumerable: false,
    configurable: true,
  },
  webkitRelativePath: {
    get: function () {
      return "";
    },
    enumerable: false,
    configurable: true,
  },
});
