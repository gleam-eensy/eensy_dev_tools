// IMPORTS ---------------------------------------------------------------------

import eensy_dev_tools/error.{type Error}
import gleam/option.{type Option}

// TYPES -----------------------------------------------------------------------

pub type Path =
  String

pub type CreateModule {
  String
  Undefined
}

// EXTERNALS -------------------------------------------------------------------

pub fn create(
  output_path: Path,
  input_paths: List(Path),
  prune: Option(Bool),
  start_module: Path,
  include_lines: Option(Bool),
) {
  do_create(
    output_path,
    input_paths,
    prune |> option.unwrap(True),
    start_module,
    include_lines |> option.unwrap(True),
  )
}

@external(erlang, "eensy_dev_tools_ffi", "create_with_result")
fn do_create(
  output_path: Path,
  input_paths: List(Path),
  prune: Bool,
  start_module: Path,
  include_lines: Bool,
) -> Result(Nil, Error)
