class Controller extends SqRootScript
{
    function PunchUp(message, data = 0)
    {
        local master = LinkDest(Link.GetOne("~ScriptParams", self));
        if (master != 0) {
            // print("PUNCHUP: " + Object_Description(self)
            //     + " is punching up " + message + "(" + data + ")"
            //     + " to " + Object_Description(master));
            SendMessage(master, message, data);
        } else {
            print("PUNCHUP ERROR: " + Object_Description(self) + " has no master!");
        }
    }

    function PunchDown(message, data = 0)
    {
        local links = Link.GetAll("ScriptParams", self);
        local children = [];
        foreach (link in links) {
            children.append(LinkDest(link));
        }
        foreach (child in children) {
            // print("PUNCHDOWN: " + Object_Description(self)
            //     + " is punching down " + message + "(" + data + ")"
            //     + " to " + Object_Description(child));
            SendMessage(child, message, data);
        }
    }
}


class Controlled extends SqRootScript
{
    function PunchUp(message, data = 0)
    {
        local master = LinkDest(Link.GetOne("~ScriptParams", self));
        if (master != 0) {
            // print("PUNCHUP: " + Object_Description(self)
            //     + " is punching up " + message + "(" + data + ")"
            //     + " to " + Object_Description(master));
            SendMessage(master, message, data);
        } else {
            print("PUNCHUP ERROR: " + Object_Description(self) + " has no master!");
        }
    }
}


class RitualMasterController extends Controller
{
    /* The overall ritual process is signalled by these messages:

            RitualBegin:
                The ritual has started.
            RitualEnd:
                The ritual reached its conclusion.
            RitualAbort:
                The ritual was stopped by the player

        Each stage of the ritual is signalled by these messages, with
        the current stage number as the data of each:

            RitualRound:
                The lights go off etc.
                Everyone walks to the next vertex.

            RitualPause:
                The performer turns to face the altar.
                The extras face the altar and ululate.

            RitualDown:
                The performer walks to the altar.
                The lights come on etc.

            RitualBless:
                The performer waves the hand over the altar and chants.
                (The ritual ends here mid-blessing if it's at the last stage)

            RitualReturn:
                The performer walks back to the vertex.

        Each step is begun by the master sending a Ritual<whatever>
        message to the other controllers. Each step ends when the master
        sends the next Ritual<whatever> to the other controllers (usually in
        response to messages from the performer controller).
    */

    // Vertices in the order that the performer should visit them.
    // Can tweak this to adjust the ritual timing in very large increments.
    // Timing can also be tweaked more generally with M-RitualTrance Creature Time Warp.
    // But the last entry must be 6, because that's the head.
    // FIXME: might in fact want to adjust time warp for Normal difficulty
    // FIXME: If the stages are changed, also need to adjust the Ritual tags in the conv schema.
    //stages = [0, 1, 2, 3, 4, 5, 6]; // very fast
    stages = [2, 5, 1, 4, 0, 3, 6]; // With time warp 1.5, this takes 5:20 to complete.
    //stages = [4, 2, 0, 5, 3, 1, 6]; // very slow

    // Status of the ritual
    // FIXME: the following status stuff needs to be GetData/SetData'd so it saves and loads
    is_running = false;
    current_index = 0; // Index into stages
    current_stage = 0; // Current stage vertex

    // FIXME: need to handle the various ways the ritual can be interrupted too, and stop the script then.

    function OnTurnOn()
    {
        // FIXME: check GetData for is_running
        if (! is_running) {
            is_running = true;
            Begin();
        } else {
            // FIXME: for testing only:
            Finish();
            // Abort();
        }
    }

    function Begin()
    {
        // FIXME: check GetData for current index? Or do we just resume somehow or something?
        current_index = 0;
        current_stage = stages[current_index];
        print("RITUAL: Begin");
        PunchDown("RitualBegin", current_stage);
        print("RITUAL: Index " + current_index + " is stage " + current_stage);

        // Seven times rounds and seven times downs - always begin with a round.
        print("RITUAL: Round " + current_stage);
        PunchDown("RitualRound", current_stage);
    }

    function End()
    {
        print("RITUAL: End");
        PunchDown("RitualEnd", current_stage);

        // FIXME: conclude the ritual
        print("RITUAL DEATH: run out of busywork!");
        Object.Destroy(self);
    }

