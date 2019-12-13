# How to use GPS

How to use GPS in Computercraft

## Usage

### GPS Server

A GPS server is a computer with a rednet wifi modem that when asked will tell passing
computers / turtles where it is its location in X , Y , Z .This combined with the distance
from the sever allows a computer / turtle to locate where it is. the turtle must have
this information from four different severs so it can Trilateration its location.
This group of turtles is called a GPS cluster.

### GPS Cluster

The way the severs are positioned has an affect on how accurate / reliable your system is.
In Picture one you can see that i have computers In a pattern that pattern allows the position
to be found in X Y and Z if you have four computers in a line along Y It would not be able to
identify its height or its X position. You must have computers on different locations.
My recommendation is to use the below configuration I use it all the time ant it is very
accurate affective and compact.

![GPS Cluster image](https://github.com/mesour/packager-server/blob/master/docs/img/gps.jpg)

After setting up four computers in this pattern at the top of the world.Set up a startup
file on each computer with the continence as the picture shown.

Put this in a file named startup:

```
shell.run("gps", "host", x, y, z)
```

You should now be able to check GPS coordinated from any where within a **370** Meter radius of the cluster.

_Inspired by [this topic](http://www.computercraft.info/forums2/index.php?/topic/3088-how-to-guide-gps-global-position-system/)._
