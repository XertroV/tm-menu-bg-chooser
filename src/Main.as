/* Notes:

- Once a bg is added it is cached in: `C:\ProgramData\TrackMania\Cache`
  That means the game won't crash on load if a resource disappears.

  */

void Main() {
    startnew(CoroMain);
}

void CoroMain() {
    startnew(CheckAndCacheCustomUrl);
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
    if (!PluginIsEnabled()) return;
    while (!GI::InMainMenu()) yield();

    auto mc = GI::GetMenuCustom();
    auto layers = mc.UILayers;

    for (uint i = 0; i < layers.Length; i++) {
        auto layer = layers[i];
        if (!layer.IsVisible) continue;
        // this is the ControlId for the frame that holds the 4 bg quads
        auto bgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global"));
        if (bgFrame !is null) {
            auto mainFrame = layer.LocalPage.MainFrame;
            auto frameGlobal = cast<CGameManialinkFrame@>(mainFrame.GetFirstChild("frame-global"));
            auto cameraVehicle = cast<CGameManialinkCamera@>(mainFrame.GetFirstChild("camera-vehicle"));

            // print("uiLayer: " + layer.IdName + ", bgFrame: " + bgFrame.IdName);
            auto cs = bgFrame.Controls;
            CGameManialinkQuad@[] quads = {};
            for (uint j = 0; j < cs.Length; j++) {
                auto quad = cast<CGameManialinkQuad@>(cs[j]);
                if (quad is null) continue;
                SetQuad(quad);
                quads.InsertLast(quad);
            }
            if (quads.Length == 4) {
                // trace('Calling: PlaneReflectEnable0');
                // print('' + bgFrame.Control.Scene.Id.GetName());
                // auto painter = GI::GetTmApp().Resources.PainterSetting;
                // print('' + painter.ScenesFids.Length);
                for (uint k = 0; k < 1; k++) {
                    GI::GetMenuSceneManager().PlaneReflectEnable1(MwId(k), 0.0f, quads[0], quads[1], quads[2], quads[3], 1.0f);
                    GI::GetMenuSceneManager().PlaneReflectRefresh();
                }
            }
            if (frameGlobal !is null) {
                if (cameraVehicle !is null) {
                    cameraVehicle.Visible = !Setting_HideCar;
                    // cameraVehicle.Hide();
                } else {
                    // print("null camera vehicle");
                }
            }
        }
    }
}



void SetQuad(CGameManialinkQuad@ quad) {
    if (Setting_Mode == BgMode::SetTimeOfDay) {
        SetQuadTimeOfDay(quad);
    } else if (Setting_Mode == BgMode::TMX) {
        SetQuadTmx(quad);
    } else if (Setting_Mode == BgMode::CustomUrl) {
        SetQuadCustom(quad);
    }
}


void SetQuadTimeOfDay(CGameManialinkQuad@ quad) {
    string timeOfDay = MenuBgNames[Setting_BackgroundChoice];
    if (WillCrashTheGame(timeOfDay)) {
        warn("timeOfDay var will crash the game! value=" + timeOfDay);
    } else if (!quad.ImageUrl.EndsWith("Background_" + timeOfDay)) {
        // print("uiLayer: " + layer.IdName + ", bgFrame: " + bgFrame.IdName);
        // print(quad.ImageUrl);
        // quad.ImageUrl = "file://Media/Manialinks/Nadeo/TMNext/Menus/MainBackgrounds/Background_" + timeOfDay;  // this seems to work, but I guess using the below function is preferred.
        quad.ChangeImageUrl("file://Media/Manialinks/Nadeo/TMNext/Menus/MainBackgrounds/Background_" + timeOfDay);
    }
}
void SetQuadTmx(CGameManialinkQuad@ quad) {}
void SetQuadCustom(CGameManialinkQuad@ quad) {
    string url = customImageURL;
    if (Setting_CheckedCurrentCustomImgUrl || UrlOkayToShowAsBg(url)) {
        if (quad.ImageUrl != url) {
            quad.ChangeImageUrl(url);
        }
    }
}
// void SetQuad(CGameManialinkQuad@ quad) {



// [Setting category="General" name="Enabled?" description="Restart the game after disabling to return to normal."]
// bool Setting_Enabled = true;

// [SettingsTab name="Custom Image"]
// void RenderCustomImageSettingsTab() {
//     UI::Text("\\$f80Warning\\$z: A wrong image URL can result a game crash. Be careful!");
//     useCustomImage = UI::Checkbox("Use custom image", useCustomImage);
//     if (useCustomImage) {
//         bool pressedEnter = false;
//         imageURLTextBox = UI::InputText("Image URL", imageURLTextBox, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
//         if (pressedEnter || UI::Button("Apply")) {
//             customImageURL = imageURLTextBox;
//         }
//     }
// }
