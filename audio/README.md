# Audio Files

Place your audio files in this directory for the game to use them.

## Required Audio Files

### Music (OGG format recommended)
- `intro_music.ogg` - Background music for the intro rhythm game
- `maze_music.ogg` - Ambient music while navigating the maze
- `rhythm_music.ogg` - Music for rhythm challenges at chests

### Sound Effects
- `scream.ogg` - Jumpscare scream sound
- `note_hit.ogg` - Sound when hitting a note
- `note_miss.ogg` - Sound when missing a note
- `note_perfect.ogg` - Sound for perfect timing
- `lure_place.ogg` - Sound when placing a lure
- `chest_open.ogg` - Sound when opening a chest

## How to Add Audio

1. Export/download your audio files in OGG Vorbis format (recommended for Godot)
2. Place them in this `/audio` folder
3. The game will automatically detect and use them

## If You Don't Have Audio Files

The game will run without audio files - it won't crash. The music manager checks if files exist before trying to play them.

## Finding Free Audio

### Free Music Sites:
- [Incompetech](https://incompetech.com/) - Royalty-free music
- [FreePD](https://freepd.com/) - Public domain music
- [Purple Planet](https://www.purple-planet.com/) - Free music

### Free Sound Effects:
- [Freesound.org](https://freesound.org/) - Creative Commons sounds
- [Zapsplat](https://www.zapsplat.com/) - Free sound effects
- [Sonniss Game Audio GDC Bundle](https://sonniss.com/gameaudiogdc) - Professional sounds

## Converting to OGG

If you have MP3 or WAV files, you can convert them to OGG using:
- [Audacity](https://www.audacityteam.org/) (free audio editor)
- [FFmpeg](https://ffmpeg.org/) command line tool
- Online converters like [Online-Convert.com](https://audio.online-convert.com/convert-to-ogg)

### Example FFmpeg command:
```bash
ffmpeg -i input.mp3 -c:a libvorbis -q:a 5 output.ogg
```

## Audio Settings

Music and sound effects can be adjusted in the game manager script. The game uses:
- **Master Volume**: 1.0 (100%)
- **Music Volume**: 0.7 (70%)
- **SFX Volume**: 1.0 (100%)

You can adjust these in [game_manager.gd](../scripts/game_manager.gd) if needed.
