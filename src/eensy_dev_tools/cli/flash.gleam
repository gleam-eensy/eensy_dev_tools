// IMPORTS ---------------------------------------------------------------------

import eensy_dev_tools/cli.{type Cli, do}
import eensy_dev_tools/cli/flag
import eensy_dev_tools/cli/pack
import eensy_dev_tools/error.{type Error}
import eensy_dev_tools/project
import gleam/io
import gleam/result
import gleam/string
import glint

// DESCRIPTION -----------------------------------------------------------------

pub const description: String = "
Commands for packing BEAM and static files from your project and 
flashing to a device
  "

// COMMANDS --------------------------------------------------------------------

pub fn app() -> glint.Command(Nil) {
  use <- glint.command_help(description)
  use <- glint.unnamed_args(glint.EqArgs(0))
  use platform <- glint.flag(flag.platform())
  use port <- glint.flag(flag.port())
  use prune <- glint.flag(flag.prune())
  use _, _, flags <- glint.command()
  let script = {
    use prune <- do(cli.get_bool("prune", False, [], prune))

    pack.do_app(prune)
  }

  case cli.run(script, flags) {
    Ok(_) -> Nil
    Error(error) -> error.explain(error) |> io.print_error
  }

  let script = {
    use platform <- do(cli.get_string("platform", "esp32", [], platform))
    use port <- do(cli.get_string("port", "", [], port))

    do_app(platform, port)
  }

  case cli.run(script, flags) {
    Ok(_) -> Nil
    Error(error) -> error.explain(error) |> io.print_error
  }
}

pub fn do_app(platform: String, port: String) -> Cli(Nil) {
  use <- cli.log("Flashing [" <> platform <> "]")
  use project_name <- do(cli.get_name())
  case string.lowercase(platform) {
    "esp32" -> project.flash_esp_32(project_name, port) |> result.unwrap(Nil)
    _ -> Nil
  }

  cli.return(Nil)
}
