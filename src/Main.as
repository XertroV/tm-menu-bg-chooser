/* Notes:

- Once a bg is added via URL it is cached in: `C:\ProgramData\TrackMania\Cache`
  That means the game won't crash on load if a resource disappears.

  */

void Main() {
    // we do stuff through coros so settings have a chance to load
    startnew(CoroMain);
    startnew(TestIntercept);
}

bool _SceneCreate(CMwStack &in stack) {
    print("_SceneCreate called with: " + stack.Index() + " / " + stack.Count());
    print("scene create called with: " + stack.CurrentWString());
    return true;
}

bool _SceneDestroy(CMwStack &in stack) {
    print("_SceneDestroy called with: " + stack.Index() + " / " + stack.Count());
    print("scene destroy called with: " + stack.CurrentId().GetName());
    return true;
}

// special variables used by _PlaneReflectEnable1
CGameMenuSceneScriptManager@ LastMenuSceneMgr;  // keep track of the instance used by maniascript
MwId LastBgSceneId = MwId(12345);
bool AllowPlaneReflectEnableCall = false;  // control whether the intercept function will send thru the call or not

// do not call directly
bool _PlaneReflectEnable1(CMwStack &in stack, CMwNod@ nod) {
    // print("_PlaneReflectEnable1 called with: " + stack.Index() + " / " + stack.Count());
    float angle = stack.CurrentFloat(); // angle -- unit seems like degrees mb; angle measured relative to camera horizontal, i think
    CGameManialinkQuad@ q4 = cast<CGameManialinkQuad>(stack.CurrentNod(1)); // bg time of day quad
    CGameManialinkQuad@ q3 = cast<CGameManialinkQuad>(stack.CurrentNod(2)); // bg time of day quad
    CGameManialinkQuad@ q2 = cast<CGameManialinkQuad>(stack.CurrentNod(3)); // bg time of day quad
    CGameManialinkQuad@ q1 = cast<CGameManialinkQuad>(stack.CurrentNod(4)); // bg time of day quad
    float opacity = stack.CurrentFloat(5); // set to like -3 to make reflection ~invisible. default is 0.63. -1 is still visible a bit. IDK what scale/units this is in.
    MwId sceneId = stack.CurrentId(6); // must be used with the correct MenuSceneMgr instance -- will not work with `GI::GetMenuSceneManager()`!
    // print("sceneId: " + sceneId.GetName()); // always #12345
    trace("_PlaneReflectEnable1 angle is: " + angle + " and opacity: " + opacity);
    if (AllowPlaneReflectEnableCall) {
        AllowPlaneReflectEnableCall = false;
        return true;
    } else {
        trace('_PlaneReflectEnable1 -- "fixing" parameters');
        AllowPlaneReflectEnableCall = true;
        @LastMenuSceneMgr = cast<CGameMenuSceneScriptManager>(nod);
        LastMenuSceneMgr.PlaneReflectEnable1(sceneId, Setting_BgReflectionOpacity, q1, q2, q3, q4, Setting_BgReflectionAngle);
        return false;
    }
}

// use this to call PlaneReflectEnable
void MenuSceneMgr_PlaneReflectEnable(MwId &in sceneId, float opacity, CGameManialinkQuad@ q1, CGameManialinkQuad@ q2, CGameManialinkQuad@ q3, CGameManialinkQuad@ q4, float angle) {
    if (LastMenuSceneMgr is null) return;
    AllowPlaneReflectEnableCall = true;
    LastMenuSceneMgr.PlaneReflectEnable1(sceneId, opacity, q1, q2, q3, q4, angle);
    LastMenuSceneMgr.PlaneReflectRefresh();
}

void UpdateAllBgReflections() {
    if (Setting_Mode == BgMode::Disabled) return;
    auto mc = GI::GetMenuCustom();
    auto layers = mc.UILayers;

    // can always skip the first 7 or so layers (they are visible but don't have anything relevant)
    for (uint i = 7; i < layers.Length; i++) {
        auto layer = layers[i];
        // this is the ControlId for the frame that holds the 4 bg quads
        auto bgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global"));
        if (bgFrame !is null) {
            auto cs = bgFrame.Controls;
            CGameManialinkQuad@[] quads = {};
            for (uint j = 0; j < cs.Length; j++) {
                auto quad = cast<CGameManialinkQuad@>(cs[j]);
                if (quad is null) continue;
                quads.InsertLast(quad);
            }
            if (quads.Length == 4) {
                MenuSceneMgr_PlaneReflectEnable(LastBgSceneId, Setting_BgReflectionOpacity, quads[3], quads[1], quads[0], quads[2], Setting_BgReflectionAngle);
            }
        }
    }
}

