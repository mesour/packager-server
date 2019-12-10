# Packager

## Server installation

```
wget https://raw.githubusercontent.com/mesour/packager-server/master/instalation/packager-installer.lua
```

and run

```
packager-installer
```

_For update use same command._


## Local installation

```
wget https://raw.githubusercontent.com/mesour/packager-server/master/packager/packager.lua
```

Sample `packager.json` file:
```
wget https://raw.githubusercontent.com/mesour/packager-server/master/packager/packager.json
```

## Usage

For download latest file for your project from packager server run this command:
```
packager
```

For upgrade to the latest version use this command:
```
packager self-upgrade
```

## Configuration

## Server configration

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

## Client configuration
```
{
  "required": {
    "monitor": "*"
  }
}
```

## Usable packages

- `manager`
- `monitor`
- `energyStorage`
- `energyStorageGrid`
- `generatorGrid`
- `electroMeter`
- `fluidTank`
- `nuclearReactor`
- `turbine`
- `reactorMonitor`
