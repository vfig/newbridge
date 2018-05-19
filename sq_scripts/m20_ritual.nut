class Controlled extends SqRootScript
{
    function PunchUp(message, data = 0)
    {
        local links = Link.GetAll("~ScriptParams", self);
        local masters = [];
        foreach (link in links) {
            masters.append(LinkDest(link));
        }
        if (masters.len() > 0) {
            foreach (master in masters) {
                // print("PUNCHUP: " + Object_Description(self)
                //     + " is punching up " + message + "(" + data + ")"
                //     + " to " + Object_Description(master));
                SendMessage(master, message, data);
            }
        } else {
            print("PUNCHUP ERROR: " + Object_Description(self) + " has no masters!");
        }
    }
}

class Controller extends Controlled
{
    function PunchDown(message, data = 0)
    {
        local links = Link.GetAll("ScriptParams", self);
        local children = [];
        foreach (link in links) {
            children.append(LinkDest(link));
        }
        if (children.len() > 0 ) {
            foreach (child in children) {
                // print("PUNCHDOWN: " + Object_Description(self)
                //     + " is punching down " + message + "(" + data + ")"
                //     + " to " + Object_Description(child));
                SendMessage(child, message, data);
            }
        } else {
            print("PUNCHDOWN ERROR: " + Object_Description(self) + " has no children!");
        }
    }
}

enum eRitualStatus {
    kRitualNotStarted       = 0,
    kRitualBegun            = 1,
    kRitualEnded            = 2,
    kRitualAborted          = 3,
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
    status = eRitualStatus.kRitualNotStarted;
    current_index = 0; // Index into stages
    current_stage = 0; // Current stage vertex

    // FIXME: need to handle the various ways the ritual can be interrupted too, and stop the script then.

    function OnTurnOn()
    {
        // FIXME: check GetData for status
        if (status == eRitualStatus.kRitualNotStarted) {
            Begin();
        } else {
            // FIXME: for testing only:
            End();
            // Abort();
        }
    }

    function Begin()
    {
        if (status == eRitualStatus.kRitualNotStarted) {
            status = eRitualStatus.kRitualBegun;

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
    }

    function End()
    {
        if (status == eRitualStatus.kRitualBegun) {
            status = eRitualStatus.kRitualEnded;

            print("RITUAL: End");
            PunchDown("RitualEnd", current_stage);

            // FIXME: objectives tie in

            print("RITUAL DEATH: Beware! The Prophet has returned!");
            Object.Destroy(self);
        }
    }

    function Abort()
    {
        if (status == eRitualStatus.kRitualBegun) {
            status = eRitualStatus.kRitualAborted;

            print("RITUAL: Abort");
            PunchDown("RitualAbort", current_stage);

            // FIXME: objectives tie-in

            print("RITUAL DEATH: Well done, you stopped the ritual!");
            Object.Destroy(self);
        }
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

    function OnPerformerNoticedHandMissing()
    {
        print("RITUAL: Victim has been unkidnapped");
        Abort();
    }

    function OnPerformerAlerted()
    {
        print("RITUAL: Performer alerted");
        Abort();
    }

    function OnPerformerBrainDead()
    {
        print("RITUAL: Performer is brain dead");
        Abort();
    }
}


class RitualPerformer extends Controlled
{

    function OnNoticedVictimMissing()
    {
        PunchUp("PerformerNoticedVictimMissing");
    }

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
        local hand = Link_GetScriptParamsDest("Hand", self);
        if (hand != 0) {
            local link = Link.GetOne("Contains", self, hand);
            if (link != 0) {
                Link_SetContainType(link, eContainType.kContainTypeAlt);
                Object_AddFrobAction(hand, eFrobAction.kFrobActionIgnore);

                // Tell the controller about it
                PunchUp("PerformerReachedAltar");
            } else {
                // The hand's been stolen: tell the controller
                PunchUp("PerformerNoticedHandMissing");
            }
        } else {
            // The hand's been stolen: tell the controller
            PunchUp("PerformerNoticedHandMissing");
        }
    }

    function OnPocketHand()
    {
        // Put the Hand back on the belt, and make it frobbable again
        local hand = Link_GetScriptParamsDest("Hand", self);
        if (hand != 0) {
            local link = Link.GetOne("Contains", self, hand);
            if (link != 0) {
                Link_SetContainType(link, eContainType.kContainTypeBelt);
                Object_RemoveFrobAction(hand, eFrobAction.kFrobActionIgnore);
            }
        }

        // Tell the controller about it
        PunchUp("PerformerFinishedBlessing");
    }

    function OnConversationFinished()
    {
        // Tell the controller we've finished going down
        PunchUp("PerformerReturnedToVertex");
    }

    function OnAlertness()
    {
        // The performer's trance prevents them from noticing the player ordinarily,
        // so they'll only alert in extreme conditions or when scripted.
        if (message().level >= eAIScriptAlertLevel.kModerateAlert) {
            PunchUp("PerformerAlerted");
        }
    }

    function OnHighAlert()
    {
        // The performer's trance prevents them from noticing the player ordinarily,
        // so they'll only alert in extreme conditions or when scripted.
        if (message().level >= eAIScriptAlertLevel.kModerateAlert) {
            PunchUp("PerformerAlerted");
        }
    }

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            PunchUp("PerformerBrainDead");
        }
    }

    function OnDrawDagger()
    {
        local dagger = Link_GetScriptParamsDest("Dagger", self);
        if (dagger != 0) {
            // Dagger's already there, just not rendered! So render it.
            Property.Set(dagger, "HasRefs", "", true);
        }
    }
}


