/* Notes:
- Once a bg is added via URL it is cached in: `C:\ProgramData\TrackMania\Cache`
  That means the game won't crash on load if a resource disappears.
*/

UI::Font@ fontLarger;
UI::Font@ fontLargerBold;

string MainMenuOverlayPatched;
wstring MMOPw;

void Main() {
    // we do stuff through coros so settings have a chance to load
    @fontLarger = UI::LoadFont("DroidSans.ttf", 18.0f);
    @fontLargerBold = UI::LoadFont("DroidSans-Bold.ttf", 18.0f);
    startnew(CoroMain);
    // startnew(CheckNewBgNames);
}

// void CheckNewBgNames() {
//     string[] newBgs = {
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Spring_Morning.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Spring_Day.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Spring_Sunset.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Spring_Night.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Summer_Morning.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Summer_Day.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Summer_Sunset.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Summer_Night.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Fall_Morning.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Fall_Day.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Fall_Sunset.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Fall_Night.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Winter_Morning.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Winter_Day.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Winter_Sunset.dds",
//         "file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/MenuBackground_Winter_Night.dds",
//     };
//     for (uint i = 0; i < newBgs.Length; i++) {
//         auto item = newBgs[i];
//         GameFileExists(item);
//         GameFileExists(item.Replace("MenuBackground", "CubeMap"));
//     }
//     GameFileExists("file://Media/Manialinks/Nadeo/TMNext/Menus/HomeBackground/PlaneReflect.dds");
// }

// void SetUpNewBg() {
//     // get patched bg script
//     IO::File mmBgScript(IO::FromDataFolder('Plugins/menu-bg-chooser-dev/main-menu-displaymode.Script.txt'), IO::FileMode::Read);
//     MainMenuOverlayPatched = mmBgScript.ReadToEnd();
//     MMOPw = wstring(MainMenuOverlayPatched);
//     print('got patched mm script of length: ' + MainMenuOverlayPatched.Length);
//     sleep(1000);
//     SetTypicallyHiddenMenuBgs();
// }

void OnSettingsChanged() {
    if (TmxBgIsAPastMonth())
        LoadCurrTmxData();
}

void CoroMain() {
    sleep(100);  // wait for settings etc
    while (!PluginIsEnabled()) {  // just do nothing indefinitely if we're disabled on load.
        yield();
    }
    startnew(SetBLSManifest);
    startnew(GreepList::UpdateList);
    tmxCurrUrl = InitTmxUrlAndData();
    startnew(CheckAndCacheCustomUrl);
    startnew(LoadCurrTmxData);
    yield();
    while (true) {
        SetMenuBgImages();
        yield();
    }
}

string[] defaultTodQuadsOrder = {"Night", "Day", "Morning", "Evening"};

// in ranked/royal it seems to be: Night, Midday, Dawn, Sunset
// mainmenu.script has: Night, Day, Morning, Evening when it calls `PlaneReflectEnable`

CGameManialinkFrame@ menuBgFrame;