    function Abort()
    {
        // FIXME: stop the ritual and make di rupo react
        print("RITUAL DEATH: look ma no hands!");
        Object.Destroy(self);
    }

    // ---- Messages from child controllers

    function OnPerformerReachedVertex()
    {
        // Time for a pause
        print("RITUAL: Pause " + current_stage);
        PunchDown("RitualPause", current_stage);
    }

    function OnPerformerFacedAltar()
    {
        // Time for a down
        print("RITUAL: Down " + current_stage);
        PunchDown("RitualDown", current_stage);
    }

    function OnPerformerReachedAltar()
    {
        // Time for a bless
        print("RITUAL: Bless " + current_stage);
        PunchDown("RitualBless", current_stage);
    }

    function OnPerformerFinishedBlessing()
    {
        // Check if it's the final stage:
        if (current_index < stages.len() - 1) {
            // Time for a return
            print("RITUAL: Return " + current_stage);
            PunchDown("RitualReturn", current_stage);
        } else {
            // Time for a grand finale
            End();
        }
    }

    function OnPerformerReturnedToVertex()
    {
        // On to the next stage
        current_index = current_index + 1;
        if (current_index >= stages.len()) {
            print("RITUAL DEATH: me am go too far!");
            Object.Destroy(self);
        }
        current_stage = stages[current_index];
        print("RITUAL: Index " + current_index + " is stage " + current_stage);

        // Time for the next round
        print("RITUAL: Round " + current_stage);
        PunchDown("RitualRound", current_stage);
    }

    // ---- Messages of abort conditions

    function OnPerformerNoticedHandMissing()
    {
        print("RITUAL: Hand has been stolen");
        Abort();
    }
}


class RitualPerformer extends Controlled
{
    function OnPatrolPoint()
    {
        // Tell the controller we've reached another patrol point (not necessarily the right one)
        local trol = message().patrolObj;
        PunchUp("PerformerPatrolPoint", trol);
    }

    function OnStartWalking()
    {
        PunchUp("PerformerFacedAltar");
    }

    function OnUnpocketHand()
    {
        // Transfer the Hand to the Alt location, and make it unfrobbable
        local link = Link.GetOne("Contains", self);
        if (link != 0) {
            local hand = LinkDest(link);
            Link_SetContainType(link, eContainType.kContainTypeAlt);
            Object_AddFrobAction(hand, eFrobAction.kFrobActionIgnore);

            // Tell the controller about it
            PunchUp("PerformerReachedAltar");
        } else {
            // The hand's been stolen: tell the controller
            PunchUp("PerformerNoticedHandMissing");
        }
    }

    function OnPocketHand()
    {
        // Put the Hand back on the belt, and make it frobbable again
        local link = Link.GetOne("Contains", self);
        if (link != 0) {
            local hand = LinkDest(link);
            Link_SetContainType(link, eContainType.kContainTypeBelt);
            Object_RemoveFrobAction(hand, eFrobAction.kFrobActionIgnore);
        }

        // Tell the controller about it
        PunchUp("PerformerFinishedBlessing");
    }

    function OnConversationFinished()
    {
        // Tell the controller we've finished going down
        PunchUp("PerformerReturnedToVertex");
    }
}


class RitualPerformerController extends Controller
{
    performer = 0;
    rounds = [];
    downs = [];

    function OnSim()
    {
        if (message().starting) {
            // Get linked entities and check they're all accounted for.
            performer = Link_GetScriptParamsDest("Performer", self);
            rounds = Link_GetAllScriptParamsDests("Patrol", self);
            downs = Link_GetAllScriptParamsDests("Conv", self);
            if (performer == 0) {
                print("RITUAL DEATH: no performer.");
                Object.Destroy(self);
            }
            if (rounds.len() != 7) {
                print("RITUAL DEATH: incorrect number of rounds.");
                Object.Destroy(self);
            }
            if (downs.len() != 7) {
                print("RITUAL DEATH: incorrect number of downs.");
                Object.Destroy(self);
            }
        }
    }

    // ---- Messages from the master for the whole ritual

