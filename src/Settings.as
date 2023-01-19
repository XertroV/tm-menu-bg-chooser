// BgMode values must exactly correspond to ModeNames indexes
enum BgMode {
    Disabled = 0,
    SetTimeOfDay,
    BetterLoadingScreens,
    TMX,
    GreepList,
    CustomUrl,
    NoBackground,
}

string[] ModeNames = { "Disabled"
, "Set Time of Day (and other TM BGs)"
, "Use 'Better Loading Screens' BGs"
, "Trackmania Exchange Monthly BGs"
, "Greep's List"
, "Custom BG (via URL)"
, "No Background"
};

[Setting hidden]
BgMode Setting_Mode = BgMode::SetTimeOfDay;

bool PluginIsEnabled() {
    return Setting_Mode != BgMode::Disabled;
}

[Setting hidden]
bool S_HideNewMenuBG = false;

[Setting hidden]
bool S_StretchMenuForUltrawide = false;

[Setting hidden]
bool S_DisableBlurredSidesOnHomePage = false;

// [Setting hidden]
// bool Setting_HideCar = false;

[Setting hidden]
bool Setting_EnableBgRanked = true;

// [Setting hidden]
// bool Setting_HideCarOnRanked = false;

[SettingsTab name="Menu Background"]
void RenderMenuBgSettings() {
    // UI::PushFont(fontLarger);
    UI::Text("Background Mode:");
    if (UI::BeginCombo("##menu-bg-mode", ModeNames[Setting_Mode])) {
        for (uint i = 0; i < ModeNames.Length; i++) {
            if (UI::Selectable(ModeNames[i], int(i) == Setting_Mode)) {
                Setting_Mode = BgMode(i);
                // if the setting mode gets changed to disabled, force-run SetMenuBgItems once
                if (!PluginIsEnabled()) {
                    SetMenuBgImages(true, true);
                }
            }
        }
        UI::EndCombo();
    }

    // exit early (show no other settings) if we're disabled
    if (!PluginIsEnabled()) {
        // UI::PopFont();
        return;
    }

    S_HideNewMenuBG = UI::Checkbox("Hide new menu bg (useful for ultrawide)", S_HideNewMenuBG);
    S_StretchMenuForUltrawide = UI::Checkbox("Stretch new menu bg (useful for ultrawide)", S_StretchMenuForUltrawide);
    S_DisableBlurredSidesOnHomePage = UI::Checkbox("Disable Blurred Sides on Home Page (useful for ultrawide)", S_DisableBlurredSidesOnHomePage);

    Setting_EnableBgRanked = UI::Checkbox("Enable for Ranked/Royal Menu Page?", Setting_EnableBgRanked);
    // UI::PopFont();
    AddSimpleTooltip("You might want to disable this if you get flickers on Ranked/Royal BGs and that bothers you.\nThe same menu page is reused for both Ranked/Royal, which means the backgrounds need to be reset each time you load the menu.\nThere are multiple BG layers, and that's why it flickers more on ranked.");

    // VPad();
    // UI::Separator();
    // VPad();

    // // UI::PushFont(fontLarger);
    // UI::Text("Reflection Settings:");
    // // UI::PopFont();
    // Setting_HideCar = UI::Checkbox("Hide Car+Reflection on Menu Home Page?", Setting_HideCar);
    // if (!Setting_HideCar) AddSimpleTooltip("If the car does not re-appear, go into a new menu and then back again to reload it.");
    // Setting_HideCarOnRanked = UI::Checkbox("Hide Car+Reflection on Ranked/Royal Page?", Setting_HideCarOnRanked);
    // if (!Setting_HideCarOnRanked) AddSimpleTooltip("If the car does not re-appear, go into a new menu and then back again to reload it.");
    // VPad();
    // UI::TextWrapped("\\$0cfHey! If you want more control over menu reflections, check out *Menu Background Reflections* in the plugin manager.");
    // UI::Markdown("Link: [Menu Background Reflections](https://openplanet.dev/plugin/menu-bg-refls) (opens in browser)");

    VPad();
    UI::Separator();
    VPad();

    // UI::PushFont(fontLarger);
    UI::Text("Mode Settings:");
    VPad();
    // UI::PopFont();

    switch (Setting_Mode) {
        case BgMode::SetTimeOfDay:
            _DrawTod(); break;
        case BgMode::BetterLoadingScreens:
            _DrawBLS(); break;
        case BgMode::GreepList:
            _DrawGreepList(); break;
        case BgMode::TMX:
            _DrawTmx(); break;
        case BgMode::CustomUrl:
            _DrawCustom(); break;
        case BgMode::NoBackground:
            _DrawNoBg(); break;
        default:
            _DrawDisabled(); return;
    }
}

/* TIME OF DAY */

[Setting hidden]
NadeoMenuBackground Setting_BackgroundChoice = NadeoMenuBackground::Clouds_Night;

void _DrawTod() {
    // UI::PushFont(fontLarger);
    if (UI::BeginCombo("##bg-chooser-tod", MenuBgNames[Setting_BackgroundChoice])) {
        for (uint i = 0; i < MenuBgNames.Length; i++) {
            if (UI::Selectable(MenuBgNames[i], int(i) == Setting_BackgroundChoice)) {
                Setting_BackgroundChoice = NadeoMenuBackground(i);
            }
        }
        UI::EndCombo();
    }
    // UI::PopFont();
}

void _DrawNoBg() {
    // UI::PushFont(fontLarger);
    UI::Text("Background will be set to transparent.");
    UI::Text("This is useful to see what is behind the BG.");
    // UI::PopFont();
}

