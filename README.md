# godot-dynamic-subtitles
An addon for easily implementing subtitles using the built-in audio system in the Godot Engine.

For more helpful information and details refer to [the wiki](https://github.com/QueenOfSquiggles/godot-dynamic-subtitles/wiki)


# Really fast install & go

If you already have some `AudioStreamPlayer` nodes in existing scene trees, it is super easy to get them all set up for subtitles.

1. Open the scene that contains the `AudioStreamPlayer` nodes that you want subtitles on
2. Go to Project -> Tools -> "Generate SubtitleData in Scene"
    * This will add a `SubtitleData` node as a child to all `AudioStreamPlayer` nodes in the scene tree
3. The subtitle text/id is automatically populated with the name of your `AudioStreamPlayer` node, feel free to go through and change them to whatever you like
    * If you want to tweak more settings, refer to the [SubtitleData Node](https://github.com/QueenOfSquiggles/godot-dynamic-subtitles/wiki/SubtitleData-Node) page for more information
4. Go to Project -> Tools -> "Attach Event Scripts in Scene"
    * This will attach a script to all `AudioStreamPlayer` nodes in your scene tree that do not otherwise have a script attached. These scripts will allow the subtitles to work event-driven which greatly reduces the processing time for inactive subtitles (to roughly 0ms)
5. Play your `AudioStreamPlayer` nodes as you normally would, and the subtitle with the subtitle text you set should display.

![tool scripts preview](https://user-images.githubusercontent.com/8940604/162343226-780322a6-8c79-4f97-bf31-ec1b2144b9b0.png)

***

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
