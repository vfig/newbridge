// FIXME: don't forget to set RoomCanal ambience back to Streets!

enum eAmbienceProgress {
    kMissionStart,
    kWhereIsArgaux,
    kGotTheJob,
    kGotTheHand,
    kGotThemBoth,
    kTimeToGoHome,
    kStopTheRitual,
    kAllDoneNow,
    // The number of progress states
    kCount,
}

class AmbienceController extends SqRootScript
{
    /* Put this on a marker named 'AmbienceController'. */

    REGIONS = {
        STREETS = [
            /* start */    ["m20city1loop", "m20city1mood", "m20city1ten"],
            /* argaux? */  ["m20city1loop", "m20city1mood", "m20city2ten"],
            /* the job */  ["m20city3loop", "m20city3mood", "m20city3ten"],
            /* got hand */ ["m20city3loop", "m20city3mood", "m20city3ten"],
            /* got both */ ["m20city3loop", "m20city4mood", "m20city3ten"],
            /* go home? */ ["m20city5loop", "m20city4mood", "m20city5ten"],
            /* ritual */   ["m20city5loop", "m20city6ten"],
            /* all done */ ["m20city1loop", "m20city1mood"],
        ],
        ARGAUXS = [
            /* start */    ["m20argloop", "m20argmood", "m20city1ten"],
            /* argaux? */  ["m20argloop", "m20argmood", "m20city2ten"],
            /* the job */  ["m20argloop", "m20argmood", "m20city3ten"],
            /* got hand */ ["m20argloop", "m20argmood", "m20city3ten"],
            /* got both */ ["m20argloop", "m20argmood", "m20city3ten"],
            /* go home? */ ["m20argloop", "m20argmood", "m20city5ten"],
            /* ritual */   ["m20argloop", "m20argmood", "m20city6ten"],
            /* all done */ ["m20argloop", "m20argmood"],
        ],
        FISHMONGERS = [
            /* start */    ["m20city1loop", "m20city1mood", "m20city1ten"],
            /* argaux? */  ["m20city1loop", "m20city1mood", "m20city2ten"],
            /* the job */  ["m20fishloop", "m20fishmood"],
            /* got hand */ ["m20fishloop", "m20fishmood"],
            /* got both */ ["m20fishloop", "m20fishmood"],
            /* go home? */ ["m20fishloop", "m20fishmood"],
            /* ritual */   ["m20fishloop", "m20fishmood", "m20city6ten"],
            /* all done */ ["m20fishloop", "m20fishmood"],
        ],
        CEMETERY = [
            /* start */    ["m20ceme1loop", "m20city1mood", "m20city1ten"],
            /* argaux? */  ["m20ceme1loop", "m20city1mood", "m20city2ten"],
            /* the job */  ["m20ceme1loop", "m20city3mood", "m20city3ten"],
            /* got hand */ ["m20ceme1loop", "m20city3mood", "m20city3ten"],
            /* got both */ ["m20ceme1loop", "m20city4mood", "m20city3ten"],
            /* go home? */ ["m20ceme1loop", "m20city4mood", "m20city5ten"],
            /* ritual */   ["m20ceme1loop", "m20city6ten"],
            /* all done */ ["m20ceme1loop", "m20city1mood"],
        ],
        MAUSOLEUM = [
            /* start */    ["m20maustone", "m20mausmood"],
            /* argaux? */  ["m20maustone", "m20mausmood"],
            /* the job */  ["m20maustone", "m20mausmood"],
            /* got hand */ ["m20maustone", "m20mausmood"],
            /* got both */ ["m20maustone", "m20mausmood"],
            /* go home? */ ["m20maustone", "m20mausmood"],
            /* ritual */   ["m20maustone", "m20mausmood"],
            /* all done */ ["m20maustone", "m20mausmood"],
        ],
        CATACOMBS = [
            /* start */    ["m20catatone", "m20cataloop1", "m20catavoice"],
            /* argaux? */  ["m20catatone", "m20cataloop1", "m20catavoice"],
            /* the job */  ["m20catatone", "m20cataloop1", "m20catavoice"],
            /* got hand */ ["m20catatone", "m20cataloop2"],
            /* got both */ ["m20catatone", "m20cataloop2"],
            /* go home? */ ["m20catatone", "m20cataloop2"],
            /* ritual */   ["m20catatone", "m20cataloop2"],
            /* all done */ ["m20catatone", "m20cataloop1"],
        ],
        SANCT_EXT = [
            /* start */    ["m20city1loop", "m20city1mood", "m20sanct1ten"],
            /* argaux? */  ["m20city1loop", "m20city1mood", "m20sanct1ten"],
            /* the job */  ["m20city3loop", "m20city3mood", "m20sanct1ten"],
            /* got hand */ ["m20city3loop", "m20city3mood", "m20sanct1ten"],
            /* got both */ ["m20city3loop", "m20city4mood", "m20sanct1ten"],
            /* go home? */ ["m20city5loop", "m20city4mood", "m20sanct1ten"],
            /* ritual */   ["m20city5loop", "m20city6ten", "m20sanct1ten"],
            /* all done */ ["m20city1loop", "m20city1mood", "m20sanct1ten"],
        ],
        SANCT_INT = [
            /* start */    ["m20sanct1loop", "m20sanct1ten"],
            /* argaux? */  ["m20sanct1loop", "m20sanct1ten"],
            /* the job */  ["m20sanct1loop", "m20sanct1ten"],
            /* got hand */ ["m20sanct1loop", "m20sanct1ten"],
            /* got both */ ["m20sanct1loop", "m20sanct1ten"],
            /* go home? */ ["m20sanct1loop", "m20sanct1ten"],
            /* ritual */   ["m20sanct1loop", "m20sanct1ten"],
            /* all done */ ["m20sanct1loop", "m20sanct1ten"],
        ],
        SANCT_BASE = [
            /* start */    ["m20sanct2loop", "m20sanct2ten"],
            /* argaux? */  ["m20sanct2loop", "m20sanct2ten"],
            /* the job */  ["m20sanct2loop", "m20sanct2ten"],
            /* got hand */ ["m20sanct2loop", "m20sanct2ten"],
            /* got both */ ["m20sanct2loop", "m20sanct2ten"],
            /* go home? */ ["m20sanct2loop", "m20sanct2ten"],
            /* ritual */   ["m20sanct2loop", "m20sanct2ten"],
            /* all done */ ["m20sanct2loop", "m20sanct2ten"],
        ],
        SANCT_CRYPT = [
            /* start */    ["m20sanct2loop", "m20sanct3ten"],
            /* argaux? */  ["m20sanct2loop", "m20sanct3ten"],
            /* the job */  ["m20sanct2loop", "m20sanct3ten"],
            /* got hand */ ["m20sanct2loop", "m20sanct3ten"],
            /* got both */ ["m20sanct2loop", "m20sanct3ten"],
            /* go home? */ ["m20sanct2loop", "m20sanct3ten"],
            /* ritual */   ["m20sanct2loop", "m20sanct3ten"],
            /* all done */ ["m20sanct2loop", "m20sanct3ten"],
        ],
        MANOR_EXT = [
            /* start */    ["m20man1loop", "m20city1mood", "m20city1ten"],
            /* argaux? */  ["m20man1loop", "m20city1mood", "m20city2ten"],
            /* the job */  ["m20man1loop", "m20city3mood", "m20city3ten"],
            /* got hand */ ["m20man1loop", "m20city3mood", "m20city3ten"],
            /* got both */ ["m20man1loop", "m20city4mood", "m20city3ten"],
            /* go home? */ ["m20man5loop", "m20city4mood", "m20city5ten"],
            /* ritual */   ["m20man5loop", "m20city6ten"],
            /* all done */ ["m20man1loop", "m20city1mood"],
        ],
        MANOR_INT = [
            /* start */    ["m20man1loop", "m20manintmood", "m20manintten"],
            /* argaux? */  ["m20man1loop", "m20manintmood", "m20manintten"],
            /* the job */  ["m20man1loop", "m20manintmood", "m20manintten"],
            /* got hand */ ["m20man1loop", "m20manintmood", "m20manintten"],
            /* got both */ ["m20man1loop", "m20manintmood", "m20manintten"],
            /* go home? */ ["m20man1loop", "m20manintmood", "m20manintten"],
            /* ritual */   ["m20man5loop", "m20manintmood", "m20manintten"],
            /* all done */ ["m20man1loop", "m20manintmood", "m20manintten"],
        ],
        TOWER = [
            /* start */    [],
            /* argaux? */  [],
            /* the job */  [],
            /* got hand */ [],
            /* got both */ [],
            /* go home? */ [],
            /* ritual */   ["m20cave5loop", "m20cave5mood", "m20city6ten"],
            /* all done */ ["m20cave5loop", "m20cave7mood", "m20cave7ten"],
        ],
        CAVES = [
            /* start */    [],
            /* argaux? */  [],
            /* the job */  [],
            /* got hand */ [],
            /* got both */ [],
            /* go home? */ [],
            /* ritual */   ["m20cave5loop", "m20cave5mood", "m20cave5ten"],
            /* all done */ ["m20cave5loop", "m20cave7mood", "m20cave7ten"],
        ],
        RITUAL = [
            /* start */    [],
            /* argaux? */  [],
            /* the job */  [],
            /* got hand */ [],
            /* got both */ [],
            /* go home? */ [],
            /* ritual */   ["m20ritualloop", "m20cave5mood", "m20cave5ten"],
            /* all done */ ["m20cave5loop", "m20cave7mood", "m20cave7ten"],
        ],
    }

