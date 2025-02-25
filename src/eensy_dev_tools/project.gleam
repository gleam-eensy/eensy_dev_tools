// IMPORTS ---------------------------------------------------------------------

import eensy_dev_tools/cmd
import eensy_dev_tools/error.{type Error, BuildError}
import filepath
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/package_interface.{type Type, Fn, Named, Tuple, Variable}
import gleam/pair
import gleam/result
import gleam/string
import simplifile
import tom.{type Toml}

// TYPES -----------------------------------------------------------------------

pub type Config {
  Config(name: String, version: String, toml: Dict(String, Toml))
}

pub type Interface {
  Interface(name: String, version: String, modules: Dict(String, Module))
}

pub type Module {
  Module(constants: Dict(String, Type), functions: Dict(String, Function))
}

pub type Function {
  Function(parameters: List(Type), return: Type)
}

// COMMANDS --------------------------------------------------------------------

/// Generate export erlang-shipment
///
pub fn export() -> Result(Nil, Error) {
  cmd.exec(run: "gleam", in: ".", with: ["export", "erlang-shipment"])
  |> result.map_error(fn(err) { BuildError(pair.second(err)) })
  |> result.replace(Nil)
}

pub fn flash_esp_32(project_name: String, port: String) -> Result(Nil, Error) {
  let args = [
    "--chip",
    "auto",
    "--port",
    port,
    "--baud",
    "921600",
    "--before",
    "default_reset",
    "--after",
    "hard_reset",
    "write_flash",
    "-u",
    "--flash_mode",
    "keep",
    "--flash_freq",
    "keep",
    "--flash_size",
    "detect",
    "0x210000",
    "./build/.atomvm/" <> project_name <> ".release.avm",
  ]
  cmd.exec(run: "esptool.py", in: ".", with: args)
  |> result.map_error(fn(err) { BuildError(pair.second(err)) })
  |> result.replace(Nil)
}

pub fn run_local(project_name: String) -> Result(Nil, Error) {
  cmd.exec(run: "atomvm ", in: ".", with: [
    "./build/.atomvm/" <> project_name <> ".release.avm",
  ])
  |> result.map_error(fn(err) { BuildError(pair.second(err)) })
  |> result.replace(Nil)
}

/// Read the project configuration in the `gleam.toml` file.
///
pub fn config() -> Result(Config, Error) {
  // Since we made sure that the project could compile we're sure that there is
  // bound to be a `gleam.toml` file somewhere in the current directory (or in
  // its parent directories). So we can safely call `root()` without
  // it looping indefinitely.
  let configuration_path = filepath.join(root(), "gleam.toml")

  // All these operations are safe to assert because the Gleam project wouldn't
  // compile if any of this stuff was invalid.
  let assert Ok(configuration) = simplifile.read(configuration_path)
  let assert Ok(toml) = tom.parse(configuration)
  let assert Ok(name) = tom.get_string(toml, ["name"])
  let assert Ok(version) = tom.get_string(toml, ["version"])

  Ok(Config(name: name, version: version, toml: toml))
}

// UTILS -----------------------------------------------------------------------

/// Finds the path leading to the project's root folder. This recursively walks
/// up from the current directory until it finds a `gleam.toml`.
///
pub fn root() -> String {
  find_root(".")
}

fn find_root(path: String) -> String {
  let toml = filepath.join(path, "gleam.toml")

  case simplifile.is_file(toml) {
    Ok(False) | Error(_) -> find_root(filepath.join("..", path))
    Ok(True) -> path
  }
}

pub fn type_to_string(type_: Type) -> String {
  case type_ {
    Tuple(elements) -> {
      let elements = list.map(elements, type_to_string)
      "#(" <> string.join(elements, with: ", ") <> ")"
    }

    Fn(params, return) -> {
      let params = list.map(params, type_to_string)
      let return = type_to_string(return)
      "fn(" <> string.join(params, with: ", ") <> ") -> " <> return
    }

    Named(name, _package, _module, []) -> name
    Named(name, _package, _module, params) -> {
      let params = list.map(params, type_to_string)
      name <> "(" <> string.join(params, with: ", ") <> ")"
    }

    Variable(id) -> "a_" <> int.to_string(id)
  }
}
