# Trackmania Menu Bg Chooser

This let's you choose the main menu background. You can choose from:

* A custom time of day (morning, day, evening, or night).
* A custom png, jpg, or webm file (via URL).
* TMX monthly backgrounds (the current month, a random month, or your choice).

To return to normal, select "Disabled" in settings.

If you want more control over menu reflections, search for [Menu Background Reflections](https://openplanet.dev/plugin/menu-bg-refls) in the plugin manager.

License: Public Domain

Authors: XertroV, Greep

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-menu-bg-chooser](https://github.com/XertroV/tm-menu-bg-chooser)

GL HF

### Notes

- `ComponentProfilePlayerInfo_frame-global`
  - Player profile page (world map background)
    - BG: `file://Media/Manialinks/Nadeo/TMNext/Menus/PageProfile/UI_profile_background_map_gradients.png` -- child 0 (quad)
    - `ComponentProfilePlayerInfo_quad-lights` (`file://Media/Manialinks/Nadeo/TMNext/Menus/PageProfile/UI_profile_background_map_lights.png`) -- fake lights that 'shine' on the player's car
    - `ComponentProfilePlayerInfo_frame-world` (frame holding 3x quads that draw land/sea outlines)

Media\ManiaApps\Nadeo\TMNext\TrackMania\MainMenu.Script.txt

- club page (activities)
  - main club page bg: `quad-page-background`
  - admin bg: `quad-page-background`
  - example of custom bg: `https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/background/17/61cb74f2dc8e4.png?updateTimestamp=1640723706.png`
  - default bg: `file://Media/Manialinks/Nadeo/TMNext/Menus/PageClub/UI_club_background_default.dds`




```
[0=>"file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Dawn.png", 1=>"file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Midday.png", 2=>"file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Sunset.png", 3=>"file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Night.png"]
```


- `HomeBackground_quad-overflow-active` -- overflow bg for main menu in ultrawide
  - mainframe.0.0.0.1.1
- `HomeBackground_quad-stadium-active` -- bg for main menu
  - mainframe.0.0.0.2.2
  - also `HomeBackground_quad-overflow-old`
    - mainframe.0.0.0.2.1

- `HomeBackground_camera-scene` -- presumably the 3d scene
  - mainframe.0.0.0.2.3


- `HomeBackground_frame-global` -- bg frame for new menu




### `HomeBackground_quad-stadium-active`

- set width to 430 for ultrawide (calc dynamically from Draw::)
- KeepRatio
  - Inactive, stretch according to W/H
  - fit, within smallest dims
  - clip, make bigger and clip top/bottom when too large

- Hide new menu bg (allows bg customization)
- Hide new menu driver
