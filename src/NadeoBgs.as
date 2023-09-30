enum NadeoMenuBackground
    { Morning = 0
    , Day
    , Evening
    , Night
    , Clouds_Day
    , Clouds_Sunset
    , Clouds_Night
    , Spring_Morning
    , Spring_Day
    , Spring_Sunset
    , Spring_Night
    , Summer_Morning
    , Summer_Day
    , Summer_Sunset
    , Summer_Night
    , Fall_Morning
    , Fall_Day
    , Fall_Sunset
    , Fall_Night
    , Winter_Morning
    , Winter_Day
    , Winter_Sunset
    , Winter_Night
    , Garage
    , Royal_Dawn
    , Royal_Midday
    , Royal_Sunset
    , Royal_Night
    , Ranked_Gold_Dawn
    , Ranked_Gold_Midday
    , Ranked_Gold_Sunset
    , Ranked_Gold_Night
    , Ranked_Silver_Dawn
    , Ranked_Silver_Midday
    , Ranked_Silver_Sunset
    , Ranked_Silver_Night
    , Ranked_Bronze_Dawn
    , Ranked_Bronze_Midday
    , Ranked_Bronze_Sunset
    , Ranked_Bronze_Night
    , UI_profile_background_map_gradients
    , NoBackground
    }

// MUST match NadeoMenuBackground enum above.

const string[] MenuBgNames =
    { 'Morning'
    , 'Day'
    , 'Evening'
    , 'Night'
    , 'Clouds_Day (webm)'
    , 'Clouds_Sunset (webm)'
    , 'Clouds_Night (webm)'
    , "Spring_Morning"
    , "Spring_Day"
    , "Spring_Sunset"
    , "Spring_Night"
    , "Summer_Morning"
    , "Summer_Day"
    , "Summer_Sunset"
    , "Summer_Night"
    , "Fall_Morning"
    , "Fall_Day"
    , "Fall_Sunset"
    , "Fall_Night"
    , "Winter_Morning"
    , "Winter_Day"
    , "Winter_Sunset"
    , "Winter_Night"
    , 'Garage'
    , 'Royal_Dawn'
    , 'Royal_Midday'
    , 'Royal_Sunset'
    , 'Royal_Night'
    , 'Ranked_Gold_Dawn'
    , 'Ranked_Gold_Midday'
    , 'Ranked_Gold_Sunset'
    , 'Ranked_Gold_Night'
    , 'Ranked_Silver_Dawn'
    , 'Ranked_Silver_Midday'
    , 'Ranked_Silver_Sunset'
    , 'Ranked_Silver_Night'
    , 'Ranked_Bronze_Dawn'
    , 'Ranked_Bronze_Midday'
    , 'Ranked_Bronze_Sunset'
    , 'Ranked_Bronze_Night'
    , 'UI_profile_background_map_gradients'
    , 'No Background'
    };

const string BgFilePrefix = "file://Media/Manialinks/Nadeo/Trackmania/Menus/";
const string bgfp = BgFilePrefix;