void SetMenuBgImages(bool ignoreDisabled = false, bool ignoreVisibility = false) {
    if (!PluginIsEnabled() && !ignoreDisabled) return;
    while (!GI::InMainMenu()) yield();

    auto mc = GI::GetMenuCustom();
    auto layers = mc.UILayers;

    // can always skip the first 7 or so layers (they are visible but don't have anything relevant)
    for (uint i = 7; i < layers.Length; i++) {
        auto layer = layers[i];

        if (!layer.IsVisible && !ignoreVisibility) continue;
        // #frame-squad only exists on ranked/royal menu screens (I think) -- this test might need updating in the future
        bool isRanked = layer.LocalPage.GetFirstChild("frame-squad") !is null;

        // this is the ControlId for the frame that holds the 4 bg quads
        auto bgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global"));
        // note: could probably get quads directly via ids like: ComponentMainBackground_quad-morning
        auto homePageBgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("HomeBackground_frame-global"));
        bool isOnHomePage = homePageBgFrame !is null;

        // string cameraVehicleId = isRanked ? "camera-vehicles" : "camera-vehicle";
        // if (isOnHomePage) cameraVehicleId = "HomeBackground_camera-scene";
        // bool carAndReflShouldHide = PluginIsEnabled() && ((Setting_HideCar && !isRanked) || (Setting_HideCarOnRanked && isRanked));

        // main bg updating logic
        if (bgFrame !is null) {
            // auto mainFrame = layer.LocalPage.MainFrame;
            // auto cameraVehicle = cast<CGameManialinkCamera@>(layer.LocalPage.GetFirstChild(cameraVehicleId));
            // if (cameraVehicle !is null) {
            //     // cameraVehicle.Visible = !carAndReflShouldHide;
            //     // cameraVehicle.RelativeScale = carAndReflShouldHide ? 0.001 : 1.;
            //     // cameraVehicle.Control.Clean();
            // }

            // bail early for ranked/royal bgs if not enabled, but after we show/hide the car
            if (isRanked && !Setting_EnableBgRanked) continue;
            if (isRanked && Setting_Mode == BgMode::Disabled) continue;  // these menus reset themselves so nothing to do here if we're disabled.

            // print("uiLayer: " + layer.IdName + ", bgFrame: " + bgFrame.IdName);
            auto cs = bgFrame.Controls;
            for (uint j = 0; j < cs.Length; j++) {
                auto quad = cast<CGameManialinkQuad@>(cs[j]);
                if (quad is null) continue;
                SetQuad(j, quad);
            }
        }

        if (isOnHomePage) {
            auto bg1 = layer.LocalPage.GetFirstChild("HomeBackground_quad-stadium-active");
            auto bg2 = layer.LocalPage.GetFirstChild("HomeBackground_quad-stadium-old");
            auto cl1 = layer.LocalPage.GetFirstChild("HomeBackground_quad-clouds-active");
            auto cl2 = layer.LocalPage.GetFirstChild("HomeBackground_quad-clouds-old");
            auto of1 = cast<CGameManialinkQuad@>(layer.LocalPage.GetFirstChild("HomeBackground_quad-overflow-active"));
            auto of2 = cast<CGameManialinkQuad@>(layer.LocalPage.GetFirstChild("HomeBackground_quad-overflow-old"));
            if (bg1 !is null) SetNewMenuBg(bg1);
            if (bg2 !is null) SetNewMenuBg(bg2);
            if (cl1 !is null) SetNewMenuBg(cl1.Parent);
            if (cl2 !is null) SetNewMenuBg(cl2.Parent);
            if (of1 !is null) SetQuad(3, of1);
            if (of2 !is null) SetQuad(3, of2);
            // we would set lighting here if we were going to include it
        }
    }
}


void SetNewMenuBg(CGameManialinkControl@ control) {
    control.Visible = !S_HideNewMenuBG;
    if (S_StretchMenuForUltrawide) {
        control.Size = vec2(float(Draw::GetWidth()) * 180. / Draw::GetHeight(), 180);
        // trace('set size to: ' + control.Size.x);
        // trace('set size to: ' + (float(Draw::GetWidth()) * 180. / Draw::GetHeight()));
    } else {
        control.Size = vec2(320, 180);
        // trace('set size to default: ' + control.Size.x);
    }
}


string[] MainBgQuadNames =
{ "ComponentMainBackground_quad-night"
, "ComponentMainBackground_quad-day"
, "ComponentMainBackground_quad-morning"
, "ComponentMainBackground_quad-evening"
};

// string KNOWN_GOOD_MM_SCRIPT_ML_PAGE_HASH = "7f243e5799f2df67edc0de4c7503767a";

// void SetTypicallyHiddenMenuBgs() {
//     if (!PluginIsEnabled()) return;
//     while (!GI::InMainMenu()) yield();

//     auto mc = GI::GetMenuCustom();
//     while (mc is null) {
//         yield();
//         @mc = GI::GetMenuCustom();
//     }
//     auto layers = mc.UILayers;
//     while (layers.Length < 25) {
//         trace('layers.Length: ' + layers.Length);
//         yield();
//         // layers = mc.UILayers;
//     }

//     for (uint i = 7; i < layers.Length; i++) {
//         auto layer = layers[i];
//         // if (!layer.IsVisible) continue;

//         // if we find the homebackground_frame
//         if (layer.LocalPage.GetFirstChild("HomeBackground_frame-global") !is null) {
//             auto mlPageHash = Hash::MD5(layer.ManialinkPageUtf8);
//             print('mlPageHash: ' + mlPageHash);
//             if (layer.ManialinkPageUtf8.StartsWith("<!-- patched to enable HomeBackground -->"))
//                 continue;
//             if (mlPageHash != KNOWN_GOOD_MM_SCRIPT_ML_PAGE_HASH) {
//                 warn('main menu script hash has changed -- aborting.');
//                 continue;
//             }
//             layer.ManialinkPage = MMOPw;
//         }