void OnSettingsChanged() {
    UpdateAllBgReflections();
}

void TestIntercept() {
    // Dev::InterceptProc("CGameMenuSceneScriptManager", "SceneCreate", _SceneCreate);
    // Dev::InterceptProc("CGameMenuSceneScriptManager", "SceneDestroy", _SceneDestroy);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "PlaneReflectEnable1", _PlaneReflectEnable1);
}

void CoroMain() {
    startnew(CheckAndCacheCustomUrl);
    startnew(CoroLoadCurrTmxData);
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

string[] defaultTodQuadsOrder = {"Night.jpg", "Day.png", "Morning.png", "Evening.png"};
// string[] defaultTodQuadsOrder = {"Morning.png", "Day.png", "Evening.png", "Night.jpg"};

// in ranked/royal it seems to be: Night, Midday, Dawn, Sunset
// mainmenu.script has: Night, Day, Morning, Evening when it calls `PlaneReflectEnable`

CGameManialinkFrame@ menuBgFrame;

bool WillCrashTheGame(const string &in tod) {
    return !okayTimeOfDays.Exists(tod);
}

void SetMenuBgImages() {
    // if (!PluginIsEnabled()) return;
    while (!GI::InMainMenu()) yield();

    auto mc = GI::GetMenuCustom();
    auto layers = mc.UILayers;

    // can always skip the first 7 or so layers (they are visible but don't have anything relevant)
    for (uint i = 7; i < layers.Length; i++) {
        auto layer = layers[i];

        if (!layer.IsVisible) continue;
        // #frame-quad only exists on ranked/royal menu screens (I think) -- this test might need updating in the future
        bool isRanked = layer.LocalPage.GetFirstChild("frame-squad") !is null;

        // this is the ControlId for the frame that holds the 4 bg quads
        auto bgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global"));
        // note: could probably get quads directly via ids like: ComponentMainBackground_quad-morning

        string cameraVehicleId = isRanked ? "camera-vehicles" : "camera-vehicle";
        bool carAndReflShouldHide = PluginIsEnabled() && ((Setting_HideCar && !isRanked) || (Setting_HideCarOnRanked && isRanked));

        // main bg updating logic
        if (bgFrame !is null) {
            /* debug dump declare:
                - 0 values: GI::GetTmApp().MenuManager.MenuCustom_CurrentManiaApp
                - 0 values: layer.LocalPage
                - 3 values: GI::GetTmApp().MenuManager.MenuCustom_CurrentManiaApp.ManiaPlanet
                - 3 values: GI::GetTmApp().ManiaPlanetScriptAPI (same as above?)
                - 23 values: GI::GetTmApp().UserManagerScript.Users[0]
                - 0 values: scriptHandler.ParentApp
                      auto scriptHandler = cast<CGameManiaAppTitleLayerScriptHandler>(layer.LocalPage.ScriptHandler);
                */
            // trace(GI::GetMenuManialinkScriptHandler().Dbg_DumpDeclareForVariables(GI::GetTmApp().Viewport.Overlays[3].UserData, false));
            // trace(cast<CGameMenuFrame>(cast<CControlFrame>(layer.LocalPage.MainFrame.Control).Parent.Parent.Parent.Parent).Id.GetName());
            // trace(GI::GetMenuManialinkScriptHandler().Dbg_DumpDeclareForVariables(cast<CGameMenuFrame>(cast<CControlFrame>(layer.LocalPage.MainFrame.Control).Parent.Parent.Parent.Parent), false));
            // sleep(150);

            // auto mainFrame = layer.LocalPage.MainFrame;
            auto cameraVehicle = cast<CGameManialinkCamera@>(layer.LocalPage.GetFirstChild(cameraVehicleId));
            if (cameraVehicle !is null) {
                cameraVehicle.Visible = !carAndReflShouldHide;
            }

            // bail early for ranked/royal bgs if not enabled, but after we show/hide the car
            if (isRanked && !Setting_EnableBgRanked) continue;
            if (isRanked && Setting_Mode == BgMode::Disabled) continue;  // these menus reset themselves so nothing to do here if we're disabled.

            // print("uiLayer: " + layer.IdName + ", bgFrame: " + bgFrame.IdName);
            auto cs = bgFrame.Controls;
            CGameManialinkQuad@[] quads = {};
            for (uint j = 0; j < cs.Length; j++) {
                auto quad = cast<CGameManialinkQuad@>(cs[j]);
                if (quad is null) continue;
                SetQuad(j, quad);
                quads.InsertLast(quad);
            }
            if (quads.Length == 4) {
                // trace('Calling: PlaneReflectEnable0');
                // print('' + bgFrame.Control.Scene.Id.GetName());
                // GI::GetMenuSceneManager().PlaneReflectEnable1(MwId(12345), 0.0f, quads[3], quads[1], quads[0], quads[2], 3.0f);
                // GI::GetMenuSceneManager().PlaneReflectRefresh();
            }
        }
    }
}



void SetQuad(uint ix, CGameManialinkQuad@ quad) {
    if (Setting_Mode == BgMode::SetTimeOfDay) {
        SetQuadTimeOfDay(quad);
    } else if (Setting_Mode == BgMode::TMX) {
        SetQuadTmx(quad);
    } else if (Setting_Mode == BgMode::CustomUrl) {
        SetQuadCustom(quad);
    } else if (Setting_Mode == BgMode::Disabled) {
        SetQuadDisabled(ix, quad);
    }
}

// include the suffix for timeOfDay
string GetDefaultBgUrl(const string &in timeOfDay) {
    if (WillCrashTheGame(timeOfDay)) {
        throw("timeOfDay var will crash the game! value=" + timeOfDay);
    }
    return "file://Media/Manialinks/Nadeo/TMNext/Menus/MainBackgrounds/Background_" + timeOfDay;
}

void CheckAndSetQuadImage(CGameManialinkQuad@ quad, const string &in url) {
    if (quad.ImageUrl != url) {
        trace('Set quad ' + quad.Id.GetName() + ' image: ' + url + ' (was: ' + quad.ImageUrl + ')');
        quad.ChangeImageUrl(url);
    }
}

void SetQuadTimeOfDay(CGameManialinkQuad@ quad) {
    string timeOfDay = MenuBgNames[Setting_BackgroundChoice];
    string url = GetDefaultBgUrl(timeOfDay);
    CheckAndSetQuadImage(quad, url);
}

const uint AugustFirst2020 = 1596260880;
const uint SecondsInAMonth = 2629800;
const uint tmxDateBuffer = 2 * 86400; // 2 days
uint maxMonth;
string tmxMonthYr;

string InitTmxUrlAndData() {
    uint now = Time::Stamp;
    uint dt = now - AugustFirst2020; // seconds since first map bg
    // dt -= tmxDateBuffer; // set time 2 days in the past to give enough time for bg to be made
    dt = dt - (dt % SecondsInAMonth);
    uint monthNumber = dt / SecondsInAMonth; // the current month
    trace('monthNumber:' + monthNumber);
    maxMonth = monthNumber; // track max month for randomized bg
    return RefreshTmxData();
}

string RefreshTmxData() {
    int theMonth;
    if (!Setting_TmxRandom) {
        theMonth = maxMonth;
    } else {
        theMonth = Math::Rand(0, maxMonth + 1);
    }
    uint calMonth = ((theMonth + 7) % 12) + 1; // 01 through 12
    trace('calMonth:' + calMonth);
    uint yr = 20 + (theMonth + 7 - calMonth + 1) / 12;
    return MakeTmxBgUrl(yr, calMonth);
}

string MakeTmxBgUrl(uint yr, uint month) {
    tmxMonthYr = '' + yr + "-" + Text::Format("%02d", month);
    return "https://images.mania-exchange.com/next/backgrounds/" + tmxMonthYr + "/bg.jpg";
}

string tmxCurrUrl = InitTmxUrlAndData();

void CoroLoadCurrTmxData() {
    tmxCurrUrl = RefreshTmxData();
}

void SetQuadTmx(CGameManialinkQuad@ quad) {
    CheckAndSetQuadImage(quad, tmxCurrUrl);
}

void SetQuadCustom(CGameManialinkQuad@ quad) {
    string url = customImageURL;
    if (Setting_CheckedCurrentCustomImgUrl || UrlOkayToShowAsBg(url)) {
        CheckAndSetQuadImage(quad, url);
    }
}

void SetQuadDisabled(uint ix, CGameManialinkQuad@ quad) {
    // this isn't triggered atm b/c we need a way to default all settings back that isn't just `&&IsPluginEnabled()` everywhere (well, we could do that but it's probs annoying and will lead to bugs)
    string url = GetDefaultBgUrl(defaultTodQuadsOrder[ix]);
    CheckAndSetQuadImage(quad, url);
}