dictionary MenuBgFiles =
    { {'Morning', bgfp + 'MainBackgrounds/Background_Morning.dds'}
    , {'Day', bgfp + 'MainBackgrounds/Background_Day.dds'}
    , {'Evening', bgfp + 'MainBackgrounds/Background_Evening.dds'}
    , {'Night', bgfp + 'MainBackgrounds/Background_Night.dds'}
    , {'Clouds_Day (webm)', bgfp + 'HomeBackground/Clouds_Day.webm'}
    , {'Clouds_Sunset (webm)', bgfp + 'HomeBackground/Clouds_Sunset.webm'}
    , {'Clouds_Night (webm)', bgfp + 'HomeBackground/Clouds_Night.webm'}
    , {'Spring_Morning', bgfp + "HomeBackground/MenuBackground_Spring_Morning.dds"}
    , {'Spring_Day', bgfp + "HomeBackground/MenuBackground_Spring_Day.dds"}
    , {'Spring_Sunset', bgfp + "HomeBackground/MenuBackground_Spring_Sunset.dds"}
    , {'Spring_Night', bgfp + "HomeBackground/MenuBackground_Spring_Night.dds"}
    , {'Summer_Morning', bgfp + "HomeBackground/MenuBackground_Summer_Morning.dds"}
    , {'Summer_Day', bgfp + "HomeBackground/MenuBackground_Summer_Day.dds"}
    , {'Summer_Sunset', bgfp + "HomeBackground/MenuBackground_Summer_Sunset.dds"}
    , {'Summer_Night', bgfp + "HomeBackground/MenuBackground_Summer_Night.dds"}
    , {'Fall_Morning', bgfp + "HomeBackground/MenuBackground_Fall_Morning.dds"}
    , {'Fall_Day', bgfp + "HomeBackground/MenuBackground_Fall_Day.dds"}
    , {'Fall_Sunset', bgfp + "HomeBackground/MenuBackground_Fall_Sunset.dds"}
    , {'Fall_Night', bgfp + "HomeBackground/MenuBackground_Fall_Night.dds"}
    , {'Winter_Morning', bgfp + "HomeBackground/MenuBackground_Winter_Morning.dds"}
    , {'Winter_Day', bgfp + "HomeBackground/MenuBackground_Winter_Day.dds"}
    , {'Winter_Sunset', bgfp + "HomeBackground/MenuBackground_Winter_Sunset.dds"}
    , {'Winter_Night', bgfp + "HomeBackground/MenuBackground_Winter_Night.dds"}
    , {'Garage', bgfp + 'PageGarage/Garage_background.dds'}
    , {'Royal_Dawn', bgfp + 'PageMatchmakingMain/Background/Royal_Dawn.dds'}
    , {'Royal_Midday', bgfp + 'PageMatchmakingMain/Background/Royal_Midday.dds'}
    , {'Royal_Night', bgfp + 'PageMatchmakingMain/Background/Royal_Night.dds'}
    , {'Royal_Sunset', bgfp + 'PageMatchmakingMain/Background/Royal_Sunset.dds'}
    , {'Ranked_Gold_Dawn', bgfp + 'PageMatchmakingMain/Background/G_Dawn.dds'}
    , {'Ranked_Gold_Midday', bgfp + 'PageMatchmakingMain/Background/G_Midday.dds'}
    , {'Ranked_Gold_Sunset', bgfp + 'PageMatchmakingMain/Background/G_Sunset.dds'}
    , {'Ranked_Gold_Night', bgfp + 'PageMatchmakingMain/Background/G_Night.dds'}
    , {'Ranked_Silver_Dawn', bgfp + 'PageMatchmakingMain/Background/S_Dawn.dds'}
    , {'Ranked_Silver_Midday', bgfp + 'PageMatchmakingMain/Background/S_Midday.dds'}
    , {'Ranked_Silver_Sunset', bgfp + 'PageMatchmakingMain/Background/S_Sunset.dds'}
    , {'Ranked_Silver_Night', bgfp + 'PageMatchmakingMain/Background/S_Night.dds'}
    , {'Ranked_Bronze_Dawn', bgfp + 'PageMatchmakingMain/Background/B_Dawn.dds'}
    , {'Ranked_Bronze_Midday', bgfp + 'PageMatchmakingMain/Background/B_Midday.dds'}
    , {'Ranked_Bronze_Sunset', bgfp + 'PageMatchmakingMain/Background/B_Sunset.dds'}
    , {'Ranked_Bronze_Night', bgfp + 'PageMatchmakingMain/Background/B_Night.dds'}
    , {'UI_profile_background_map_gradients', bgfp + 'PageProfile/UI_profile_background_map_gradients.dds'}
    , {'No Background', ''}
};