    function OnRitualBegin()
    {
        print("PERFORMER CTL: RitualBegin");
        local stage = message().data;
        local trol = rounds[stage];
        SetPatrolTarget(trol);
        Link_SetCurrentPatrol(performer, trol);
        print("PERFORMER CTL: Starting trance");
        Object.AddMetaProperty(performer, "M-DoesPatrol");
        Object.AddMetaProperty(performer, "M-RitualTrance");
    }

    function OnRitualEnd()
    {
        // Wake the performer from her trance
        Object.RemoveMetaProperty(performer, "M-DoesPatrol");
        Object.RemoveMetaProperty(performer, "M-RitualTrance");

        // FIXME: make the performer play a victory conversation. Maybe she can do the spinny dance!!
    }

    function OnRitualAbort()
    {
        // FIXME - we need to send *back* to the master controller when
        // the perform notices the Hand missing (when about to use it),
        // or the Anax missing (when the lights are on), and then the
        // master controller can abort the whole thing.

        // Kill all the conversations
        foreach (down in downs) {
            SendMessage(down, "TurnOff");
        }

        // Wake the performer from her trance
        Object.RemoveMetaProperty(performer, "M-DoesPatrol");
        Object.RemoveMetaProperty(performer, "M-RitualTrance");
    }

    // ---- Messages from the controller for each step

    function OnRitualRound()
    {
        local stage = message().data;
        local trol = rounds[stage];
        print("PERFORMER CTL: Patrolling to " + Object.GetName(trol) + " (" + trol + ") for stage " + stage);
        SetPatrolTarget(trol);
    }

    function OnRitualPause()
    {
        local stage = message().data;
        local down = downs[stage];
        // We call it a down, but really it's a system of a down.
        // The system drives all the facing, the downing, the
        // blessing, and the returning.
        print("PERFORMER CTL: Starting conversation " + Object.GetName(down) + " (" + down + ") for stage " + stage);
        AI.StartConversation(down);
    }

    // ---- Messages from the performer

    function OnPerformerPatrolPoint()
    {
        local trol = message().data;
        if (trol == GetPatrolTarget()) {
            print("PERFORMER CTL: reached target: " + Object.GetName(trol) + " (" + trol + ")");
            PunchUp("PerformerReachedVertex");
        } else {
            print("PERFORMER CTL: reached troll trol: " + Object.GetName(trol) + " (" + trol + ")");
        }
    }

    function OnPerformerFacedAltar()
    {
        PunchUp(message().message);
    }

    function OnPerformerReachedAltar()
    {
        PunchUp(message().message);
    }

    function OnPerformerFinishedBlessing()
    {
        PunchUp(message().message);
    }

    function OnPerformerReturnedToVertex()
    {
        PunchUp(message().message);
    }

    function OnPerformerNoticedHandMissing()
    {
        PunchUp(message().message);
    }

    // ---- Utilities

    function GetPatrolTarget()
    {
        local link = Link.GetOne("Route", self);
        if (link != 0) {
            return LinkDest(link);
        } else {
            return 0;
        }
    }

    function SetPatrolTarget(trol)
    {
        print("PERFORMER CTL: new target is: " + Object.GetName(trol) + " (" + trol + ")");
        Link_DestroyAll("Route", self);
        if (trol != 0) {
            Link.Create("Route", self, trol);
        }
    }
}


class RitualLightingController extends Controller
{
    lights = [];
    strips = [];

    function OnSim()
    {
        if (message().starting) {
            // Get linked entities and check they're all accounted for.
            lights = Link_GetAllScriptParamsDests("Light", self);
            strips = Link_GetAllScriptParamsDests("Strip", self);
            if (lights.len() != 7) {
                print("RITUAL DEATH: incorrect number of lights.");
                Object.Destroy(self);
            }
            if (strips.len() != 7) {
                print("RITUAL DEATH: incorrect number of strips.");
                Object.Destroy(self);
            }
        }
    }

    // ---- Messages from the master for the whole ritual

    function OnRitualBegin()
    {
        print("LIGHTING CTL: RitualBegin");
    }

    function OnRitualEnd()
    {
        // FIXME: make the lights flash!
    }

    function OnRitualAbort()
    {
        // FIXME: need to turn off the lights?
    }

    // ---- Messages from the controller for each step

