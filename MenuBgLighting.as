CGameMenuSceneScriptManager@ MenuSceneMgr;
MwId SceneId;

// Dev::InterceptProc("CGameMenuSceneScriptManager", "CameraSetLocation1", _CameraSetLocation1);

bool _CameraSetLocation1(CMwStack &in stack, CMwNod@ nod) {
    if (MenuSceneMgr !is null) return true;
    @MenuSceneMgr = cast<CGameMenuSceneScriptManager>(nod);
    bool ret = true;
    SceneId = stack.CurrentId(3);
    // print("SceneId: " + SceneId.Value);
    // print("SceneId: " + SceneId.GetName());
    return ret;
}



[Setting hidden]
bool S_CustomizePilotLighting = false;

[Setting hidden]
vec3 S_DriverLightingColor = vec3(1, .9, .1);

[Setting hidden]
float S_DriverLightingIntensity = 1.5;


[SettingsTab name="Pilot Lighting" icon="LightbulbO"]
void RenderPilotLightingSettings() {
    S_CustomizePilotLighting = UI::Checkbox("Customize car/pilot lighting?", S_CustomizePilotLighting);
    S_DriverLightingColor = UI::InputColor3("Lighting Color", S_DriverLightingColor);
    S_DriverLightingIntensity = UI::SliderFloat("Lighting intensity", S_DriverLightingIntensity, 0., 2.0, "%.2f");
    AddSimpleTooltip("Defaults: daytime=1.5, night=1.3, sunrise=1., sunset=1.25");
}