class RitualVictim extends SqRootScript
{
    // Basically an altered version of GoMissing to spawn
    // our specific MissingRitualVictim instead of the usual MissingLoot.
    function OnFrobWorldEnd()
    {
        if (! IsDataSet("OutOfPlace")) {
            local newobj = Object.Create("MissingRitualVictim");
            Object.Teleport(newobj, vector(0,0,0), vector(0,0,0), self);
            Property.Set(newobj, "SuspObj", "Is Suspicious", true);
            //Property.Set(newobj, "SuspObj", "Suspicious Type", "missingbody");
            SetData("OutOfPlace", true);
        }
    }
}


class MissingRitualVictim extends SqRootScript
{
    // Basically an altered version of WatchMe to create
    // watch links to our ritual participants instead of just
    // all humans. Beasts have feelings too after all!
    function OnBeginScript()
    {
        if (! IsDataSet("Init")) {
            Link.CreateMany("AIWatchObj", "@M-RitualParticipant", self);
            SetData("Init", true);
        }
    }
}


class RitualPerformerController extends Controller
{
    performer = 0;
    rounds = [];
    downs = [];
    search_trols = [];
    search_convs = [];

    function OnSim()
    {
        if (message().starting) {
            // Get linked entities and check they're all accounted for.
            performer = Link_GetScriptParamsDest("Performer", self);
            rounds = Link_GetAllScriptParamsDests("Round", self);
            downs = Link_GetAllScriptParamsDests("Down", self);
            search_trols = Link_GetAllScriptParamsDests("SearchTrol", self);
            search_trols = Link_CollectPatrolPath(search_trols);
            search_convs = Link_GetAllScriptParamsDests("SearchConv", self);
            if (performer == 0) {
                print("PERFORMER CTL DEATH: no performer.");
                Object.Destroy(self);
            }
            if (rounds.len() != 7) {
                print("PERFORMER CTL DEATH: incorrect number of rounds.");
                Object.Destroy(self);
            }
            if (downs.len() != 7) {
                print("PERFORMER CTL DEATH: incorrect number of downs.");
                Object.Destroy(self);
            }
            if (search_convs.len() == 0) {
                print("PERFORMER CTL DEATH: no search_convs.");
                Object.Destroy(self);
            }

            // Start the performer in a trance so they won't spook
            // at anything before the ritual begins.
            print("PERFORMER CTL: Starting trance");
            Object.AddMetaProperty(performer, "M-RitualTrance");

            // FIXME: for testing only
            Object.AddMetaProperty(performer, "M-GetOnWithIt");
        }
    }

    // ---- Messages from the master for the whole ritual

    function OnRitualBegin()
    {
        local stage = message().data;
        local trol = rounds[stage];
        SetPatrolTarget(trol);
        Link_SetCurrentPatrol(performer, trol);
        print("PERFORMER CTL: Starting patrol");
        Object.AddMetaProperty(performer, "M-DoesPatrol");
    }

