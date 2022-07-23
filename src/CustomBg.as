/*

- Download + cache custom BGs before loading as menu BG

*/

CNetScriptHttpRequest@ bgCheckReq;
string bgLastCheckedUrl;
bool bgLastUrlValid = true;
int bgLastUrlStatusCode = 200;

bool CheckUrlExistsAndIsCached(const string &in url) {
    bgLastCheckedUrl = url;
    auto http = GI::GetHttpManager();

    // note: found a maybe relevant function: PreloadImage(string ImageUrl)

    bgLastUrlValid = http.IsValidUrl(url);
    if (!bgLastUrlValid) {
        warn("Invalid URL: " + url);
        return false;
    }

    @bgCheckReq = http.CreateGet2(url, true);
    while (bgCheckReq is null || !bgCheckReq.IsCompleted) {
        yield();
    }
    trace("Download complete for URL: " + url + " (status=" + bgCheckReq.StatusCode + ")");

    // Successful status codes could be any 2xx code I think.
    // I am unsure if redirects are followed or if direct urls are required.
    bgLastUrlStatusCode = bgCheckReq.StatusCode;
    return bgCheckReq.StatusCode == 200;
}

dictionary@ checkedUrls = dictionary();

bool UrlOkayToShowAsBg(const string &in url) {
    return checkedUrls.Exists(url);
}

void CheckAndCacheCustomUrl() {
    @bgCheckReq = null;
    string url = Setting_CustomImageURL;
    trace("Checking URL: " + url);
    if (CheckUrlExistsAndIsCached(url)) {
        checkedUrls[url] = true;
    }
    Setting_CheckedCurrentCustomImgUrl = true;
}

/* NOTE: This does not seem to actually cache the image as far as Quad's are concerned.
   Also, .PreloadImage(url) crashes the game :(
*/

// class CacheUrl {
//     string url;
//     CacheUrl(const string &in _url) {
//         url = _url;
//     }
// }

// void CoroCacheUrl(ref r) {
//     string url = cast<CacheUrl>(r).url;
//     trace("Caching URL: " + url);
//     CheckUrlExistsAndIsCached(url);
// }
