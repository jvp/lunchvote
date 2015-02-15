@Images = new FS.Collection "images", {
  stores: [
    new FS.Store.FileSystem "images",
    { path: "/tmp" }
  ]
}

Images.allow {
  download: (userId, file) ->
    return true
}
