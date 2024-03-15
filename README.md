<div align="center">
  <img src="/media/logo.png" alt="Self-Driving Car project" height="455" width="250">
  <div style="padding-top: 10px;">
    <h1 style="margin: 0;">Self-Driving Car</h1>
    <p style="margin: 0;">Canvas painted project written in Flutter/Dart without 3rd-party libraries.</p>
  </div>
</div>

## Preview

Project contains two game modes:

* Infinity road with endless traffic spawn
* Virtual world with editor builder

<table>
<tr>
  <td align="center">Infinity road</td>
  <td align="center">Virtual world</td>
</tr>
<tr>
  <td align="center"><img src="/media/infinity_road.gif" alt="Infinity road" height="480"></td>
  <td align="center"><img src="/media/virtual_world.gif" alt="Virtual world" height="480"></td>
</tr>
</table>

## Project features

* 🛠️ Configurable world with custom settings
* 🕹 Manual steering controls
* 📈 Custom Neural network
* 🧰 Toolbar with various actions
* 🚗 20+ different car models
* 🗺️ Minimap
* 🗂️ Load/Save/Import world actions
* 🏡 Pseudo-generated buildings & trees
* 🧭 Shortest path finding algorithms (Dijkstra + more coming soon)

### Build editor

In build editor you are enable you to edit:

- 🛣 Road builder supported by spacial graph
- 🛑 Stop sign
- ⚠️️ Yield sign
- 🚦 Traffic lights system
- 🚸 Crossing marking
- 🅿️ Parking marking
- 🏎️ Start marking position
- 🏁 Target marking position

<table>
<tr>
  <td align="center"><img src="/media/build_editor.mp4" alt="Build editor" width="688"></td>
</tr>
</table>

### Import from Open Street map

Parser will extract the following data:

* 🏠 Buildings
* 🛣 Roads️
* 🌊 Water areas
* 🌲 Tree areas
* 🦦 Rivers
* 🌾 All land field types

<table>
<tr>
  <td align="center"><img src="/media/real_world.mp4" alt="Real world example" width="688"></td>
</tr>
</table>

#### Fetching the data

Open Street map data can be fetch via [overpass turbo](https://overpass-turbo.eu/) with the
following query:

```
[out:json];
(
  // Routes
  way['highway']
  ['highway' !~ 'pedestrian']
  ['highway' !~ 'footway']
  ['highway' !~ 'cycleway']
  ['highway' !~ 'path']
  ['highway' !~ 'service']
  ['highway' !~ 'corridor']
  ['highway' !~ 'track']
  ['highway' !~ 'steps']
  ['highway' !~ 'raceway']
  ['highway' !~ 'bridleway']
  ['highway' !~ 'proposed']
  ['highway' !~ 'construction']
  ['highway' !~ 'elevator']
  ['highway' !~ 'bus_guideway']
  ['access' !~ 'private']
  ['access' !~ 'no']
  ({{bbox}});
  
  // Buildings
  way['building']({{bbox}});
  
  // Lands
  way["natural"]({{bbox}});
  way["landuse"]({{bbox}});
  relation["natural"]({{bbox}});
  relation["landuse"]({{bbox}});
  
  // Rivers
  way["waterway"]({{bbox}});
  
  // Waterbodies
  node["natural"="water"]({{bbox}});
  way["natural"="water"]({{bbox}});
  relation["natural"="water"]({{bbox}});
);

out body;	// Full body, not just summary
>;
out skel;	// Remove some extra details
```

## Supported platforms

* 🖥️ Desktop (macOS, Linux, Windows)
* 📱 Mobile (iOS, Android)
* 🔗 Web

## Special Thank You

Special thanks to [Radu Mariescu-Istodor](https://github.com/gniziemazity) for:

* 🤩 amazing course
  on [Self-driving car - No libraries - JavaScript course](https://www.youtube.com/watch?v=NkI9ia2cLhc&list=PLB0Tybl0UNfYoJE7ZwsBQoDIG4YN9ptyY),
* 💫 great way of explaining custom neural networks,
* 🎸 super content that he provides and
* 🚀 source of inspiration.

Thank you! 🙏