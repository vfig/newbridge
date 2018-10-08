// FIXME: don't forget to set RoomCanal ambience back to Streets!

enum eAmbienceProgress {
    kMissionStart,
    //... one for each plot variable
    kRitualStopped,
}

class AmbienceController extends SqRootScript
{
    /* Put this on a marker named 'AmbienceController'. */

    REGIONS = {
        CANAL = [
            ["dinner_bell", "dinner_bell", "dinner_bell"],
            // ... one for each progress state;
        ],

        STREETS = [
            ["lostcity", "lostcity", "creaks1"],
            // ... one for each progress state;
        ],
        // ... one for each region
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

    function OnProgressChange() {
        // FIXME
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
        SendMessage(controller, "RegionChange", region);
    }
}
