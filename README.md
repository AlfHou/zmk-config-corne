# ZMK Config

Firmware configuration for Corne and Mechboards Lily58 (with nice!view displays).

## Building

Requires Docker. Builds use `zmkfirmware/zmk-build-arm:4.1`.

```sh
./build.sh                  # build all shields
./build.sh corne_left       # build one shield
PRISTINE=1 ./build.sh       # clean rebuild (needed after config/overlay changes)
```

Output goes to `firmware/*.uf2`.

## Lily58 nice!view display

The Mechboards Lily58 routes the nice!view CS pin to **pro_micro pin 4**, not the default pin 1 used by `nice_view_adapter`. This is overridden in `config/lily58.keymap`:

```dts
&nice_view_spi {
    cs-gpios = <&pro_micro 4 GPIO_ACTIVE_HIGH>;
};
```

The display uses the [MechboardsLTD/zmk-module](https://github.com/MechboardsLTD/zmk-module) (`nv_gem` branch) which provides the `nice_view_gem` shield. This is pulled in via `config/west.yml`.

## West workspace

The west workspace lives in `.zmk/` (gitignored). To set up or update:

```sh
cd .zmk && west update
```
