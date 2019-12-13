# Energy storage grid

Automatic program for display data from IC2 energy storages.

![Energy storage grid monitor](https://github.com/mesour/packager-server/blob/master/docs/img/energyStorageGrid_monitor.png)

![Energy storage grid](https://github.com/mesour/packager-server/blob/master/docs/img/energyStorageGrid.png)

## Requirements

1. IndustrialCraft 2 (IC2)
2. Computercraft (CC:Tweaked)

Tested on Minecraft 1.12.2

## Installation

1. Install package `energyStorageGrid`
2. Run `mv energy-storage-grid-config.json config.json` to move config
3. Run `edit config.json` and save your current configuration
4. Restart computer (`ctrl + R`)

## Configuration

- All configurations are **required**.
- `remoteMonitor` is name for [remote monitor](https://github.com/mesour/packager-server/blob/master/docs/en/monitor.md)
- `monitorSize` must be array with two items [`width`, `height`].
  - `width` can be `big` or `medium`
  - `height` can be `big`, `medium` or `small`
- `storages` is array of connected peripherals

```
{
  "name": "sg1",
  "rednet": "left",
  "remoteMonitor": "m1",
  "monitorSize": ["medium", "small"],
  "storages": [
    "ic2:mfsu_0",
    "ic2:mfsu_1",
    "ic2:mfsu_2",
    ...
  ]
}
```