//         if (layer.IsVisible && layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global") !is null) {
//             for (uint qNum = 0; qNum < MainBgQuadNames.Length; qNum++) {
//                 auto quad = cast<CGameManialinkQuad@>(layer.LocalPage.GetFirstChild(MainBgQuadNames[qNum]));
//                 if (quad is null) continue;
//                 quad.ImageUrl = '';
//                 // quad.Opacity = 0.0;
//             }
//         }
//     }
// }

void SetQuad(uint ix, CGameManialinkQuad@ quad) {
    if (Setting_Mode == BgMode::SetTimeOfDay) {
        SetQuadTimeOfDay(quad);
    } else if (Setting_Mode == BgMode::NoBackground) {
        SetQuadTimeOfDay(quad, 'No Background');
    } else if (Setting_Mode == BgMode::BetterLoadingScreens) {
        SetQuadBLS(quad);
    } else if (Setting_Mode == BgMode::TMX) {
        SetQuadTmx(quad);
    } else if (Setting_Mode == BgMode::GreepList) {
        SetQuadGreepList(quad);
    } else if (Setting_Mode == BgMode::CustomUrl) {
        SetQuadCustom(quad);
    } else if (Setting_Mode == BgMode::Disabled) {
        SetQuadDisabled(ix, quad);
    }
    quad.Visible = true;
}

/*
file://Media/Manialinks/Nadeo/TMNext/Menus/PageGarage/Garage_background.dds

file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Midday.dds
file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Night.dds
file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Dawn.dds
file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/Royal_Sunset.dds

file://Media/Manialinks/Nadeo/TMNext/Menus/PageMatchmakingMain/Background/S_Sunset.dds (also {G_,B_} dawn, night, midday)

auto size = Fids::GetFake('Titles/Trackmania/' + vfile).ByteSize;
if (size > 0) {
    UI::Text("File Loaded (" + size + "B)");
} else {
    UI::Text("File doesn't exist");
}
*/


bool GameFileExists(const string &in path) {
    if (path == "") return false;
    auto theFile = Fids::GetFake(path.Replace('file://', 'Titles/Trackmania/'));
    if (theFile is null) {
        warn('null GetFake? ' + path);
        return false;
    }
    return theFile.ByteSize > 0;
}


uint lastWarn = 0;

// include the suffix for timeOfDay
string GetDefaultBgUrl(const string &in timeOfDay) {
    if (!MenuBgFiles.Exists(timeOfDay)) {
        if (lastWarn + 5000 < Time::Now) {
            lastWarn = Time::Now;
            warn('Time of day does not exist: \'' + timeOfDay + '\'');
            string msg = "Time of day not found: '" + timeOfDay + "'. This should not happen, please msg @XertroV on Openplanet discord.";
            UI::ShowNotification('Menu BG Chooser', msg, vec4(0.9, 0.6, 0.0, 0.5), 5000);
        }
        return string(MenuBgFiles['Morning']);
    }

    string filePath = string(MenuBgFiles[timeOfDay]);
    if (filePath != '' && !GameFileExists(filePath)) {
        if (lastWarn + 5000 < Time::Now) {
            lastWarn = Time::Now;
            warn('Could not find game file that should exist: \'' + filePath + '\'');
            string msg = "Missing file: " + filePath + ". Menu BG Chooser is exiting to avoid a crash. This should not happen, please msg @XertroV on Openplanet discord.";
            UI::ShowNotification('Menu BG Chooser', msg, vec4(0.9, 0.6, 0.0, 0.5), 5000);
            warn('Aborting to avoid crash: game file does not exist: ' + filePath);
        }
        return "";
    }
    return filePath;
}

float setBgNTimes = 0;

void CheckAndSetQuadImage(CGameManialinkQuad@ quad, const string &in url) {
    if (quad.ImageUrl != url) {
        trace('Set quad ' + quad.Id.GetName() + ' image: ' + url + ' (was: ' + quad.ImageUrl + ')');
        quad.ChangeImageUrl(url);
        setBgNTimes++;
        if (Time::Now > 1000 && float(Time::Now) / setBgNTimes > 0.01 && setBgNTimes > 100) {
            UI::ShowNotification("Menu BG Chooser", "The BG has been set many many more times than one would expect. Something is probably wrong. Aborting to avoid breaking stuff.");
            throw("set the bg too many times");
        }
    }
}

