const string manifestUrl = "https://openplanet.dev/plugin/betterloadingscreen/config/loading_screens";

Json::Value@ FetchManifest() {
    auto req = Net::HttpRequest();
    req.Url = manifestUrl;
    req.Start();
    while(!req.Finished()) { yield(); }
    return Json::Parse(req.String());
}

string[] blsManifest = {};

void SetBLSManifest() {
    auto manifest = FetchManifest();
    if (manifest.GetType() == Json::Type::Array) {
        blsManifest.RemoveRange(0, blsManifest.Length);
        for (uint i = 0; i < manifest.Length; i++) {
            blsManifest.InsertLast(string(manifest[i]));
        }
        randBLSIx = Math::Rand(0, blsManifest.Length);
    } else {
        UI::ShowNotification("Menu BG Chooser", "Could not load Better Loading Screens manifest file.", vec4(.9, .6, .0, .9), 5000);
    }
}

bool IsBLSInitialized() {
    return blsManifest.Length > 0;
}
