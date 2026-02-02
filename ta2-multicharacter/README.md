# ta2-multicharacter
Multi Character Feature for TA2-Core Framework :people_holding_hands:

Added support for setting default number of characters per player per Rockstar license

# License

TA2Core Framework
Copyright (C) 2026 Terrance Tatituptech Ware

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>


## Dependencies
- [ta2-core]
- [ta2-spawn]- Spawn selector
- [ta2-apartments]- For giving the player a apartment after creating a character.
- [ta2-clothing]- For the character creation and saving outfits.
- [ta2-weathersync] - For adjusting the weather 

## Screenshots
![Character Selection](https://cdn.discordapp.com/attachments/934470871333105674/1014215694394589294/unknown.png)
![Character Registration](https://cdn.discordapp.com/attachments/934470871333105674/1014215687700488304/unknown.png)

## Features
- Ability to create up to 5 characters and delete any character.
- Ability to see character information during selection.

## Installation
### Manual
- Download the script and put it in the `[ta2]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure ta2-core
ensure ta2-multicharacter
ensure ta2-spawn
ensure ta2-apartments
ensure ta2-clothing
ensure ta2-weathersync
```