void SetQuadTimeOfDay(CGameManialinkQuad@ quad, string _timeOfDay = '') {
    string timeOfDay = _timeOfDay.Length > 0 ? _timeOfDay : MenuBgNames[Setting_BackgroundChoice];
    string url = GetDefaultBgUrl(timeOfDay);
    CheckAndSetQuadImage(quad, url);
}

const uint AugustFirst2020 = 1596260880;
const uint SecondsInAMonth = 2629800;
const uint tmxDateBuffer = 2 * 86400; // 2 days
uint maxMonth;

string[] tmxAllMonthYrs = {};

string InitTmxUrlAndData() {
    uint now = Time::Stamp;
    uint dt = now - AugustFirst2020; // seconds since first map bg
    // dt -= tmxDateBuffer; // set time 2 days in the past to give enough time for bg to be made
    dt = dt - (dt % SecondsInAMonth);
    uint monthNumber = dt / SecondsInAMonth; // the current month
    // trace('monthNumber:' + monthNumber);
    maxMonth = monthNumber; // track max month for randomized bg
    auto mlsh = GI::GetMenuManialinkScriptHandler();
    for (uint m = 0; m <= maxMonth; m++) {
        string yrMo = MonthNumberToMonthYrStr(m);
        tmxAllMonthYrs.InsertLast(yrMo);
        // trace('inserted tmxAllMonthYrs: ' + yrMo);
        // startnew(CoroCacheUrl, CacheUrl(MakeTmxBgUrlYrMonth(yrMo)));
    }
    return RefreshTmxData();
}

// theMonth = 0 is August 2020; theMonth = 12 is August 2021; etc
uint[] MonthNumberToMonthYr(uint theMonth) {
    uint calMonth = ((theMonth + 7) % 12) + 1; // 01 through 12
    uint yr = 20 + (theMonth + 7 - calMonth + 1) / 12;
    return {calMonth, yr};
}

string MonthNumberToMonthYrStr(uint theMonth) {
    auto moYr = MonthNumberToMonthYr(theMonth);
    return '' + moYr[1] + "-" + Text::Format("%02d", moYr[0]);
}

string lastSetTmxBgYrMo;

string RefreshTmxData() {
    if (!Setting_TmxRandom && !Setting_TmxCurrent) {
        lastSetTmxBgYrMo = Setting_TmxPastMonth;
        return MakeTmxBgUrlYrMonth(Setting_TmxPastMonth);
    }
    int theMonth;
    if (!Setting_TmxRandom) {
        theMonth = maxMonth;
    } else {
        theMonth = Math::Rand(0, maxMonth + 1);
    }
    Setting_TmxPastMonth = MonthNumberToMonthYrStr(theMonth);
    lastSetTmxBgYrMo = Setting_TmxPastMonth;
    return MakeTmxBgUrlYrMonth(Setting_TmxPastMonth);
}

string MakeTmxBgUrl(uint yr, uint month) {
    string _tmxMonthYr = '' + yr + "-" + Text::Format("%02d", month);
    return MakeTmxBgUrlYrMonth(_tmxMonthYr);
}

string MakeTmxBgUrlYrMonth(const string &in _tmxMonthYr) {
    return "https://images.mania-exchange.com/next/backgrounds/" + _tmxMonthYr + "/bg.jpg";
}

string tmxCurrUrl;

void LoadCurrTmxData() {
    tmxCurrUrl = RefreshTmxData();
}

void SetQuadTmx(CGameManialinkQuad@ quad) {
    CheckAndSetQuadImage(quad, tmxCurrUrl);
}

int randBLSIx = -1;
void SetQuadBLS(CGameManialinkQuad@ quad) {
    if (!IsBLSInitialized()) return;
    if (randBLSIx < 0)
        randBLSIx = Math::Rand(0, blsManifest.Length);
    CheckAndSetQuadImage(quad, blsManifest[randBLSIx]);
}

void SetQuadGreepList(CGameManialinkQuad@ quad) {
    if (!GreepList::GotList()) return;
    CheckAndSetQuadImage(quad, GreepList::GetImageUrl());
}

void SetQuadCustom(CGameManialinkQuad@ quad) {
    string url = Setting_CustomImageURL;
    if (Setting_CheckedCurrentCustomImgUrl || UrlOkayToShowAsBg(url)) {
        CheckAndSetQuadImage(quad, url);
    }
}

void SetQuadDisabled(uint ix, CGameManialinkQuad@ quad) {
    string url = GetDefaultBgUrl(defaultTodQuadsOrder[ix]);
    CheckAndSetQuadImage(quad, url);
}
