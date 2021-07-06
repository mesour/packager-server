# Turtle

Automatic mining turtle program for Computercraft (CC:Tweaked)

- Turtle automatically place torches, refuel, get new torches, killing mobs in front of turtle, removing lava and much more

![Manager](../img/turtle-locations.png)

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
- Storage side is when standing in front of a chest

```
{
  "name": "t1",
  "rednet": "right",
  "start": "-36, 26, 5",
  "end": "-45, 18, 8",
  "storage": "-36, 21, 5",
  "torchStorage": "-36, 19, 5",
  "storageSide": "east"
}
```

## First start

Before first start your turtle run:

```
startup setup
```

- It will find lava bucket at any position in turtle inventory and refuel
- It will equip item from slot `16`

## Usage

For start turtle simply restart it and startup will load automatically

### Reset position

If you start old turtle for new location you must reset it:
```
startup reset
```

- This will remove .settings file from turtle filesystem

### Remote monitoring

For remote monitoring can use [manager - turtle](https://github.com/mesour/packager-server/blob/master/docs/en/manager.md#plugin-turtle)


### Show current state

For show current states run:
```
startup state
```

It will show something like:

```
Row: 0
Floor: 0
Fuel: 25629/100000
Need refuel: no
Full inventory: no
```
