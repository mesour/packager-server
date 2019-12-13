# Energy meter

Automatic program for display how much EU went through the energy cable.

![Energy meter monitor](https://github.com/mesour/packager-server/blob/master/docs/img/energyMeter_monitor.png)

![Energy meter](https://github.com/mesour/packager-server/blob/master/docs/img/energyMeter.png)

## Requirements

1. IndustrialCraft 2 (IC2)
2. Computercraft (CC:Tweaked)
3. Plethora

Tested on Minecraft 1.12.2

## Installation

1. Install package `electroMeter`
2. Run `mv electro-meter-config.json config.json` to move config
3. Run `edit config.json` and save your current configuration
4. Restart computer (`ctrl + R`)

## Configuration

- All configurations are **required**.
- `remoteMonitor` is name for [remote monitor](https://github.com/mesour/packager-server/blob/master/docs/en/monitor.md)
- `mfsu` is name of a connected peripheral for center energy storage. For example MFSU.
- `inputIntegrator` and `outputIntegrator` is array of [`periphral_name`, `word_side`]
  - `periphral_name` is name of a connected redstone_integrator (Plethora mod)
  - `word_side` is `north`, `east`, `south` or `west`. This is side for redstone_integrator where toggle signal.
- `autoMode` must be always `true` for now

```
{
  "name": "em1",
  "rednet": "left",
  "remoteMonitor": "m1",
  "mfsu": "ic2:mfsu_0",
  "inputIntegrator": ["redstone_integrator_1", "west"],
  "outputIntegrator": ["redstone_integrator_2", "north"],
  "autoMode": true
}
```
