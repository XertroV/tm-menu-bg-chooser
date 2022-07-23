notes

```AngelScript
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
```
