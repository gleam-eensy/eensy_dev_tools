// IMPORTS ---------------------------------------------------------------------

import eensy_dev_tools/cli.{type Cli, do, try}
import eensy_dev_tools/cli/flag
import eensy_dev_tools/error.{type Error}
import eensy_dev_tools/packbeam
import eensy_dev_tools/project
import filepath
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import glint
import simplifile

// DESCRIPTION -----------------------------------------------------------------

pub const description: String = "
Commands for packing BEAM and static files from your project
  "

// COMMANDS --------------------------------------------------------------------

pub fn app() -> glint.Command(Nil) {
  use <- glint.command_help(description)
  use <- glint.unnamed_args(glint.EqArgs(0))
  use prune <- glint.flag(flag.prune())
  use _, _, flags <- glint.command()
  let script = {
    use prune <- do(cli.get_bool("prune", False, ["build"], prune))

    do_app(prune)
  }

  case cli.run(script, flags) {
    Ok(_) -> Nil
    Error(error) -> error.explain(error) |> io.print_error
  }
}

pub fn do_app(prune: Bool) -> Cli(Nil) {
  use <- cli.log("Packing your project")
  use project_name <- do(cli.get_name())

  use <- cli.success("Project compiled successfully")
  use <- cli.log("Loading ")

  use <- cli.log("Running atomvm beam packer")
  let root = project.root()
  use _ <- try(project.export())

  let output_path = filepath.join(root, "build/.atomvm")
  result.unwrap(simplifile.create_directory_all(output_path), Nil)
  let input_paths =
    result.unwrap(simplifile.get_files(in: "build/erlang-shipment/"), [])
    |> list.filter(fn(path) { string.contains(path, ".beam") })

  use _ <- try(packbeam.create(
    filepath.join(output_path, project_name <> ".release.avm"),
    input_paths,
    Some(prune),
    project_name,
    None,
  ))

  cli.return(Nil)
}
