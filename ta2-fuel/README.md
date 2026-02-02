# ta2-fuel

Fuel and fuelstations system for Fivem :fuelpump:

## Dependencies

-   [ta2-core]https://github.com/tatituptech/TA2-CORE
-   [ta2-target]
-   [PolyZone]

## Exports 📡

|  Name   | Namespace |    Arguments    | Return |
| :-----: | :-------: | :-------------: | :----: |
| GetFuel |  Client   |     vehicle     | number |
| SetFuel |  Client   | vehicle, number |  void  |

_\* The exports can be use with the resource name (qb-fuel) or with LegacyFuel_

## Compatibility

This resource is fully compatible with TA2Core servers and it sustitutes the _[LegacyFuel](https://github.com/InZidiuZ/LegacyFuel)_, thanks to InZidiuZ for that amazing script that inspired us to make a new Fuel System script.

```lua
-- Will return the same
exports['ta2-fuel']:GetFuel(vehicle)
exports['LegacyFuel']:GetFuel(vehicle)
```

This will make it easier to change from _LegacyFuel_ to _ta2-fuel_.
