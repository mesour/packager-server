# Nuclear reactor

### Normal and fluid reactor are supported

Automatic program for manage nuclear reactor or fluid nuclear reactor.

- **Program is written only for one fuel rod settings. See it on second image (not require all rods in reactor,
but maximum can be 6 fuel rods and must be placed on specified places like on image).**
- Program will automatically stop reactor if heat is too much
- Program will automatically stop fluid reactor if cold coolant is too low amount or hot coolant is too much amount

![Reactor with monitor](https://github.com/mesour/packager-server/blob/master/docs/img/reactor.png)

![Reactor inside](https://github.com/mesour/packager-server/blob/master/docs/img/reactor_inside.png)

## Requirements

1. IndustrialCraft 2 (IC2)
2. Computercraft (CC:Tweaked)
3. Plethora

Tested on Minecraft 1.12.2

## Installation

1. Install package `reactor`
2. Run `mv reactor-config.json config.json` to move config
3. Run `edit config.json` and save your current configuration
4. Restart computer (`ctrl + R`)

## Configuration

Redstone integrator must be connected to `Reactor redstone port`.

- All configurations are **required**.
- `monitor` is name for default reactor monitoring. For display detailed info
about reactor use [ReactorMonitor](https://github.com/mesour/packager-server/blob/master/docs/en/reactorMonitor.md).
- `type` is is only for fluid reactor use `"type": "fluid"`
- `reactor` is name of a connected redstone_integrator (Plethora mod)
- `integrator` is array of [`periphral_name`, `word_side`]
  - `periphral_name` is name of a connected redstone_integrator (Plethora mod)
  - `word_side` is `north`, `east`, `south` or `west`. This is side for redstone_integrator where toggle signal.

### Normal reactor

```
{
  "name": "r1",
  "rednet": "left",
  "monitor": "monitor_1",
  "reactor": "ic2:reactor_chamber_0",
  "integrator": ["redstone_integrator_0", "south"]
}
```

### Fluid reactor

```
{
  "name": "r1",
  "rednet": "left",
  "type": "fluid",
  "monitor": "top",
  "reactor": "ic2:reactor_access_hatch_0",
  "integrator": ["redstone_integrator_0", "north"]
}
```
