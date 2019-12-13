# Packager

## Usable packages

- `electroMeter` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/electroMeter.md)
- `energyStorage`
- `energyStorageGrid` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/energyStorageGrid.md)
- `fluidTank` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/fluidTank.md)
- `generatorGrid` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/generatorGrid.md)
- `manager`
- `monitor` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/monitor.md)
- `nuclearReactor` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/reactor.md)
- `reactorMonitor` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/reactorMonitor.md)
- `turbine` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/turbine.md)
- `turtle` - [usage](https://github.com/mesour/packager-server/blob/master/docs/en/turtle.md)

## Client installation

```
wget https://raw.githubusercontent.com/mesour/packager-server/master/generated/packager.lua
```

## Usage

Init `packager.json` file, for example for package`reactorMonitor`.
It will create configuration file `packager.json` with required package.
```
packager init reactorMonitor
```

For download latest file for your project from packager server run this command:
```
packager
```

For upgrade to the latest version use this command:
```
packager self-upgrade
```

### Client configuration

In this example is required `monitor` package.

```
{
  "required": {
    "monitor": "*"
  }
}
```

## Server installation

Download latest installer with:

```
wget https://raw.githubusercontent.com/mesour/packager-server/master/generated/packager-installer.lua
```

For upgrade to the latest version use this command:
```
packager-installer self-upgrade
```

Replace `<REPOSITORY>` to your `user/repository` from you Github URL and run _(for update use same command.)_:

```
packager-installer <REPOSITORY>
```

Example with `mesour/packager-server` repository:

```
packager-installer mesour/packager-server
```

### Server configration

Default "packager-server.json" for configurate monigor package:
```
{
  "monitor": {
    "library": [
      "Monitor",
      "MonitorControl",
      "RednetClient",
      "listeners/MonitorTouchListener",
      "FileLoader"
    ],
    "startup": "run-monitor",
    "bin": ["run-event-listener"],
    "config": ["monitor-config"]
  },

  ...
}
```