# Turtle

Automatic turtle program for Computercraft 1.6+

## Requirements

1. IndustrialCraft 2 (IC2)
2. Computercraft (CC:Tweaked)
3. Need created [GPS Cluster](https://github.com/mesour/packager-server/blob/master/docs/en/gps.md) in game

Tested on Minecraft 1.12.2

## Installation

1. Install package `turtle`
2. Run `mv turtle-config.json config.json` to move config
3. Run `edit config.json` and save your current configuration
4. Restart turtle (`ctrl + R`)

## Configuration

- All configurations are **required**.
- Start position must always be at the bottom left of the cube.

```
{
  "name": "t1",
  "start": "-36, 26, 5",
  "end": "-45, 18, 8",
  "storage": "-36, 21, 5",
  "storageSide": "east"
}
```

## Usage

### Show current state

For show current states run:
```
run-turtle state
```
It will show something like:
```
Row: 0
Floor: 0
Fuel: 25629/100000
Need refuel: no
Full inventory: no
```

### Reset position

For reset position to start run:
```
run-turtle reset
```
