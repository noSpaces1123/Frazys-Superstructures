Version = "1.6.3"

ChangelogYOffset = 0

Changelog = Version ..

[[
 Changelog:

    Turrets:
    - New: Bullet sprites
    - New: Prime turrets (only in hot weather)

    Hooligans:
    - New: Hooligans will now try to run away when the player is near a checkpoint
    - New: Hooligans permanently stick to a sticky platform upon contact

    OTHER:
    - New: Added voice acting for the player
    - New: New posters
    - Change: Windows render distance increased from 10 to 14 meters
    - Fixed: Foggy level shader overlay incorrectly centered on Windows
    - Fixed: Scaling differences on Windows and iOS
    - Fixed: Checkpoints not destroying turrets
    
1.6 -> 1.6.2 Changelog:
    
    UI:
    - UI changes
    
    Camera:
    - New: Camera rotation based on velocity (togglable in settings)
    
    Platforms:
    - New: Added random color darkening for variation
    - New: Sticky platform stickiness can be negated by holding space
    - New: Random platform scale factor for each level (correlating to platform density)
    - New: Background beams between platforms for the sake of graphical depth (no gameplay effects)
    
    Turrets:
    - New: Velocity multiplier when destroying turrets
    - New: Screen shake when destroying turrets
    - New: 7% of turrets will be have personality trait peaceful or angry
    - Change: Decreased velocity multiplier when destroying turrets
    - Removed: Bouncing off turrets when destroying them
    
    Weather:
    - New: Wind whooshing sound for hot levels
    - New: Foggy weather
    - New: Added menu option to turn off weather screen darkening (to increase visibility in rainy levels)
    - New: Weather is guaranteed clear until level 10
    - Change: Hot weather chance when starting a new level decreased from 33% to 25%
    - Change: Decreased wind event strength
    - Change: Adjusted weather chances (clear 42%, rainy 32%, hot 21%, foggy 5%)
    - Removed: Higher zoom in foggy levels
    - Fixed: Rainy level rain effect being at random line widths
    - Fixed: Rainy level rain sounds looping awkwardly
    - Fixed: Added continuity with wind events across game instances
    
    Bubs:
    - New: Added Marvin the Magic Weatherman, Wygore the Wise, and Globu the Navigator
    - Change: Decreased Bub detection radius from 75 to 30 meters

    Hooligans:
    - New: 1 in 5 hooligans will run away if you're moving significantly faster than them
    
    Super jump:
    - New: Added SFX to communicate when a super jump can be used and when your bar is at max

    Bug fixes:
    - Fixed: Hit and stay buttons for blackjack appearing in the main menu
    - Fixed: Hooligans moving around and attacking the player when in the main menu
    - Fixed: Mass of turrets spawning on level 50

    OTHER:
    - New: Quit button in the menu
    - New: Zen mode
    - Change: Changed game icon to resemble a hooligan
    - Change: Decreased input buffer time from 0.17 seconds to 0.08 seconds
    - Removed: Cursor readings (hovering over turrets to see data)


1.5 Changelog:

    Turrets:
    - New: Push turrets

    Weather:
    - New: Added wind events to rainy levels


1.4 -> 1.4.3.3 Changelog:

    Levels:
    - Change: Descreased jump pad spawn density
    - Change: Generation (in terms of platform types) now work using Simplex noise
    - New: Added weather (affects gameplay)

    Timer:
    - Fixed: Timer still counting up when dead

    Minimap:
    - Change: Made waypoints easier to remove
    - New: Displays "Game paused." at the bottom of the screen viewing the minimap
    - New: Turrets and Hooligans now must be discovered to appear on the minimap

    Turrets and hooligans:
    - Fixed: Targeting indicator (line from threat to player) not rendering when the threat has not been discovered

    Sticky platforms:
    - Fixed: Not being able to super-jump off of sticky platforms

    QoL:
    - New: Self-destruct with [B]

    Performance:
    - Enhanced: Significant performance enhancement

    Analytics upgrade path:
    - Change: Scale bar changed to be vertical rather than horizontal
    - Change: Added weather info to level 1 of analytics

    Weather:
    - Change: Brightened rainy levels
    - Change: Changed all weather types to be equally likely
    - New: Added dialogue to make it extra clear that checkpoints don't work in rainy levels

    Hooligans:
    - Fixed: Hooligans clipping through the player with no effect

    Bug fixes:
    - Fixed: Descension level hooligan spawning not triggering
    - Fixed: Upgrades not taking effect when moving to the next level
    - Fixed: Random crashing
    - Fixed: Hooligans and turrets not being cleared and regenerated each level
    - Fixed: Random crashing (for the most part)
    - Fixed: Crash enemy.lua:71 (getting confused about missing data)

    OTHER:
    - New: Added game icon
    - Fixed: Fading in animation on game startup trailing into entering the game
    - Change: Changed game font from Geo to DM Mono for better readability (especially in differentiating between '1' and '7')
    - Removed: Level regeneration with [R] when paused



Changelogs of versions prior are logged within their respective versions. They can be found in the designated Google Drive for Frazy's Superstructures.
]]