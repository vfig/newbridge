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

class MysticGauge extends SqRootScript
{
    /* The Mystic Gauge always points towards its target when dropped!
        Just give it a ControlDevice link to the target, and put the
        MysticGaugeTarget script onto the target too (if you want the
        gauge to stop working when the target is picked up). */

    target = 0;
    wild_mode = false;
    dead_mode = false;

    function OnSim()
    {
        if (message().starting) {
            // Find out what we're targeting
            local link = Link.GetOne("ControlDevice", self);
            target = LinkDest(link);
            if (target == 0) {
                SetDeadMode();
            }

            Physics.SubscribeMsg(self, ePhysScriptMsgType.kFellAsleepMsg);
        } else {
            Physics.UnsubscribeMsg(self, ePhysScriptMsgType.kFellAsleepMsg);
        }
    }

    function OnPhysFellAsleep()
    {
        // We've hit the floor, so we need to update the pointer
        Update();
    }

    function OnTargetPickedUp()
    {
        // The target has been picked up, so we die forever.
        SetDeadMode();
        Update();
    }

    function SetWildMode(wild) {
        if (wild_mode != wild) {
            wild_mode = wild;
            if (wild) {
                // No limits!
                local animC = Property.Get(self, "CfgTweqJoints", "Joint1AnimC");
                Property.Set(self, "CfgTweqJoints", "Joint1AnimC", (animC | 1));
                local curveC = Property.Get(self, "CfgTweqJoints", "Joint1CurveC");
                Property.Set(self, "CfgTweqJoints", "Joint1CurveC", (curveC & ~2));
                // And spin wildly!
                Property.Set(self, "CfgTweqJoints", "    rate-low-high", vector(160.0, 0.0, 360.0));
            } else {
                // Okay, we want limits, and we want jitter.
                local animC = Property.Get(self, "CfgTweqJoints", "Joint1AnimC");
                Property.Set(self, "CfgTweqJoints", "Joint1AnimC", (animC & ~1));
                local curveC = Property.Get(self, "CfgTweqJoints", "Joint1CurveC");
                Property.Set(self, "CfgTweqJoints", "Joint1CurveC", (curveC | 2));
            }
        }
    }

    function SetDeadMode() {
        if (! dead_mode) {
            dead_mode = true;

            // Okay, we want limits, but no jitter
            local animC = Property.Get(self, "CfgTweqJoints", "Joint1AnimC");
            Property.Set(self, "CfgTweqJoints", "Joint1AnimC", (animC & ~1));
            local curveC = Property.Get(self, "CfgTweqJoints", "Joint1CurveC");
            Property.Set(self, "CfgTweqJoints", "Joint1CurveC", (curveC &~ 2));
            // And sit at zero forever
            Property.Set(self, "CfgTweqJoints", "    rate-low-high", vector(1000.0, 0.0, 0.0));
        }
    }

    function Update()
    {
        if (target == 0 || dead_mode) {
            return;
        }

        const max_distance = 512.0;
        const min_distance = 64.0;
        local target_pos = Object.Position(target);
        local my_pos = Object.Position(self);
        local my_facing = Object.Facing(self);
        local distance = sqrt(pow(target_pos.x - my_pos.x, 2) + pow(target_pos.y - my_pos.y, 2));
        if (distance < min_distance) {
            SetWildMode(true);
        } else {
            SetWildMode(false);
            local heading = (atan2(target_pos.x - my_pos.x, target_pos.y - my_pos.y) * 180.0 / PI);
            local gauge = 135.0 + my_facing.z + heading;
            local clamped_distance = (distance > max_distance ? max_distance : distance);
            local closeness = (1.0 - ((clamped_distance - min_distance) / (max_distance - min_distance)));
            local inaccuracy = (closeness * 90.0) + 10.0;
            local agitation = (closeness * 50.0) + 5.0;
            Property.Set(self, "CfgTweqJoints", "    rate-low-high", vector(agitation, gauge - inaccuracy, gauge + inaccuracy));
        }
    }
}

class MysticGaugeTarget extends SqRootScript
{
    /* Notifies the Mystic Gauge that this item has been picked up by the player. */

    function OnContained()
    {
        if ((message().container == Object.Named("Player"))
            && (message().event == eContainsEvent.kContainAdd)) {
            Link.BroadcastOnAllLinks(self, "TargetPickedUp", "~ControlDevice");
        }   
    }
}