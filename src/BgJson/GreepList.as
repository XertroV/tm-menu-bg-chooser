
namespace GreepList {
    string url = "https://greep.gq/api/trackmaniabackgrounds.json";

    Json::Value@ FetchGreepList() {
        auto req = Net::HttpGet(url);
        while(!req.Finished()) { yield(); }
        return Json::Parse(req.String());
    }

    string[] greepList = {};
    int randIx = -1;

    string GetImageUrl() {
        if (!GotList()) return "";
        if (randIx < 0)
            randIx = Math::Rand(0, greepList.Length);
        return greepList[randIx];
    }

    void UpdateList() {
        auto bgs = FetchGreepList();
        if (bgs.GetType() == Json::Type::Object && bgs['tm2020'].GetType() == Json::Type::Array) {
            greepList.RemoveRange(0, greepList.Length);
            for (uint i = 0; i < bgs['tm2020'].Length; i++) {
                auto obj = bgs['tm2020'][i];
                if (obj.GetType() != Json::Type::Object) continue;
                auto imgUrl = string(bgs['tm2020'][i]['url']);
                if (imgUrl.Length > 0)
                    greepList.InsertLast(imgUrl);
            }
            randIx = Math::Rand(0, greepList.Length);
        } else {
            UI::ShowNotification("Menu BG Chooser", "Could not load Greep's background file.", vec4(.9, .6, .0, .9), 5000);
        }
    }

    bool GotList() {
        return greepList.Length > 0;
    }
}
