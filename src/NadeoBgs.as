enum NadeoMenuBackground
    { Morning = 0
    , Day
    , Evening
    , Night
    , Stadium_Sunrise
    , Stadium_Day
    , Stadium_Sunset
    , Stadium_Night
    , Clouds_Sunrise
    , Clouds_Day
    , Clouds_Sunset
    , Clouds_Night
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

// MUST match NadeoMenuBackground enum
const string[] MenuBgNames =
    { 'Morning'
    , 'Day'
    , 'Evening'
    , 'Night'
    , 'Stadium_Sunrise'
    , 'Stadium_Day'
    , 'Stadium_Sunset'
    , 'Stadium_Night'
    , 'Clouds_Sunrise (webm)'
    , 'Clouds_Day (webm)'
    , 'Clouds_Sunset (webm)'
    , 'Clouds_Night (webm)'
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

const string BgFilePrefix = "file://Media/Manialinks/Nadeo/TMNext/Menus/";
const string bgfp = BgFilePrefix;

dictionary MenuBgFiles =
    { {'Morning', bgfp + 'MainBackgrounds/Background_Morning.dds'}
    , {'Day', bgfp + 'MainBackgrounds/Background_Day.dds'}
    , {'Evening', bgfp + 'MainBackgrounds/Background_Evening.dds'}
    , {'Night', bgfp + 'MainBackgrounds/Background_Night.dds'}
    , {'Stadium_Sunrise', bgfp + 'HomeBackground/Stadium_Sunrise.dds'}
    , {'Stadium_Day', bgfp + 'HomeBackground/Stadium_Day.dds'}
    , {'Stadium_Sunset', bgfp + 'HomeBackground/Stadium_Sunset.dds'}
    , {'Stadium_Night', bgfp + 'HomeBackground/Stadium_Night.dds'}
    , {'Clouds_Sunrise (webm)', bgfp + 'HomeBackground/Clouds_Sunrise.webm'}
    , {'Clouds_Day (webm)', bgfp + 'HomeBackground/Clouds_Day.webm'}
    , {'Clouds_Sunset (webm)', bgfp + 'HomeBackground/Clouds_Sunset.webm'}
    , {'Clouds_Night (webm)', bgfp + 'HomeBackground/Clouds_Night.webm'}
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
