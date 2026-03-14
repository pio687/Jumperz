# Jumperz 🐸

A PICO-8 platformer where you play as a froggie on a mission — jump, swim, and crawl through underground caverns, mushroom forests, tree platforms, and a secret space level to rescue your friends.

Current build found at https://pio687.github.io/Jumperz/jumperz.html

## Concept

Your bunny friends are scattered across a strange and layered world. Explore the ground level, diving into ponds to discover hidden underwater caves, or building enough swim momentum to launch yourself off the top of the map and into space. Each zone has its own physics — sand slows you down and sinks you, water lets you float and stroke upward, and space sends you drifting with the momentum you built below. Find all your friends to win.

## Development Approach

Building a vertical slice first — getting all core movement, zone physics, and world structure working across the ground level before expanding into full underground and space sequences.

## Learning Disclaimer

This is my second PICO-8 game and I'm still very much learning. Core platformer structure was built following the Nerdy Teachers Platformer Setup playlist (https://www.youtube.com/watch?v=q6c6DvGK4lg&list=PLyhkEEoUjSQtUiSOu-N4BIrHBFtLNjkyE). I used Claude (Sonnet 4.6) as a "Senior Dev"-style mentor for debugging and creative iteration. The frog character sprites were designed by my niece, who also inspired the whole project. Inspired by and dedicated to my niece, who drew the character sprites.

## Controls

- **Arrow Keys** - Move
- **Z** - Jump / Swim stroke
- **X** - (coming soon)

## Current Status

### Implemented
- Full player physics: gravity, friction, acceleration, boost
- Zone-based physics: normal ground, water (low gravity, swim strokes), sand (slow + sink), space (momentum-based)
- Horizontal map wrapping at ground level
- Multi-zone vertical world: sky, ground, underground/pond, space
- Space accessed by building swim momentum and launching off the top of the map
- Camera system with per-zone clamping (prevents zones from bleeding into each other visually)
- Tile flag collision system (floor, wall, water, sand)
- NPC spawning from flagged map tiles
- Bunny NPCs with animated sprites
- Multiple ground-level environments (mushroom forest, tree platforms, pond)
- Hidden cave accessible by sinking to the bottom of the starting pond
- Bounce physics for space blocks, clouds, and gold eyed mushrooms
- Basic sound effects

### In Development
- Friends to rescue (collectibles)
- HUD showing rescue progress
- Enemies and enemy collision
- Stomp mechanic
- Win condition

### Next Up
- More map areas and environments
- Improved and expanded sprites
- Sound effects and music

## Post-Vertical Slice Features

### World Expansion
- Full underground cave network
- Space zone with unique traversal
- Secret areas and shortcuts

### Collectibles & Progression
- Rescue all friends to trigger win condition
- Collectible tracking via HUD
- Hidden friends in hard-to-reach zones

### Combat
- Stomp enemies Mario-style

### Polish
- Zone-specific music and ambience
- Particle effects
- Improved animations