    function OnRitualDown()
    {
        local stage = message().data;
        local light = lights[stage];
        local strip = strips[stage];
        SendMessage(light, "TurnOn");
        SendMessage(strip, "TurnOn");
    }

    function OnRitualReturn()
    {
        local stage = message().data;
        local light = lights[stage];
        SendMessage(light, "TurnOff");
    }
}


class RitualVictimController extends Controller
{
    victim = 0;
    gores = [];


    function OnSim()
    {
        if (message().starting) {
            victim = Link_GetScriptParamsDest("Victim", self);
            gores = Link_GetAllScriptParamsDests("Gore", self);
            if (victim == 0) {
                print("RITUAL DEATH: no victim.");
                Object.Destroy(self);
            }
            if (gores.len() != 7) {
                print("RITUAL DEATH: incorrect number of gores.");
                Object.Destroy(self);
            }

            // Make sure the gores aren't "there" initially.
            foreach (gore in gores) {
                Object.AddMetaProperty(gore, "M-NotHere");
            }
        }
    }

    // ---- Messages from the master for the whole ritual

    function OnRitualBegin()
    {
        print("VICTIM CTL: RitualBegin");
    }

    function OnRitualEnd()
    {
        // Destroy the victim, and bring out the gores
        Object.Destroy(victim);
        foreach (gore in gores) {
            Object.RemoveMetaProperty(gore, "M-NotHere");
        }

        ExplodeVictim();
    }

    function OnRitualAbort()
    {
    }

    function ExplodeVictim()
    {
        // Fling body parts everywhere, why don't you?
        local z_angles = [141.429, 192.857, 244.286, 295.714, 347.143, 38.571, 90.0];
        for (local i = 0; i < gores.len(); i++) {
            local gore = gores[i];

            // Calculate launch vector
            local a = z_angles[i]  * 3.14 / 180;
            local vel = vector(cos(a), sin(a), 1);
            vel.Normalize();
            vel.Scale(30.0);

            // Deactivate the physics controls
            if (! Physics.ValidPos(gore)) {
                print("RITUAL ERROR: gore " + i + " not in valid position!");
                continue;
            } else {
                Property.Set(gore, "PhysControl", "Controls Active", 0);
            }

            // And launch!
            Physics.Activate(gore);
            Physics.SetVelocity(gore, vel);
        }
    }
}


// FIXME: extras: We need a plan to deal with
// 0 - 6 extras, and space them out around the ritual area accordingly.
// This probably means a bunch of extra disconnected patrol points to send them to
// (patrol points so that we can replace the current link, and they'll automatically
// return when settling down after alerted)


class RitualFloorStrip extends SqRootScript
{
    /* When turned on, brighten up and pulse illumination. */

    is_on = false;
    selfillum = 0.0; // 0...1
    selfillum_off = 0.0;
    selfillum_min = 0.125;
    selfillum_max = 0.375;
    period = 2.0;
    direction = 1.0;
    previous_time = 0;

    function OnTurnOn()
    {
        if (! is_on) {
            is_on = true;
            // Make sure we're animating
            direction = 1.0;
            previous_time = message().time;
            SetFlickering(true);
        }
    }

    function OnTurnOff()
    {
        if (is_on) {
            is_on = false;
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

        // Calculate the selfillum change corresponding to the elapsed time
        local min = (is_on ? selfillum_min : selfillum_off);
        local max = selfillum_max;
        selfillum = selfillum + ((max - min) * direction * elapsed / period);
        if (direction == -1.0 && selfillum < min) {
            selfillum = min;
            direction = 1.0;
        } else if (direction == 1.0 && selfillum > max) {
            selfillum = max;
            direction = -1.0;
        }

        // Stop updates if we've reached minimum and we're turned off
        if ((! is_on) && (selfillum == selfillum_off)) {
            SetFlickering(false);
        }

        // Self-illuminate accordingly
        Property.Set(self, "ExtraLight", "Amount (-1..1)", selfillum);
    }

    function SetFlickering(on) {
        // Turn on or off the flicker tweq
        local animS = Property.Get(self, "StTweqBlink", "AnimS");
        local newAnimS = (on ? (animS | 1) : (animS & ~1));
        Property.Set(self, "StTweqBlink", "AnimS", newAnimS);
    }
}
