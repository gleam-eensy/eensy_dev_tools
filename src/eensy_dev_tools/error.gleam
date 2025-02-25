// IMPORTS ---------------------------------------------------------------------

import gleam/bit_array
import gleam/list
import gleam/package_interface.{type Type, Fn, Named, Tuple, Variable}
import gleam/string
import simplifile

// TYPES -----------------------------------------------------------------------

pub type Error {
  BuildError(reason: String)
  BundleError(reason: String)
  CannotCreateDirectory(reason: simplifile.FileError, path: String)
  CannotReadFile(reason: simplifile.FileError, path: String)
}

// CONVERSIONS -----------------------------------------------------------------

pub fn explain(error: Error) -> String {
  case error {
    BuildError(reason) -> build_error(reason)
    BundleError(reason) -> bundle_error(reason)
    CannotCreateDirectory(reason, path) -> cannot_create_directory(reason, path)
    CannotReadFile(reason, path) -> cannot_read_file(reason, path)
  }
}

fn build_error(reason: String) -> String {
  let message =
    "
It looks like your project has some compilation errors that need to be addressed
before I can do anything. Here's the error message I got:

{reason}
"

  message
  |> string.replace("{reason}", reason)
}

fn bundle_error(reason: String) -> String {
  let message =
    "
I ran into an unexpected issue while trying to bundle your project with esbuild.
Here's the error message I got:

    {reason}

If you think this is a bug, please open an issue with some details about what
you were trying to do when you ran into this issue.
"

  message
  |> string.replace("{reason}", reason)
}

fn cannot_create_directory(reason: simplifile.FileError, path: String) -> String {
  let message =
    "
I ran into an error while trying to create the following directory:

    {path}

Here's the error message I got:

    {reason}

If you think this is a bug, please open an issue with some details about what
you were trying to do when you ran into this issue.
"

  message
  |> string.replace("{path}", path)
  |> string.replace("{reason}", string.inspect(reason))
}

fn cannot_read_file(reason: simplifile.FileError, path: String) -> String {
  let message =
    "
I ran into an error while trying to read the following file:

    {path}

Here's the error message I got:

    {reason}

If you think this is a bug, please open an issue with some details about what
you were trying to do when you ran into this issue.
"

  message
  |> string.replace("{path}", path)
  |> string.replace("{reason}", string.inspect(reason))
}

// UTILS -----------------------------------------------------------------------

fn pretty_type(t: Type) -> String {
  case t {
    Tuple(elements) -> {
      let message = "#({elements})"
      let elements = list.map(elements, pretty_type)

      message
      |> string.replace("{elements}", string.join(elements, ", "))
    }

    Fn(params, return) -> {
      let message = "fn({params}) -> {return}"
      let params = list.map(params, pretty_type)
      let return = pretty_type(return)

      message
      |> string.replace("{params}", string.join(params, ", "))
      |> string.replace("{return}", return)
    }

    Named(name, _package, _module, []) -> name
    Named(name, _package, _module, params) -> {
      let message = "{name}({params})"
      let params = list.map(params, pretty_type)

      message
      |> string.replace("{name}", name)
      |> string.replace("{params}", string.join(params, ", "))
    }

    Variable(id) -> pretty_var(id)
  }
}

fn pretty_var(id: Int) -> String {
  case id >= 26 {
    True -> pretty_var(id / 26 - 1) <> pretty_var(id % 26)

    False -> {
      let id = id + 97
      let assert Ok(var) = bit_array.to_string(<<id:int>>)

      var
    }
  }
}
