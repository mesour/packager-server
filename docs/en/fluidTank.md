# Fluid tank

Automatic turtle program for display tank capacity and current content.

![Fluid tank](https://github.com/mesour/packager-server/blob/master/docs/img/fluidTank.png)

![Fluid tank monitor](https://github.com/mesour/packager-server/blob/master/docs/img/fluidTank_monitor.png)

## Requirements

1. IndustrialCraft 2 (IC2)
2. Computercraft

Tested on Minecraft 1.12.2.

## Installation

1. Install package `turtle`
2. Run `mv fluid-tank-config.json config.json` to move config
3. Run `edit config.json` and save your current configuration
4. Restart computer (`ctrl + R`)

## Configuration

1. All configurations are **required**.
2. Start position must always be at the front bottom left of the cube.

```
{
  "name": "ft1",
  "rednet": "left",
  "remoteMonitor": "m1",
  "tank": "ic2:iridium_tank_1"
}
```
