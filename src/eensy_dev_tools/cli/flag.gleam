// IMPORTS ---------------------------------------------------------------------

import glint

// FLAGS -----------------------------------------------------------------------

pub fn prune() -> glint.Flag(Bool) {
  let description = "Prune based on BEAM files definitions."

  glint.bool_flag("prune")
  |> glint.flag_help(description)
}

pub fn platform() -> glint.Flag(String) {
  let description = "Platform to use for flashing a device."

  glint.string_flag("platform")
  |> glint.flag_help(description)
}

pub fn port() -> glint.Flag(String) {
  let description = "Port to use for flashing a device."

  glint.string_flag("port")
  |> glint.flag_help(description)
}
