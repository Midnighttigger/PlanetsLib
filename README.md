[![Discord](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge)](https://discord.gg/VuVhYUBbWE)

# PlanetsLib

Code and graphics to help modders creating planets, moons and other systems, plus standardizations (to avoid proliferations of mods like [Surfaces Have Temperature](https://mods.factorio.com/mod/Surfaces-Have-Temperature)).

Breaking changes in this mod will be accompanied with bumps to a higher major version.

## API Reference

### Planet helpers

* `PlanetsLib:planet_extend(config)` - Defines a new planet. This includes a call to data:extend. Does not support `distance` or `orientation` - instead, contains `orbit` as listed below.
  * `config.orbit` - Object containing orbital parameters:
    * `parent` - Object containing `name` and `type` fields, corresponding to a parent at data.raw\[type]\[name].
    * `distance` - Number: orbital distance from parent
    * `orientation` - Number: orbital angle from parent (0-1). Note that orientation is absolute, not relative to the parent's orientation.
    * `sprite` - Object: Sprite to use for the orbit.
  * `config.sprite_only` - Boolean (optional): If true, the prototype will be removed in data-final-fixes and replaced by a sprite on the starmap. This is used for data.raw["space-location"].star internally.
  * Any other valid planet prototype fields
  * Note:
    * Can accept a single config object or an array of configs
    * Returns array of created planet prototypes
* `PlanetsLib:borrow_music(source_planet, target_planet)` - Clones music tracks from an existing planet to a new one.
* `PlanetsLib:set_default_import_location(item_name, planet)` - Sets the default import location for an item on a planet.

### Cargo Drop System

The library provides automatic cargo drop restriction functionality. To implement:

1. Define a technology with name pattern: `[planet-name]-cargo-drops`
2. Use the provided helper functions:
   * `PlanetsLib.technology_icons_planet_cargo_drops`
   * `PlanetsLib.technology_effect_cargo_drops`

Players will be unable to drop cargo (excluding players and construction robots) to that planet before researching the technology.

### Moon Support

Special functionality for implementing moons:

* `PlanetsLib.technology_icons_moon` - Creates standardized icons for moon discovery
* A new Factoriopedia row below planets. Add to this by including `subgroup=satellites` on the planet.

### Surface Temperature

The library implements a temperature surface condition for planetary surfaces. Default temperatures (in Kelvin):

| Surface         | Temperature |
| --------------- | ----------- |
| Nauvis          | 288K        |
| Vulcanus        | 332K        |
| Fulgora         | 314K        |
| Gleba           | 298K        |
| Aquilo          | 258K        |
| Space Platforms | 268K        |
| Default         | 288K        |

These values are spaced to allow modded planets to fit between them.

## Credits

This library is a community project and will grow over time — feel free to contribute via pull requests on [Github](https://github.com/danielmartin0/PlanetsLib).

Contributors:

* [Tserup](https://mods.factorio.com/user/Tserup) - Art
* [thesixthroc](https://mods.factorio.com/user/thesixthroc)
* [notnotmelon](https://mods.factorio.com/user/notnotmelon)

Special credit goes to [MidnightTigger](https://mods.factorio.com/user/Midnighttigger) for inspiring the structure of this mod with [MidnightTigger's Library](https://mods.factorio.com/mod/MT-lib).