void _DrawBLS() {
    // UI::PushFont(fontLarger);
    UI::Text("Background will be set to a random 'Better Loading Screens' image.");
    UI::Text("Downloaded list of BLS images? " + (IsBLSInitialized() ? 'Yes (' + blsManifest.Length + ' images)' : 'Not yet'));

    if (!IsBLSInitialized())
        UI::BeginDisabled();

    UI::Text("Current BLS image index: " + randBLSIx);
    if (UI::Button("Randomize Background")) {
        randBLSIx = Math::Rand(0, blsManifest.Length);
    }

    if (!IsBLSInitialized())
        UI::EndDisabled();

    // UI::PopFont();
}

void _DrawGreepList() {
    // UI::PushFont(fontLarger);
    UI::Text("Background will be set to a random image from Greep's list.");
    UI::Text("Downloaded list of images? " + (GreepList::GotList() ? 'Yes (' + GreepList::greepList.Length + ' images)' : 'Not yet'));

    if (!GreepList::GotList())
        UI::BeginDisabled();

    UI::Text("Current image index: " + GreepList::randIx);
    if (UI::Button("Randomize Background")) {
        GreepList::randIx = Math::Rand(0, GreepList::greepList.Length);
    }

    if (!GreepList::GotList())
        UI::EndDisabled();

    // UI::PopFont();
}

/* TMX */

[Setting hidden]
bool Setting_TmxRandom = false;
[Setting hidden]
bool Setting_TmxCurrent = true;
[Setting hidden]
string Setting_TmxPastMonth = "20-08";

bool TmxBgIsAPastMonth() {
    return !Setting_TmxCurrent && !Setting_TmxRandom;
}

void _DrawTmx() {
    // UI::PushFont(fontLarger);
    Setting_TmxRandom = UI::Checkbox("Randomize TMX Background?", Setting_TmxRandom);
    if (Setting_TmxRandom)
        UI::BeginDisabled();

    Setting_TmxCurrent = UI::Checkbox("Use TMX Background for This Month?", !Setting_TmxRandom && Setting_TmxCurrent);
    if (!Setting_TmxRandom && Setting_TmxCurrent)
        UI::BeginDisabled();

    UI::Text("Choose Month:");
    if (UI::BeginCombo("##bg-chooser-tmx-month", Setting_TmxPastMonth)) {
        for (uint i = 0; i < tmxAllMonthYrs.Length; i++) {
            if (UI::Selectable(tmxAllMonthYrs[i], tmxAllMonthYrs[i] == Setting_TmxPastMonth)) {
                Setting_TmxPastMonth = tmxAllMonthYrs[i];
            }
        }
        UI::EndCombo();
    }

    if (Setting_TmxRandom || Setting_TmxCurrent)
        UI::EndDisabled();

    // UI::PopFont();
    VPad();

    if (UI::Button("Refresh Background")) {
        LoadCurrTmxData();
    }
    UI::Text("Date of current background (YY-MM): " + lastSetTmxBgYrMo);
}

/* CUSTOM */

// this setting allows us to load cached images on first load (it's set to false on "Apply" and true in CheckAndCacheCustomUrl)
[Setting hidden]
bool Setting_CheckedCurrentCustomImgUrl = false;

[Setting hidden]
string Setting_CustomImageURL = "https://openplanet.dev/img/header.webp";
// string Setting_CustomImageURL = "https://i.imgur.com/cysV8Fn.png";
// string Setting_CustomImageURL = "http://localhost:8888/noisestorm-crabs2.webm";

string imageURLTextBox;

void _DrawCustom() {
    if (imageURLTextBox.Length == 0)
        imageURLTextBox = Setting_CustomImageURL;
    // UI::TextWrapped("\\$f80Warning\\$z: A bad image URL might crash the game. Be careful!");
    // VPad();
    UI::TextWrapped("Supported formats: jpg, png, webp, webm (video)");
    UI::TextWrapped("\\$fa4Note:\\$z Other formats might work too. If a format isn't compatible then the background will go black.");
    UI::TextWrapped("\\$fa4Note:\\$z The image will be stretched to your screen resolution. (Future feature: aspect ratio / cropping / alignment.)");
    UI::TextWrapped("\\$fa4Note:\\$z The image URL must point directly to an image -- redirects will not work.");

    VPad();
    // UI::PushFont(fontLarger);
    UI::Text("Image URL:");
    bool pressedEnter = false;
    imageURLTextBox = UI::InputText("##bg-chooser-image-url", imageURLTextBox, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
    if (pressedEnter || UI::Button("Apply")) {
        Setting_CustomImageURL = imageURLTextBox;
        Setting_CheckedCurrentCustomImgUrl = false;
        startnew(CheckAndCacheCustomUrl);
    }
    // UI::PopFont();
    VPad();
    // show status msgs when requesting
    if (!UrlOkayToShowAsBg(Setting_CustomImageURL)) {
        UI::Text("Url: " + Setting_CustomImageURL);
        UI::Text("Url: " + (bgLastUrlValid ? "is" : "is not") + " valid");
        if (bgCheckReq is null) {
            UI::Text("Download not started.");
        } else {
            if (!bgCheckReq.IsCompleted) {
                UI::Text("Download in progress...");
            } else {
                UI::Text("Download complete; status = " + bgCheckReq.StatusCode);
            }
        }
    } else {
        UI::Text("URL valid and cached: " + Setting_CustomImageURL);
    }

    if (bgCheckReq !is null && bgCheckReq.IsCompleted)
        UI::TextWrapped("\\$fa4Note:\\$z If the background is still black, it's probably because the URL is not a direct link to an image.");
}

/* DISABLED */

void _DrawDisabled() {
    UI::TextWrapped("Disabled");
}
