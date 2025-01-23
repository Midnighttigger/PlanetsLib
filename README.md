[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/danielmartin0/PlanetsLib)[![Discord](https://img.shields.io/badge/Discord-%235865F2.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/VuVhYUBbWE)

# PlanetsLib

Code, graphics and conventions to help modders creating planets, moons and other systems. This library is a community project and will grow over time. Contributors are welcome to open a [pull request](https://github.com/danielmartin0/PlanetsLib/pulls) on Github. For feature requests, please open an [issue](https://github.com/danielmartin0/PlanetsLib/issues).

## Credits

Contributors:

* [thesixthroc](https://mods.factorio.com/user/thesixthroc)
* [Tserup](https://mods.factorio.com/user/Tserup) (art)
* [Midnighttigger](https://mods.factorio.com/user/Midnighttigger)
* [notnotmelon](https://mods.factorio.com/user/notnotmelon)
* [MeteorSwarm](https://mods.factorio.com/user/MeteorSwarm)

## Notes for contributors

* We're currently publishing releases of this mod manually. In your pull requests, please list your changes in changelog.txt to be included in the next release. Please also update README.md to add sections for your new functionality (even with only 'Documentation pending') and add yourself to the contributors list.
* You must test your changes, ideally with multiple planet installed.
* Feel free to use the file `todo.md`.

## API Reference

### Planet definitions

Planet prototypes and space location prototypes can be defined using the following API. The 'distance' and 'orientation' of the prototypes will be calculated automatically from the orbit hierarchy, as will the layering of the sprites on the starmap.

* `PlanetsLib:extend(config)` — A wrapper/replacement for `data:extend`. Throws an error if passed `distance` or `orientation`. It instead takes the fields listed below.
    * `type` — `"planet"` or `"space-location"`
    * `orbit` — Object containing orbital parameters:
        * `parent` — Object containing `name` and `type` fields, corresponding to a parent at `data.raw[type][name]`. Planets in the original solar system should have an orbit with `type = "space-location"` and `name = "star"`.
        * `distance` — Number: orbital distance from parent
        * `orientation` — Number: orbital angle from parent (0-1). Note that orientation is absolute, not relative to the parent's orientation.
        * `sprite` — Object (optional): Sprite for the planet’s orbit, centered on its parent.
        * `eccentricity` — Number: Eccentricity of the orbit, default is 0 which is a circle.
        * `periapsis` — Number: Orientation at closest approach to the parent, mandatory when eccentricity is defined and not 0.
    * `sprite_only` — Boolean (optional): If true, this prototype will be removed in `data-final-fixes` and replaced by its sprites on the starmap (unless neither `starmap_icon`, `starmap_icons` nor an orbit sprite are defined, in which case nothing will show).
        * This is useful for constructing stars and other locations that should not have a space platform 'docking ring'.
    * `background_sprite` — Boolean (optional): If true, this prototype will be removed in `data-final-fixes` and replaced by its sprites on the starmap (unless neither `starmap_icon`, `starmap_icons` nor an orbit sprite are defined, in which case nothing will show).
        * This is useful for background sprites.
    * Other valid `planet` or `space-location` prototype fields
    * Further notes on `PlanetsLib:extend`:
        * Should not be called in `data-final-fixes`.
        * See [here](https://github.com/danielmartin0/Cerys-Moon-of-Fulgora/blob/main/prototypes/planet/planet.lua) or [here](https://github.com/danielmartin0/PlanetsLib/issues/12#issuecomment-2585484116) for usage examples.
* `PlanetsLib:update(config)` — The same as `PlanetsLib:extend`, except it updates a pre-existing planet or space location (identified by the passed `type` and `name` fields) using the parameters passed. If the `orbit` field is passed, the `distance` and `orientation` fields on the prototype will be updated appropriately. Should not be called in `data-final-fixes`.

### Planet Cargo Drops technology

The library provides automatic functionality to restrict cargo drops on your planet until a technology is researched. To implement:

* Use the helper function `PlanetsLib.cargo_drops_technology_base(planet, planet_technology_icon, planet_technology_icon_size)` to create a base technology prototype.
    * This will create a technology with name pattern: `planetslib-[planet-name]-cargo-drops`
    * PlanetsLib detects this technology by name. Players will be unable to drop cargo (excluding players and construction robots) to planets with that name before researching the technology.
    * Only the fields `type`, `name`, `localised_name`, `localised_description`, `effects`, `icons` will be defined, so you will need to add `unit` (or `research_trigger`) and prerequisites.
    * A locale entry for this technology is automatically generated, but you are free to override it.

### Support for moons

* `PlanetsLib.technology_icons_moon` — Icon to be used in moon discovery technologies.
* `subgroup=satellites` — A new Factoriopedia row for satellites (below the planets row).

### Description templates

Documentation pending.

### Surface conditions

PlanetsLib includes a wide variety of surface conditions, all of which are either hidden or disabled by default. To enable a surface condition, modders must add the following line to settings-updates.lua (using 'oxygen' as an example):

`data.raw["bool-setting"]["PlanetsLib-enable-oxygen"].forced_value = true`

#### Per-planet surface conditions

* `PlanetsLib.surface_conditions.restrict_to_surface(planet)`: Returns a surface condition restricting an entity to the given planet. Accepts both planet names and planet objects. This surface condition is almost completely hidden in the UI with the exception of messages like "X can't be crafted on this surface. The  is too low."

### Other helper functions

* `PlanetsLib.set_default_import_location(item_name, planet)` - Sets the default import location for an item on a planet.
* `PlanetsLib.borrow_music(source_planet, target_planet)` - Clones music tracks from `source_planet` to `target_planet`. Does not overwrite existing music for `target_planet`.

### Python helper scripts

* `lib/orbit_graphic_generator.py`: contains a Python script that generates orbit sprites. `generate_orbit(distance, output_file, mod_name)`, `distance` being the same as your orbital distance. After generating your sprite, the script will print a block of lua code that imports your sprite with proper scaling. Orbit sprites should be scaled at 0.25 to ensure that no pixels are visible, even on 4K displays.