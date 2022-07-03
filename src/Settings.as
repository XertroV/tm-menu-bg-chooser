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

[SettingsTab name="Menu Background"]
void RenderSettings() {
    UI::Text("Background Mode:");
    VPad();

    if (UI::BeginCombo("##menu-bg-mode", ModeNames[Setting_Mode])) {
        for (uint i = 0; i < ModeNames.Length; i++) {
            if (UI::Selectable(ModeNames[i], int(i) == Setting_Mode)) {
                Setting_Mode = BgMode(i);
            }
        }
        UI::EndCombo();
    }
    VPad();

    UI::TextWrapped("\\$fa4Please note:\\$z To disable this plugin, select 'Disabled' and then restart the game.");

    VPad();
    Setting_HideCar = UI::Checkbox("Hide Car+Reflection on Menu Home Page?", Setting_HideCar);

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
            _DrawDisabled(); break;
    }
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
    if (UI::BeginCombo("##bg-chooser-tod", MenuBgNames[Setting_BackgroundChoice])) {
        for (uint i = 0; i < MenuBgNames.Length; i++) {
            if (UI::Selectable(MenuBgNames[i], int(i) == Setting_BackgroundChoice)) {
                Setting_BackgroundChoice = NadeoMenuBackground(i);
            }
        }
        UI::EndCombo();
    }
}

/* TMX */

void _DrawTmx() {}

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
    VPad();
    UI::Text("Image URL:");
    bool pressedEnter = false;
    imageURLTextBox = UI::InputText("##bg-chooser-image-url", imageURLTextBox, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
    if (pressedEnter || UI::Button("Apply")) {
        customImageURL = imageURLTextBox;
        Setting_CheckedCurrentCustomImgUrl = false;
        startnew(CheckAndCacheCustomUrl);
    }
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
}

/* DISABLED */

void _DrawDisabled() {
    UI::TextWrapped("Disabled");
}

/* MISC */

void VPad() {
    UI::Dummy(vec2(0, 2));
}