    function CurrentRegion() {
        local region = GetData("CurrentRegion");
        if (region) {
            return region;
        } else {
            return "";
        }
    }

    function CurrentProgress() {
        local progress = GetData("CurrentProgress");
        if (progress) {
            return progress;
        } else {
            return 0;
        }
    }

    function CurrentSamples() {
        local sample0 = GetData("Sample0");
        if (! sample0) { sample0 = ""; }
        local sample1 = GetData("Sample1");
        if (! sample1) { sample1 = ""; }
        local sample2 = GetData("Sample2");
        if (! sample2) { sample2 = ""; }
        return {
            [sample0] = true,
            [sample1] = true,
            [sample2] = true,
        };
    }

    function OnRegionChange() {
        local region = message().data;
        Fillip(region, CurrentProgress());
    }

    function OnDebugNextProgress() {
        local progress = CurrentProgress();
        progress = (progress + 1) % (eAmbienceProgress.kCount);
        DarkUI.TextMessage("Ambience progress is now " + progress);
        Fillip(CurrentRegion(), progress);
    }

    function OnProgressChange() {
        // FIXME: need another object to monitor quest vars
        // and translate them into progress
        // FIXME: just realised GotTheHand needs to be an
        // orthogonal variable, since you _can_ go get it
        // before you have any reason to--and we need the
        // catacombs ambience to change accordingly.
        // We _could_ just change the Ambience property on
        // the Catacomb room and trigger a fillip?
    }