    function OnRitualEnd()
    {
        // Kill all the conversations
        foreach (down in downs) {
            SendMessage(down, "TurnOff");
        }

        // Wake the performer from her trance
        Object.RemoveMetaProperty(performer, "M-DoesPatrol");
        Object.RemoveMetaProperty(performer, "M-RitualTrance");

        // FIXME: make the performer play a victory conversation. Maybe she can do the spinny dance!!
    }

    function OnRitualAbort()
    {
        // Wake the performer from her trance
        Object.RemoveMetaProperty(performer, "M-RitualTrance");
        Object.RemoveMetaProperty(performer, "M-DoesPatrol");

        // Kill all the conversations
        foreach (down in downs) {
            SendMessage(down, "TurnOff");
        }

        // Bring out a weapon.
        SendMessage(performer, "DrawDagger");

        // HACK: aborting the conversation by killing an actor or actor link
        // leaves the performer's AI in a weird state. We really don't want that.
        // So instead, we make them play a different conversation which overrides it.
        PlayRandomSearchConv();

        // Make sure the performer will investigate a little before searching.
        // These are singleton links, so don't add them if they're already present!
        local player = Object.Named("Player");
        if (! Link.AnyExist("AIInvest", performer, player)) {
            Link.Create("AIInvest", performer, Object.Named("Player"));
        }
        if (! Link.AnyExist("AIAwareness", performer, player)) {
            Link.Create("AIAwareness", performer, Object.Named("Player"));
        }

        // Even after investigating, the performer should search around endlessly,
        // starting at a random point.
        BeginRandomSearch();
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
        if (GetData("IsSearching")) {
            PlayRandomSearchConv();
        } else {
            local trol = message().data;
            if (trol == GetPatrolTarget()) {
                print("PERFORMER CTL: reached target: " + Object.GetName(trol) + " (" + trol + ")");
                PunchUp("PerformerReachedVertex");
            } else {
                print("PERFORMER CTL: reached troll trol: " + Object.GetName(trol) + " (" + trol + ")");
            }
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

    function OnPerformerNoticedVictimMissing()
    {
        PunchUp(message().message);
    }

    function OnPerformerAlerted()
    {
        PunchUp(message().message);
    }

    function OnPerformerBrainDead()
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

    function BeginRandomSearch()
    {
        print("PERFORMER CTL: Now searching.");
        SetData("IsSearching", true);
        if (search_trols.len() > 0) {
            local i = Data.RandInt(0, (search_trols.len() - 1));
            local target = search_trols[i];
            Link_SetCurrentPatrol(performer, target);
        }
        Object.AddMetaProperty(performer, "M-RitualSearchModerate");
    }

    function PlayRandomSearchConv()
    {
        local i = Data.RandInt(0, (search_convs.len() - 1));
        local conv = search_convs[i];
        print("PERFORMER CTL: Chose random search conv: " + Object_Description(conv));
        AI.StartConversation(conv);
    }
}


class DisableStrobes extends SqRootScript
{
    // Can use a .dml to patch this onto RitualLightingController to disable strobes.
    function OnSim()
    {
        if (message().starting) {
            SendMessage(self, "DisableStrobes");
        }
    }
}

class RitualLightingController extends Controller
{
    lights = [];
    strips = [];
    strobes = [];

    function OnSim()
    {
        if (message().starting) {
            // Get linked entities and check they're all accounted for.
            lights = Link_GetAllScriptParamsDests("Light", self);
            strips = Link_GetAllScriptParamsDests("Strip", self);
            strobes = Link_GetAllScriptParamsDests("Strobe", self);
            if (lights.len() != 7) {
                print("LIGHTING CTL DEATH: incorrect number of lights.");
                Object.Destroy(self);
            }
            if (strips.len() != 7) {
                print("LIGHTING CTL DEATH: incorrect number of strips.");
                Object.Destroy(self);
            }

            // We don't care how many strobes there are, but make sure they're off to begin with
            foreach (strobe in strobes) {
                SendMessage(strobe, "TurnOff");
            }
        }
    }

    function OnDisableStrobes()
    {
        SetData("StrobeDisabled", true);
    }

    // ---- Messages from the master for the whole ritual


    function OnRitualBegin()
    {
    }

    function OnRitualEnd()
    {
        if (GetData("StrobeDisabled")) {
            print("LIGHTING CTL: Strobes are disabled.");
            // Just turn on all the lights.
            foreach (light in lights) {
                SendMessage(light, "TurnOn");
            }
        } else {
            print("LIGHTING CTL: Strobes are enabled.");
            // Make all the strobes flash horrendously
            foreach (light in lights) {
                SendMessage(light, "TurnOff");
            }
            foreach (strobe in strobes) {
                SendMessage(strobe, "TurnOn");
            }
        }
        // And all the strips glow steadily
        foreach (strip in strips) {
            SendMessage(strip, "Fullbright");
        }
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
                print("VICTIM CTL DEATH: no victim.");
                Object.Destroy(self);
            }
            if (gores.len() != 7) {
                print("VICTIM CTL DEATH: incorrect number of gores.");
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
                print("VICTIM CTL ERROR: gore " + i + " not in valid position!");
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

    function OnFullbright()
    {
        // Stop animating
        SetFlickering(false);
        // Self-illuminate fully
        Property.Set(self, "ExtraLight", "Amount (-1..1)", 1.0);
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


class RitualExtraController extends Controller
{
    extras = [];
    trols = [];

    function OnSim()
    {
        if (message().starting) {
            // Get linked entities and check they're all accounted for.
            extras = Link_GetAllScriptParamsDests("Extra", self);
            trols = Link_GetAllScriptParamsDests("Trol", self);
            trols = Link_CollectPatrolPath(trols);
            if (extras.len() == 0) {
                print("EXTRA CTL DEATH: no extras.");
                Object.Destroy(self);
            }
            if (trols.len() != 14) {
                // Needs to be 2x as many as performer round trol points
                // so we can space out the extras roughly evenly
                print("EXTRA CTL DEATH: incorrect number of trols.");
                Object.Destroy(self);
            }

            // FIXME: for testing only
            foreach (extra in extras) {
                Object.AddMetaProperty(extra, "M-GetOnWithIt");
            }
        }
    }

    // ---- Messages from the master for the whole ritual

    function OnRitualBegin()
    {
        local stage = message().data;

        // First positions, everyone
        local available_extras = GetAvailableExtras();
        PickPatrolPoints(stage, available_extras, true);
    }

    function OnRitualEnd()
    {
    }

    function OnRitualAbort()
    {
    }

    // ---- Messages from the controller for each step

    function OnRitualPause()
    {
        // Extras suddenly get a desire to make some noise
    }

    function OnRitualDown()
    {
    }

    function OnRitualBless()
    {
    }

    function OnRitualReturn()
    {
    }

    function OnRitualRound()
    {
        local stage = message().data;
        local available_extras = GetAvailableExtras();
        PickPatrolPoints(stage, available_extras);
    }

    // ---- Messages from the extras

    function OnExtraPatrolPoint()
    {
        // They suddenly get a desire not to patrol anymore, but
        // instead to face the altar
        local extra = message().from;
        SendMessage(extra, "StopPatrolling");

        // FIXME: handle the facing bit
    }

    function OnExtraBrainDead()
    {
        // Well, I _suppose_ we can leave you out of the rest of the ritual
        local extra = message().from;
        Link_DestroyAll("ScriptParams", self, extra);
        local index = extras.find(extra);
        if (index != null) {
            extras.remove(index);
        }
        print("EXTRA CTL: extra " + Object_Description(extra) + " is excused from the ritual due to brain death.");
    }

    // ---- Utilities

    function GetAvailableExtras()
    {
        local available_extras = [];
        // Find the extras available to participate in this round:
        // those who are dead, unconscious, or off searching for
        // or attacking the player are excused.
        foreach (extra in extras) {
            local level = AI.GetAlertLevel(extra);
            local compare_level = Property.Get(extra, "AI_Alertness", "Level");
            if (level < eAIScriptAlertLevel.kModerateAlert) {
                available_extras.append(extra);
            } else {
                print("EXTRA CTL: extra " + Object_Description(extra)
                    + " is at alert " + level + " (compare: " + compare_level + ") and temporarily excused.");
            }
        }
        print("EXTRA CTL: " + available_extras.len() + " extras available.");
        return available_extras;
    }

    function PickPatrolPoints(stage, available_extras, go_directly = false)
    {
        // The performer will be at index stage*2 in the trol ring;
        // pick roughly-evenly-spaced places for the extras around the
        // rest of the ring.
        local picked_trols = [];
        local spacing = (trols.len() / (available_extras.len() + 1.0));
        print("EXTRA CTL: extras spaced every " + spacing + " points.");
        local performer_index = (2 * stage);
        foreach (extra_index, extra in available_extras) {
            local pick_index = (floor(performer_index + ((extra_index + 1) * spacing) + 0.5) % trols.len());
            local pick = trols[pick_index];
            // print("EXTRA CTL: extra " + extra_index + ": " + Object_Description(extra)
            //     + " picked trol #" + pick_index + ": " + Object_Description(pick));
            picked_trols.append(pick);
            local closest_trol = (go_directly ? 0 : FindClosestTrol(Object.Position(extra)));
            SendMessage(extra, "PatrolTo", pick, closest_trol);
        }
    }

    function FindClosestTrol(pos)
    {
        local closest = 0;
        local shortest_distance = 9999999;
        foreach (trol in trols) {
            local trol_pos = Object.Position(trol);
            local delta = (trol_pos - pos);
            // Ignore z, nobody's flying to their patrol point
            local distance = (delta.x * delta.x) + (delta.y * delta.y);
            if (distance < shortest_distance) {
                shortest_distance = distance;
                closest = trol;
            }
        }
        return closest;
    }
}

class RitualExtra extends Controlled
{
    // ---- Messages from the controller

    function OnPatrolTo()
    {
        local trol = message().data;
        local start_at_trol = message().data2;
        local direct = (start_at_trol == 0);
        SetPatrolTarget(trol);
        if (direct) {
            Link_SetCurrentPatrol(self, trol);
        } else {
            if (Link_GetCurrentPatrol(self) == 0) {
                Link_SetCurrentPatrol(self, start_at_trol);
            }
        }
        Object.AddMetaProperty(self, "M-DoesPatrol");
        if (direct) {
            print("EXTRA: " + Object_Description(self)
                + " patrolling directly to " + Object_Description(trol));
        } else {
            print("EXTRA: " + Object_Description(self)
                + " patrolling to " + Object_Description(trol)
                + " via " + Object_Description(start_at_trol));
        }
    }

    function OnStopPatrolling()
    {
        Object.RemoveMetaProperty(self, "M-DoesPatrol");
    }

    // ---- Messages from the AI

    function OnPatrolPoint()
    {
        // Tell the controller we've reached our target patrol point
        local trol = message().patrolObj;
        if (trol == GetPatrolTarget()) {
            print("EXTRA: " + Object_Description(self) + " reached target point " + Object_Description(trol));
            PunchUp("ExtraPatrolPoint", trol);
        } else {
            print("EXTRA: " + Object_Description(self) + " reached non-target point " + Object_Description(trol));
            print("EXTRA: " + Object_Description(self) + " continuing on to " + Object_Description(Link_GetCurrentPatrol(self)));
        }
    }

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            PunchUp("ExtraBrainDead");
        }
    }

    function OnAlertness()
    {
        if ((message().level > message().oldLevel)
            && (message().level >= eAIScriptAlertLevel.kModerateAlert))
        {
            // Forget where we were going, so that when we return to the
            // ritual, we can go to our spot via the closest point.
            Link_DestroyAll("AICurrentPatrol", self);
        }

        /* Plan:

            When an extra starts investigating, they punch up to ask to be excused.
            When they stop having any AIInvestigate or AIAttack links, then they punch up to rejoin.
            When they rejoin, they're sent directly to place beside the performer: ((2 * stage + 1) % stage_count)
                and inserted at the front of the extras array, so they'll then be the first in line.

        or maybe not?

        Okay, different technique needed: I still want them to calm down sooner, so:

            What if, when alerted to > 2, we activate a tweq for every few seconds.
            Then when tweq'd, we check:

                * Make sure we have no AIAttack links to the player.
                * Check the time on the all AIAwareness links that are level >= 2.
                    - if any are more than 30 seconds old, delete them and stop the tweq.
                    - and also remove any AIInvest links too.
                * Regardless, stop the tweq when alertness reaches <= 1.

                If that doesn't work, can maybe throw a temporary low AlertCap in there, then take it off again?
        */
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
        print("EXTRA " + Object_Description(self) + ": new target is: " + Object_Description(trol));
        Link_DestroyAll("Route", self);
        if (trol != 0) {
            Link.Create("Route", self, trol);
        }
    }
}
