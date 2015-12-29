package = "xcomposer"
version = "3.0-0"
source = {
  url = "git://github.com/hugomg/xcomposer",
  tag = "v3.0",
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
    ["xcomposer.tables"]      = "src/xcomposer/tables.lua",
    ["xcomposer.util"]        = "src/xcomposer/util.lua",
  },
  install = {
    bin = {
      xcomposer = "src/main.lua",
    }
  },
}
