# Quick Start Guide

## Running the Game

1. Open Godot 4.5
2. Import/Open this project
3. Press F5 or click the Play button
4. The main menu will appear

## Testing Each Component

### Test 1: Main Menu
- Should see "RHYTHM HELL" title
- Click "Start Game" to begin

### Test 2: Intro Rhythm Sequence
- 4 arrow keys appear at bottom (D, F, J, K)
- Notes fall from top
- Press D, F, J, K keys to hit notes
- After ~20 notes, speed will suddenly increase dramatically
- You'll likely fail (this is intentional!)
- Screen fades to black
- Jumpscare appears (placeholder sprite currently)
- Title card: "RHYTHM HELL"
- Automatically transitions to maze level

### Test 3: Maze Level
- You spawn at bottom-left (green square)
- Monster spawns at top-right (red square)
- Colored chests are scattered in the maze
- Use Arrow Keys to move
- Monster will chase you after 3 seconds

### Test 4: Lure System
- Press Space/Enter with mouse over a walkable tile
- Monster will move to that location for 60 seconds
- Timer shows in top-left
- Warning appears when 10 seconds remain

### Test 5: Chest Interaction
- Walk into a colored chest
- Rhythm challenge starts
- Complete the challenge (hit notes)
- On success: Chest unlocks, diary entry appears
- On failure: Jumpscare, level restarts

### Test 6: Diary System
- After completing a chest challenge
- A diary entry panel appears
- Read the lore
- Click "Close" to continue playing

## Known Issues / Needs Work

1. **No Art Assets**: Currently using colored rectangles as placeholders
   - Need: Monster sprite, Player sprite, Chest sprites
   - Need: Better note visuals
   
2. **No Audio**: Silent game currently
   - Need: Scream sound for jumpscare
   - Need: Music for rhythm challenges
   - Need: Hit/miss sound effects
   - Need: Ambient maze sounds

3. **Monster Pathfinding**: Monster doesn't use proper pathfinding yet
   - Currently just moves toward player in straight line
   - Need to implement A* pathfinding through maze

4. **Note Visuals**: Need to properly display arrow sprites for notes
   - The Arrows.webp is in the art folder but needs proper integration

5. **Camera**: Camera doesn't follow player in maze
   - Should add smooth camera following

## Quick Fixes Needed

1. **Add Camera Follow**:
   ```gdscript
   # In maze_level.gd _process():
   $Camera2D.global_position = player.global_position
   ```

2. **Fix Note Sprites**:
   - The falling_keys.tscn needs to use proper arrow textures
   - Currently just uses placeholder

3. **Add Sound**:
   - Import audio files
   - Assign to AudioStreamPlayer nodes

## Testing Checklist

- [ ] Main menu loads
- [ ] Start button works
- [ ] Intro rhythm game spawns notes
- [ ] Can hit notes with DFJK keys
- [ ] Speed increases after time
- [ ] Jumpscare triggers
- [ ] Title card shows
- [ ] Maze generates
- [ ] Player can move with arrows
- [ ] Monster chases player
- [ ] Can place lures with Space
- [ ] Lure timer counts down
- [ ] Warning shows at 10 seconds
- [ ] Can interact with chests
- [ ] Rhythm challenge starts at chest
- [ ] Can complete challenge
- [ ] Diary appears on success
- [ ] Jumpscare on failure
- [ ] Level progresses when all keys collected

## Debug Tips

If something doesn't work:

1. **Check Console (F4)**: Look for errors
2. **Scene Tree**: Make sure all nodes are properly connected
3. **Signals**: Verify signals are connected in the inspector
4. **Scene Paths**: Ensure all scene paths are correct (res://...)

## Next Steps

1. Create or import art assets
2. Add audio files
3. Improve monster AI with proper pathfinding
4. Add camera follow
5. Polish UI elements
6. Add more juice (particles, screen shake, etc.)
7. Balance difficulty
8. Test extensively

Enjoy building your horror rhythm game!
