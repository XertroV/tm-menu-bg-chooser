/* Notes:

- Once a bg is added via URL it is cached in: `C:\ProgramData\TrackMania\Cache`
  That means the game won't crash on load if a resource disappears.

  */

UI::Font@ fontLarger;
UI::Font@ fontLargerBold;

void Main() {
    // we do stuff through coros so settings have a chance to load
    startnew(CoroMain);
    @fontLarger = UI::LoadFont("DroidSans.ttf", 18.0f);
    @fontLargerBold = UI::LoadFont("DroidSans-Bold.ttf", 18.0f);
}

void OnSettingsChanged() {
    if (TmxBgIsAPastMonth())
        LoadCurrTmxData();
}

void CoroMain() {
    tmxCurrUrl = InitTmxUrlAndData();
    startnew(CheckAndCacheCustomUrl);
    startnew(LoadCurrTmxData);
    yield();
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

// in ranked/royal it seems to be: Night, Midday, Dawn, Sunset
// mainmenu.script has: Night, Day, Morning, Evening when it calls `PlaneReflectEnable`

CGameManialinkFrame@ menuBgFrame;

bool WillCrashTheGame(const string &in tod) {
    return !okayTimeOfDays.Exists(tod);
}

void SetMenuBgImages(bool ignoreDisabled = false, bool ignoreVisibility = false) {
    if (!PluginIsEnabled() && !ignoreDisabled) return;
    while (!GI::InMainMenu()) yield();

    auto mc = GI::GetMenuCustom();
    auto layers = mc.UILayers;

    // can always skip the first 7 or so layers (they are visible but don't have anything relevant)
    for (uint i = 7; i < layers.Length; i++) {
        auto layer = layers[i];

        if (!layer.IsVisible && !ignoreVisibility) continue;
        // #frame-quad only exists on ranked/royal menu screens (I think) -- this test might need updating in the future
        bool isRanked = layer.LocalPage.GetFirstChild("frame-squad") !is null;

        // this is the ControlId for the frame that holds the 4 bg quads
        auto bgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global"));
        // note: could probably get quads directly via ids like: ComponentMainBackground_quad-morning

        string cameraVehicleId = isRanked ? "camera-vehicles" : "camera-vehicle";
        bool carAndReflShouldHide = PluginIsEnabled() && ((Setting_HideCar && !isRanked) || (Setting_HideCarOnRanked && isRanked));

        // main bg updating logic
        if (bgFrame !is null) {
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
            for (uint j = 0; j < cs.Length; j++) {
                auto quad = cast<CGameManialinkQuad@>(cs[j]);
                if (quad is null) continue;
                SetQuad(j, quad);
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
