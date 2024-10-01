import argv
import eensy_dev_tools/cli/flash
import eensy_dev_tools/cli/pack
import glint

pub fn main() {
  let args = argv.load().arguments

  glint.new()
  |> glint.as_module
  |> glint.with_name("eensy/dev")
  |> glint.add(at: ["pack"], do: pack.app())
  |> glint.add(at: ["flash"], do: flash.app())
  |> glint.run(args)
}
