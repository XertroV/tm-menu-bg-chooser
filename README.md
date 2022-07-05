# Trackmania Menu Bg Chooser

This let's you choose the main menu background. You can choose from:

* A custom time of day (morning, day, evening, or night).
* A custom png, jpg, or webm file (via URL)
* TMX monthly backgrounds (either the current month or a random month)

To return to normal, select "Disabled" in settings and then restart Trackmania (sorry, it's a lot more work to avoid this).

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
