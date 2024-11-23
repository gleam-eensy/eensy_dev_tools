# eensy_dev_tools

Very early alpha stage. Please just use it for hobby projects. Open to contributions.

[![Package Version](https://img.shields.io/hexpm/v/eensy_dev_tools)](https://hex.pm/packages/eensy_dev_tools)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/eensy_dev_tools/)

```sh
gleam add --dev eensy_dev_tools
```

Further documentation can be found at <https://hexdocs.pm/eensy_dev_tools>.

## Development

```sh
gleam run -m eensy_dev_tools flash esp32 # Run devtools for flashing to an esp32 device
gleam test  # Run the tests
```


# MacOS interesting stuff

```sh
esptool.py --chip auto --port /dev/tty.usbserial-0001 --baud 921600 erase_flash
```

```sh
esptool.py \  
--chip auto \
--port /dev/tty.usbserial-0001 --baud 921600 \
--before default_reset --after hard_reset \
write_flash -u \
--flash_mode dio --flash_freq 40m --flash_size detect \
0x1000 \
~/Downloads/AtomVM-esp32-v0.6.4.img
```

