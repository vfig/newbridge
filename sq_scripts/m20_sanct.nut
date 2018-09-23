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
        const min_distance = 48.0;
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
            local inaccuracy = ((1.0 - closeness) * 90.0) + 10.0;
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

class PickUpWeapon extends SqRootScript
{
    /* Make an AI (hammerites only for now) run to pick up a weapon (hammers
       only for now) when high alerted.

       Put this script on an AI, and give them a ScriptParams(PickUpWeapon) link
       to a Warhammer they can "pick up".
    */

    function OnHighAlert()
    {
        local link = Link_GetOneScriptParams("PickUpWeapon", self);
        local weapon = ((link != 0) ? LinkDest(link) : 0);
        // Destroy the link so we never try to pick up the weapon again.
        Link.Destroy(link);

        if (weapon == 0) {
            // Can't find a weapon, so I'll just be a coward instead.
            // (or maybe I've already picked one up?)
        } else {
            // Poop out a marker where we got alerted from, and keep a link to it.
            local pos = Object.Position(self);
            local marker = Object.BeginCreate("Marker");
            if (marker != 0) {
                Object.Teleport(marker, vector(0,0,0), vector(0,0,0), self);
                Object.EndCreate(marker);
                local link = Link.Create("ScriptParams", self, marker);
                LinkTools.LinkSetData(link, "", "PUWOrigin");
            }

            // Run to the weapon.
            // High priority so that it overrides the AI's desire to attack us bare-handed!
            AI.MakeGotoObjLoc(self, weapon, eAIScriptSpeed.kFast,
                eAIActionPriority.kHighPriorityAction, "PUWToWeapon");
        }
    }

    function OnObjActResult()
    {
        // After running to the weapon...
        if ((message().action == eAIAction.kAIGoto)
            // FIXME: "the index 'result' does not exist ?!?
            // So if we can't path to the weapon, we'll just magically get it. Okay!
            /* && (message().result = eAIActionResult.kActionDone) */
            && (message().actdata == "PUWToWeapon"))
        {
            // Pick up the weapon. It's a trick: actually we destroy the weapon and
            // polymorphise into a Hammerite-with-a-hammer.
            local weapon = message().target;
            if (weapon != 0) {
                Property.Set(self, "ModelName", "", "exphamh4");
                Object.Destroy(weapon);
            }

            // Check for a pooped marker
            local link = Link_GetOneScriptParams("PUWOrigin", self);
            local marker = ((link != 0) ? LinkDest(link) : 0);
            // Destroy the link so we never try to run to the marker again.
            Link.Destroy(link);

            // If we can see the player, forget the marker; otherwise
            // run back to it, cause they're probably somewhere around there, right?
            local player = Object.Named("Player");
            local awareness = Link.GetOne("AIAwareness", self, player);
            if ((awareness != 0)
                && Awareness_HaveLOS(awareness))
            {
                Object.Destroy(marker);
            } else {
                AI.MakeGotoObjLoc(self, marker, eAIScriptSpeed.kFast,
                    eAIActionPriority.kNormalPriorityAction, "PUWToMarker");
            }

        // After running back to the marker...
        } else if ((message().action == eAIAction.kAIGoto)
            && (message().actdata == "PUWToMarker"))
        {
            // Get rid of the marker now that we're here.
            local marker = message().target;
            if (marker != 0) {
                Object.Destroy(marker);
            }
        }
    }

    function Awareness_HaveLOS(link)
    {
        local flags = LinkTools.LinkGetData(link, "Flags");
        return ((flags & 0x08) != 0); // "HaveLOS"
    }
}


class MarathonRunner extends SqRootScript
{
    function OnHighAlert()
    {
        SetData("MarathonStarted", GetTime());
    }

    function OnObjActResult()
    {
        // After running to a weapon...
        if ((message().action == eAIAction.kAIGoto)
            && (message().actdata == "PUWToWeapon"))
        {
            local started = GetData("MarathonStarted");
            local ended = GetTime();
            local duration = (ended - started).tointeger();
            if (duration > 60) {
                // So, if I don't manage to do some of the bonus objectives, rather than
                // rework the objective scripting, just repurpose them and make this a
                // bonus objective as an easter egg.
                print("Congratulations, you made " + Object_Description(self) + " run a marathon for " + duration + " seconds!");
            }
        }
    }
}

class SlidingBanner extends SqRootScript {
    function OnTurnOn() {
        SlideBanner(true);
    }

    function OnTurnOff() {
        SlideBanner(false);
    }

    function ToggleBanner() {
        local animS = Property.Get(self, "StTweqModels", "AnimS");
        local isTurnedOn = ((animS & 2) == 0);
        SlideBanner(!isTurnedOn);
    }

    function SlideBanner(open) {
        // Turn on the models tweq, setting the reverse bit according to "open".
        local animS = Property.Get(self, "StTweqModels", "AnimS");
        // Set the On bit.
        animS = (animS | 1);
        // Set or clear the Reverse bit.
        if (open) {
            animS = (animS & ~2)
        } else {
            animS = (animS | 2)
        }
        Property.Set(self, "StTweqModels", "AnimS", animS);
        // If we're not open, then block frob.
        Property.SetSimple(self, "BlockFrob", !open);
    }
}
