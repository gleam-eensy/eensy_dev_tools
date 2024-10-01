// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}

// EXTERNALS -------------------------------------------------------------------

///
///
@external(erlang, "eensy_dev_tools_ffi", "exec")
pub fn exec(
  run command: String,
  with args: List(String),
  in in: String,
) -> Result(String, #(Int, String))

///
///
@external(erlang, "eensy_dev_tools_ffi", "get_cwd")
pub fn cwd() -> Result(String, Dynamic)
