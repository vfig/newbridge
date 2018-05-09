class SanctBell extends SqRootScript
{
    function OnSlashStimStimulus()
    {
        # Rung by a sword
        Ring();
    }

    function OnPokeStimStimulus()
    {
        # Rung by an arrow
        Ring();
    }

    function OnBashStimStimulus()
    {
        # Rung by a blackjack
        Ring();
    }

    function Ring()
    {
        local schema = "m20sanctbell";
        Sound.PlaySchemaAtObject(self, schema, self);
    }
}

enum HotStuffState {
    idle = 0,
    lowering = 1,
    pour_starting = 2,
    pouring = 3,
    pour_ending = 4,
    raising = 5
}
class HotStuff extends SqRootScript
{
    /* Someone's pouring molten steel onto the floor! That's unsafe. */

    state = HotStuffState.idle;

    function OnTurnOn()
    {
        if (state == HotStuffState.idle) {
            DoLowering();
        } else if (state == HotStuffState.raising) {
            DoLowering();
        } else if (state == HotStuffState.pour_ending) {
            DoPourStarting();
        }
    }

    function OnTurnOff()
    {
        if (state == HotStuffState.pouring) {
            DoPourEnding();
        } else if (state == HotStuffState.lowering) {
            DoRaising();
        } else if (state == HotStuffState.pour_starting) {
            DoPourEnding();
        }
    }

    function OnTweqComplete()
    {
        if (state == HotStuffState.lowering) {
            DoPourStarting();
        } else if (state == HotStuffState.pour_starting) {
            DoPouring();
        } else if (state == HotStuffState.pour_ending) {
            DoRaising();
        } else if (state == HotStuffState.raising) {
            DoIdle();
        }
    }

    function DoIdle()
    {
        state = HotStuffState.idle;
    }

    function DoLowering()
    {
        state = HotStuffState.lowering;
        SetJointsTweqing(true, true);
    }

    function DoPourStarting()
    {
        state = HotStuffState.pour_starting;
        SetModelsTweqing(true, true);
    }

    function DoPouring()
    {
        state = HotStuffState.pouring;
        Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
    }

    function DoPourEnding()
    {
        state = HotStuffState.pour_ending;
        Link.BroadcastOnAllLinks(self, "TurnOff", "ControlDevice");
        SetModelsTweqing(true, false);
    }

    function DoRaising()
    {
        state = HotStuffState.raising;
        SetJointsTweqing(true, false);
    }

    function SetJointsTweqing(on, forward)
    {
        local animS = Property.Get(self, "StTweqJoints", "AnimS");
        if (on) {
            if (forward) {
                animS = ((animS | 1) & ~2);
            } else {
                animS = (animS | 3);
            }
        } else {
            animS = (animS & ~1);
        }
        Property.Set(self, "StTweqJoints", "AnimS", animS);
    }

    function SetModelsTweqing(on, forward)
    {
        local animS = Property.Get(self, "StTweqModels", "AnimS");
        if (on) {
            if (forward) {
                animS = ((animS | 1) & ~2);
            } else {
                animS = (animS | 3);
            }
        } else {
            animS = (animS & ~1);
        }
        Property.Set(self, "StTweqModels", "AnimS", animS);
    }
}

class M20HotPlate extends SqRootScript
{
    /* Extends physical contact into Act/React contact. */

    function OnSim()
    {
        if (message().starting) {
            Physics.SubscribeMsg(self, ePhysScriptMsgType.kContactMsg);
        } else {
            Physics.UnsubscribeMsg(self, ePhysScriptMsgType.kContactMsg);
        }
    }

    function OnPhysContactCreate()
    {
        ActReact.BeginContact(self, message().contactObj);
    }

    function OnPhysContactDestroy()
    {
        ActReact.EndContact(self, message().contactObj);
    }
}

class M20HotPlateController extends SqRootScript
{
    /* Turns on or off one or more M20HotPlates linked with ControlDevice. */

    intensity = 0.0;
    period = 5.0;
    direction = 1.0;
    previous_time = 0;

    function OnTurnOn()
    {
        if (intensity < 1.0) {
            direction = 1.0;
            previous_time = message().time;
            SetFlickering(true);
        }
    }

    function OnTurnOff()
    {
        if (intensity > 0.0) {
            direction = -1.0;
            previous_time = message().time;
            SetFlickering(true);
        }
    }

    function OnTweqComplete()
    {
        // Figure out how much time has passed since the last update
        local time = message().time
        local elapsed = (time - previous_time) / 1000.0;
        if (elapsed < 0) {
            elapsed = 0;
        } else if (elapsed > period) {
            elapsed = period;
        }
        previous_time = time;

        // Calculate the intensity change corresponding to the elapsed time
        intensity = intensity + (direction * elapsed / period);
        if (intensity < 0.0) {
            intensity = 0.0;
        } else if (intensity > 1.0) {
            intensity = 1.0;
        }

        // Apply the intensity to linked objects
        ApplyIntensity();

        // Stop updates if we've reached minimum or maximum intensity
        if (intensity == 0.0 || intensity == 1.0) {
            SetFlickering(false);
        }
    }

    function SetFlickering(on) {
        // Turn on or off the flicker tweq
        local animS = Property.Get(self, "StTweqBlink", "AnimS");
        local newAnimS = (on ? (animS | 1) : (animS & ~1));
        Property.Set(self, "StTweqBlink", "AnimS", newAnimS);
    }

    function ApplyIntensity()
    {
        local links = Link.GetAll("ControlDevice", self);
        local heat = Object.Named("HotPlateHeat");

        foreach (link in links) {
            local hotplate = LinkDest(link);            

            // Self-illuminate according to the intensity
            Property.Set(hotplate, "ExtraLight", "Amount (-1..1)", intensity);

            // Add and remove heat as appropriate
            local has_heat = Object.HasMetaProperty(hotplate, heat);
            if (intensity >= 0.25 && ! has_heat) {
                Object.AddMetaProperty(hotplate, heat);
            } else if (intensity <= 0.25 && has_heat) {
                Object.RemoveMetaProperty(hotplate, heat);
            }
        }
    }
}