    function OnSchemaDone() {
        // FIXME: remove me
        print("Schema " + message().name + " stopped.");
    }

    function Fillip(region, progress) {
        local current_region = CurrentRegion();
        local current_progress = CurrentProgress();
        print("AMBIENCE FILLIP: " + current_region + " -> " + region + ", "
            + current_progress + " -> " + progress);
        if ((region != current_region)
            || (progress != current_progress))
        {
            SetData("CurrentRegion", region);
            SetData("CurrentProgress", progress);
            local samples;
            if (region in REGIONS) {
                local region_table = REGIONS[region];
                if ((progress >= 0)
                    && (progress < region_table.len()))
                {
                    local samples = region_table[progress];
                    FillipSamples(samples);
                } else {
                    print("AMBIENCE: " + region + " has no entry for progress " + progress);
                }
            } else {
                print("AMBIENCE: Unrecognised region " + region);
            }
        }
    }

    function FillipSamples(samples) {
        local current_samples = CurrentSamples();
        local start_samples = {};
        local stop_samples = {};
        // Build the new samples table
        local new_samples = {};
        foreach (_, s in samples) {
            if (s != "") {
                new_samples[s] <- true;
            }
        }
        // Compare new samples and current samples
        foreach (s, _ in new_samples) {
            if ((s != "")
                && (! (s in current_samples)))
            {
                start_samples[s] <- true;
            }
        }
        foreach (s, _ in current_samples) {
            if ((s != "")
                && (! (s in new_samples)))
            {
                stop_samples[s] <- true;
            }
        }
        // Save the new samples
        for (local i = 0; i < 3; ++i) {
            if (i < samples.len()) {
                SetData("Sample" + i, samples[i]);
            } else {
                SetData("Sample" + i, "");
            }
        }
        // Finally, stop samples that need stopping
        foreach (s, _ in stop_samples) {
            local result = Sound.HaltSchema(self, s, self /* FIXME: remove callback */);
            print("Stopping schema " + s + ": " + result);
        }
        // And start those that need starting
        foreach (s, _ in start_samples) {
            local result = Sound.PlaySchemaAmbient(self, s);
            print("Starting schema " + s + ": " + result);
        }
    }
}

class PlayerAmbienceWatcher extends SqRootScript
{
    /* Put this script on the StartingPoint, together with a 
       ScriptParams("AmbienceControl") link to the AmbienceController */
    function OnObjRoomTransit() {
        if (message().ObjType != eObjType.kPlayer) return;

        local controller = Object.Named("AmbienceController");
        if (! controller) return;

        local room = message().ToObjId;
        local region = "";
        if ((room != 0) 
            && (Property.Possessed(room, "Ambient")))
        {
            region = Property.Get(room, "Ambient", "Schema Name").toupper();
        }

        print("Player did enter room " + Object_Description(room));
        PostMessage(controller, "RegionChange", region);
    }
}


class DebugNextAmbience extends SqRootScript
{
    /* For a debug inv object that allows the player to change the progress. */
    function OnFrobInvEnd() {
        local controller = Object.Named("AmbienceController");
        if (! controller) return;
        SendMessage(controller, "DebugNextProgress");
    }
}
