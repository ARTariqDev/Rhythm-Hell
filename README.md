# Rhythm Hell

A 2D horror rhythm game where you must escape from a maze while being chased by a monster (your wife?) and complete rhythm challenges to collect keys.

## Game Concept

### Intro Sequence
- The game starts with a rhythm game using 4 keys: D, F, J, K
- Notes fall from top to bottom
- After a period of time, the speed suddenly increases by 100x
- You inevitably fail (or even if you succeed, you lose anyway)
- Screen fades to black...
- A monster jumpscares you
- Title card appears: "RHYTHM HELL"
- The monster is revealed to be your wife... at least you think so?

### Main Gameplay
Each level you are trapped in a randomly generated maze:

- **The Monster**: Starts at the top right corner of the maze
- **The Player**: Starts at the bottom left
- **The Goal**: Reach color-coded chests scattered throughout the maze to obtain keys
- **The Challenge**: Each chest requires completing a rhythm game song
- **The Consequence**: If you fail, you get jumpscared and restart

### Lure System
You have 3 "lures" that can be placed in the maze:
- Each lure keeps the monster occupied for 1 minute
- When a lure runs out, you are alerted
- You can pause your rhythm game to lure the monster elsewhere
- You have 10 seconds after a lure expires before the monster reaches you

### Progression
- Complete rhythm challenges at chests to collect keys
- After each challenge, you unlock a diary "scrap" revealing lore
- Each level has more chests and more keys to collect
- Chest placement and the maze itself are randomly generated

## Controls

### Maze Navigation
- **Arrow Keys**: Move your character
- **Space/Enter**: Place a lure at mouse position
- **ESC**: Pause rhythm game (during challenges)

### Rhythm Game
- **D, F, J, K**: Hit the corresponding notes as they reach the bottom

## Game Systems

### Rhythm Manager
- Spawns notes in a pre-defined sequence
- Detects note hits with accuracy (Perfect, Good, Okay)
- Tracks combo and misses
- Gradually increases speed before ramping to 100x

### Maze Generator
- Uses recursive backtracking to generate mazes
- Maze size increases with each level
- Randomly places chests throughout the maze
- Ensures all areas are reachable

### Monster AI
- Chases the player through the maze
- Can be lured to specific positions
- Resumes chase after lure expires
- Catches player if they get too close

### Lure System
- 3 lures per level
- Each lasts 60 seconds
- Visual timer shows remaining time
- Warning appears at 10 seconds remaining

### Diary System
- 10 diary entries total
- Unlock one entry per chest completed
- Tells the story of your entrapment
- Reveals the relationship with the monster

## Development Setup

1. Open the project in Godot 4.5
2. The main scene is `main_menu.tscn`
3. Run the project to start from the main menu

## File Structure

```
rythm-hell/
├── main_menu.tscn          # Main menu scene
├── intro_level.tscn        # Opening rhythm sequence
├── levels/
│   └── maze_level.tscn     # Main maze gameplay scene
├── objects/
│   ├── key_listner.tscn    # Rhythm game input detector
│   ├── chest.tscn          # Collectible chest
│   └── falling_keys.tscn   # Falling note
├── scripts/
│   ├── game_manager.gd     # Global game state
│   ├── main_menu.gd        # Main menu logic
│   ├── intro_level.gd      # Intro sequence controller
│   ├── rhythm_manager.gd   # Rhythm game logic
│   ├── falling_keys.gd     # Note behavior
│   ├── maze_generator.gd   # Procedural maze generation
│   ├── maze_level.gd       # Main gameplay controller
│   ├── player.gd           # Player movement
│   ├── monster.gd          # Monster AI
│   ├── chest.gd            # Chest interaction
│   ├── lure_system.gd      # Lure mechanics
│   ├── diary_system.gd     # Lore/story system
│   ├── jumpscare_layer.gd  # Jumpscare effect
│   └── title_card_layer.gd # Title card display

```

## Assets Needed

To complete the game, you'll need:

1. **Monster Sprite**: A creepy 2D sprite for the monster/wife character
2. **Player Sprite**: A simple character sprite
3. **Note Sprites**: Arrow sprites for the rhythm game (already has Arrows.webp)
4. **Chest Sprites**: Chest sprites in different colors
5. **Sound Effects**:
   - Scream for jumpscare
   - Note hit sounds
   - Background music for rhythm challenges
   - Ambient maze music
6. **UI Elements**: Better styled UI elements

## TODO / Future Improvements

- [ ] Add proper pathfinding (A*) for monster AI
- [ ] Create animated sprites for monster and player
- [ ] Add sound effects and music
- [ ] Implement difficulty settings
- [ ] Add more visual polish (particles, screen shake, etc.)
- [ ] Create more varied rhythm patterns
- [ ] Add achievements/unlockables
- [ ] Implement high score system
- [ ] Add more jumpscare variations
- [ ] Create cutscenes between levels

## Credits

Created with Godot Engine 4.5
# Rhythm-Hell
