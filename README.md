# HexEngine
A Hex tile engine that uses SpriteKit and is written in Swift.

The code tries to be as *swifty* as possible: i.e. use Structs instead of Classes where possible, tries to be as safe as possible, tries to adhere to Swift naming conventions for stuff and uses higher order functions.

The project is built for macOS, but as far as I can tell, apart from "scrollwheel" support and "mouseover" there is very little here that is macOS dependant. I.e. it should be easy to port to iOS/ipadOS/tvOS (watchOS might not be relevant).

Uses art assets from [Kenney](https://www.kenney.nl)

# Features
## What is working
* HexGrid operations: choose/convert between Cube and Axial coordinates, find neighbours, diagonals, lines, hex within range;
* A map is generated using perlin noise and a fixed seed (so it's always the same);
* Basic map actions: pan around the map ("drag"), select tiles ("click"/"tap"), zoom-in/zoom-out ("pinch", scrollwheel);
* Convert between "screen space" and HexMap coordinates;
* Select a unit, displays a path for the unit if one is set;
* Issue a "move" command for a unit;
* Path finding for units (takes inaccessible terrain and terrain costs into account);
* "Next turn" button processes actions for all units, i.e. moves along path if one is set.

## What is missing
Where to begin?
* Units should have variable abilities, not just move;
* Typical stuff on a hex grid: cities, buildings, improvements;
* Build/create stuff over time;
* Players;
* ...

## Why is this taking so long?
Adding features to the hexmap and world (i.e. the simulation) is not trivial. However, the effort required there is eclipsed by how much time UI work takes. Because that is where state becomes messy: UI state versus simulation state, feedback to users, handle different input modes. It also tends to be where the tight coupling starts to creep in. Last couple of weeks have been 90% UI...

## So, what can I do with it now?
Well, it is off course not necesarry to make a 4x game using the HexMap. You could use it for something smaller. The basic scaffold is ViewController -> HexMapScene -> HexMapController -> World -> HexMap.
To simplify, you can strip out all reference to UI/GUI and UnitController. You then have a basic map that you can interact with.

# Contact details
Need to contact me? Drop an email at maarten@thedreamweb.eu or twitter at [@maarten_engels](https://twitter.com/maarten_engels)

# References
* The HexMap data structure and calculations are based on this excellent explanation of HexMaps: https://www.redblobgames.com/grids/hexagons/ 
* Assets used are from Kenney's packages: (Hexagon Pack)[https://www.kenney.nl/assets/hexagon-pack] and (Animal pack)[https://www.kenney.nl/assets/animal-pac]. Please consider (a donation)[https://kenney.itch.io/kenney-donation] and/or buy his (complete assets packs)[https://www.kenney.nl/store]