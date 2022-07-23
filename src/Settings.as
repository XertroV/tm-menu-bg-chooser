// BgMode values must exactly correspond to ModeNames indexes
enum BgMode {
    Disabled = 0,
    SetTimeOfDay,
    TMX,
    CustomUrl
}

string[] ModeNames = { "Disabled", "Set Time of Day (TM default BG)", "Trackmania Exchange Monthly BG", "Custom BG (via URL)" };

[Setting hidden]
BgMode Setting_Mode = BgMode::SetTimeOfDay;

bool PluginIsEnabled() {
    return Setting_Mode != BgMode::Disabled;
}

[Setting hidden]
bool Setting_HideCar = false;

[Setting hidden]
bool Setting_EnableBgRanked = true;

[Setting hidden]
bool Setting_HideCarOnRanked = false;

[SettingsTab name="Menu Background"]
void RenderMenuBgSettings() {
    UI::PushFont(fontLarger);
    UI::Text("Background Mode:");
    if (UI::BeginCombo("##menu-bg-mode", ModeNames[Setting_Mode])) {
        for (uint i = 0; i < ModeNames.Length; i++) {
            if (UI::Selectable(ModeNames[i], int(i) == Setting_Mode)) {
                Setting_Mode = BgMode(i);
            }
        }
        UI::EndCombo();
    }
    Setting_EnableBgRanked = UI::Checkbox("Enable for Ranked/Royal Menu Page?", Setting_EnableBgRanked);
    UI::PopFont();
    AddSimpleTooltip("You might want to disable this if you get flickers on Ranked/Royal BGs and that bothers you.\nThe same menu page is reused for both Ranked/Royal, which means the backgrounds need to be reset each time you load the menu.\nThere are multiple BG layers, and that's why it flickers more on ranked.");
    VPad();


    UI::TextWrapped("\\$fa4Please note:\\$z To disable this plugin, select 'Disabled' and then restart the game.");

    VPad();
    UI::Separator();
    VPad();

    switch (Setting_Mode) {
        case BgMode::SetTimeOfDay:
            _DrawTod(); break;
        case BgMode::TMX:
            _DrawTmx(); break;
        case BgMode::CustomUrl:
            _DrawCustom(); break;
        default:
            _DrawDisabled();
            return;
    }

    VPad();
    UI::Separator();
    VPad();

    Setting_HideCar = UI::Checkbox("Hide Car+Reflection on Menu Home Page?", Setting_HideCar);
    Setting_HideCarOnRanked = UI::Checkbox("Hide Car+Reflection on Ranked/Royal Page?", Setting_HideCarOnRanked);
}

/* TIME OF DAY */

enum NadeoMenuBackground {
    Morning = 0,
    Day,
    Evening,
    Night
}

string[] MenuBgNames = { 'Morning.png', 'Day.png', 'Evening.png', 'Night.jpg' };

[Setting hidden]
NadeoMenuBackground Setting_BackgroundChoice = NadeoMenuBackground::Morning;

void _DrawTod() {
    UI::PushFont(fontLarger);
    if (UI::BeginCombo("##bg-chooser-tod", MenuBgNames[Setting_BackgroundChoice])) {
        for (uint i = 0; i < MenuBgNames.Length; i++) {
            if (UI::Selectable(MenuBgNames[i], int(i) == Setting_BackgroundChoice)) {
                Setting_BackgroundChoice = NadeoMenuBackground(i);
            }
        }
        UI::EndCombo();
    }
    UI::PopFont();
}

/* TMX */

[Setting hidden]
bool Setting_TmxRandom = false;

void _DrawTmx() {
    UI::PushFont(fontLarger);
    Setting_TmxRandom = UI::Checkbox("Randomize TMX Background?", Setting_TmxRandom);
    if (MDisabledButton(!Setting_TmxRandom, "Randomize Now")) {
        tmxCurrUrl = RefreshTmxData();
    }
    UI::PopFont();
    VPad();
    UI::Text("Date of current background (YY-MM): " + tmxMonthYr);
}

/* CUSTOM */

// this setting allows us to load cached images on first load (it's set to false on "Apply" and true in CheckAndCacheCustomUrl)
[Setting hidden]
bool Setting_CheckedCurrentCustomImgUrl = false;

[Setting hidden]
string customImageURL = "https://openplanet.dev/img/header.webp";
// string customImageURL = "https://i.imgur.com/cysV8Fn.png";
// string customImageURL = "http://localhost:8888/noisestorm-crabs2.webm";

string imageURLTextBox;

void _DrawCustom() {
    if (imageURLTextBox.Length == 0)
        imageURLTextBox = customImageURL;
    // UI::TextWrapped("\\$f80Warning\\$z: A bad image URL might crash the game. Be careful!");
    // VPad();
    UI::TextWrapped("Supported formats: jpg, png, webp, webm (video)");
    UI::TextWrapped("\\$fa4Note:\\$z Other formats might work too. If a format isn't compatible then the background will go black.");
    UI::TextWrapped("\\$fa4Note:\\$z The image will be stretched to your screen resolution. (Future feature: aspect ratio / cropping / alignment.)");
    UI::TextWrapped("\\$fa4Note:\\$z The image URL must point directly to an image -- redirects will not work.");

    VPad();
    UI::PushFont(fontLarger);
    UI::Text("Image URL:");
    bool pressedEnter = false;
    imageURLTextBox = UI::InputText("##bg-chooser-image-url", imageURLTextBox, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
    if (pressedEnter || UI::Button("Apply")) {
        customImageURL = imageURLTextBox;
        Setting_CheckedCurrentCustomImgUrl = false;
        startnew(CheckAndCacheCustomUrl);
    }
    UI::PopFont();
    VPad();
    // show status msgs when requesting
    if (!UrlOkayToShowAsBg(customImageURL)) {
        UI::Text("Url: " + customImageURL);
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
        UI::Text("URL valid and cached: " + customImageURL);
    }

    if (bgCheckReq !is null && bgCheckReq.IsCompleted)
        UI::TextWrapped("\\$fa4Note:\\$z If the background is still black, it's probably because the URL is not a direct link to an image.");
}

/* DISABLED */

void _DrawDisabled() {
    UI::TextWrapped("Disabled");
}

/* Reflection Settings */

[Setting category="BG Reflection" name="Opacity" min="-20.0" max="20.0"]
float Setting_BgReflectionOpacity = 0.63;

[Setting category="BG Reflection" name="Angle" min="-20.0" max="2.0" description="Clipping occurs below -6"]
float Setting_BgReflectionAngle = -2.1;
