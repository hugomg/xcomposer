package = "xcomposer"
version = "2.0-0"
source = {
  url = "git://github.com/hugomg/xcomposer",
  tag = "v2.0",
}
description = {
  summary = "A DSL for more readable .XCompose files",
  homepage = "https://github.com/hugomg/xcomposer",
  license = "MIT",
}
dependencies = {
  "argparse",
  "cosmo",
  "dromozoa-utf8",
}
build = {
  type = "builtin",
  modules = {
    ["xcomposer.ComposeFile"] = "src/xcomposer/ComposeFile.lua",
    ["xcomposer.keysyms"]     = "src/xcomposer/keysyms.lua",
    ["xcomposer.util"]        = "src/xcomposer/util.lua",
  },
  install = {
    bin = {
      xcomposer = "src/main.lua",
    }
  },
}
