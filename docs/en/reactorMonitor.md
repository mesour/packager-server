# Reactor monitor

Automatic program for display detailed info about nuclear reactor or fluid nuclear reactor.

- Clickable button ON / OFF is included on monitor (use by right clicking)
- Supports normal and fluid reactor are supported

![Fluid reactor monitor](https://github.com/mesour/packager-server/blob/master/docs/img/reactorMonitor_monitor.png)

![Normal reactor monitor](https://github.com/mesour/packager-server/blob/master/docs/img/reactorMonitor_monitor_normal.png)

![Fluid reactor error](https://github.com/mesour/packager-server/blob/master/docs/img/reactorMonitor_monitor_error.png)

![Reactor monitor](https://github.com/mesour/packager-server/blob/master/docs/img/reactorMonitor.png)

## Requirements

1. IndustrialCraft 2 (IC2)
2. Computercraft (CC:Tweaked)
3. Plethora
4. Need created [reactor](https://github.com/mesour/packager-server/blob/master/docs/en/reactor.md) in game

Tested on Minecraft 1.12.2

## Installation

1. Install package `reactor`
2. Run `mv reactor-monitor-config.json config.json` to move config
3. Run `edit config.json` and save your current configuration
4. Restart computer (`ctrl + R`)

## Configuration

- All configurations are **required**.
- `remoteMonitor` is name for [remote monitor](https://github.com/mesour/packager-server/blob/master/docs/en/monitor.md)
- `reactorName` is name of a remote [reactor](https://github.com/mesour/packager-server/blob/master/docs/en/reactor.md)
defined in reactor config.json

```
{
  "name": "rm1",
  "rednet": "left",
  "remoteMonitor": "m1",
  "reactorName": "r1"
}
```
