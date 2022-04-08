# godot-dynamic-subtitles
An addon for easily implementing subtitles using the built-in audio system in the Godot Engine.

For more helpful information and details refer to [the wiki](https://github.com/QueenOfSquiggles/godot-dynamic-subtitles/wiki)

# Features
## Subtitle System
* Dialogue Subtitles
  * Subtitles stack and snap to bottom of screen. 
* 3D spatial subtitles
  * Subtitles reposition to track the 3D node's position

## Helpful tool:
There is a tool script for automatically converting an existing scene tree to one compatible with the subtitles system. Every AudioStreamPlayer node is given a SubtitleData child node which is what handles the passing of subtitle data


## Translations!
Because all subtitles use Godot's built-in `Label`, they are all automatically translated using Godot's built-in [Translation & Localization System](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html)

## Customization
Every SubtitleData node has an option to have an overriding `Theme` asset to affect the subtitle. They also allow for padding subtitle duration, changing what spatial position is used for the playing of audio. etc...
More details [here at the Wiki page for the SubtitleData node](https://github.com/QueenOfSquiggles/godot-dynamic-subtitles/wiki/SubtitleData-Node)
