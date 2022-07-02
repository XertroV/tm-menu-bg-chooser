void Main() {
    while (true) {
        SetMenuBgImages();
        yield();
    }
}

dictionary@ okayTimeOfDays =
    { {'Morning.png', true}
    , {'Day.png', true}
    , {'Evening.png', true}
    , {'Night.jpg', true}
};

CGameManialinkFrame@ menuBgFrame;

bool WillCrashTheGame(const string &in tod) {
    return !okayTimeOfDays.Exists(tod);
}

void SetMenuBgImages() {
    if (!Setting_Enabled) return;
    while (!GI::InMainMenu()) yield();

    auto mc = GI::GetMenuCustom();
    auto layers = mc.UILayers;

    string timeOfDay = MenuBgNames[Setting_BackgroundChoice];

    for (uint i = 0; i < layers.Length; i++) {
        auto layer = layers[i];
        if (!layer.IsVisible) continue;
        // this is the ControlId for the frame that holds the 4 bg quads
        auto bgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global"));
        if (bgFrame !is null) {
            // print("uiLayer: " + layer.IdName + ", bgFrame: " + bgFrame.IdName);
            auto cs = bgFrame.Controls;
            for (uint j = 0; j < cs.Length; j++) {
                auto quad = cast<CGameManialinkQuad@>(cs[j]);
                if (quad is null) continue;
                if (WillCrashTheGame(timeOfDay)) {
                    warn("timeOfDay var will crash the game! value=" + timeOfDay);
                    break;
                }
                if (!quad.ImageUrl.EndsWith("Background_" + timeOfDay) || (useCustomImage && quad.ImageUrl != customImageURL)) {
                    // print("uiLayer: " + layer.IdName + ", bgFrame: " + bgFrame.IdName);
                    // print(quad.ImageUrl);
                    // quad.ImageUrl = "file://Media/Manialinks/Nadeo/TMNext/Menus/MainBackgrounds/Background_" + timeOfDay;  // this seems to work, but I guess using the below function is preferred.
                    if (!useCustomImage) {
                        quad.ChangeImageUrl("file://Media/Manialinks/Nadeo/TMNext/Menus/MainBackgrounds/Background_" + timeOfDay);
                    } else {
                        quad.ChangeImageUrl(customImageURL);
                    }
                }
            }
        }
    }
}

enum NadeoMenuBackground {
    Morning = 0,
    Day,
    Evening,
    Night
}

string[] MenuBgNames = { 'Morning.png', 'Day.png', 'Evening.png', 'Night.jpg' };

[Setting category="General" name="Enabled?" description="Restart the game after disabling to return to normal."]
bool Setting_Enabled = true;

[Setting category="General" name="Menu bg time of day"]
NadeoMenuBackground Setting_BackgroundChoice = NadeoMenuBackground::Morning;

[Setting hidden]
bool useCustomImage = false;

[Setting hidden]
string customImageURL = "https://i.imgur.com/cysV8Fn.png";

string imageURLTextBox = customImageURL;

[SettingsTab name="Custom Image"]
void RenderCustomImageSettingsTab() {
    UI::Text("\\$f80Warning\\$z: A wrong image URL can result a game crash. Be careful!");
    useCustomImage = UI::Checkbox("Use custom image", useCustomImage);
    if (useCustomImage) {
        bool pressedEnter = false;
        imageURLTextBox = UI::InputText("Image URL", imageURLTextBox, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
        if (pressedEnter || UI::Button("Apply")) {
            customImageURL = imageURLTextBox;
        }
    }
}