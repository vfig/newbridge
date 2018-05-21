// FIXME: for the sake of saving, need to review everything here,
// and might want to track more things with more links and/or SetData
// instead of member variables.
// Also need to consider OnSim() vs OnBeginScript().

const DEBUG_GETONWITHIT = true;
const DEBUG_SKIPTOTHEEND = false;

/*
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
*/

enum eRitualStatus {
    kRitualNotStarted       = 0,
    kRitualInProgress       = 1,
    kRitualLastStage        = 2,
    kRitualFinale           = 3,
    kRitualEnded            = 4,
    kRitualAborted          = 5,
}

class RitualController extends SqRootScript
{
    /* The overall ritual runs through these statuses:

        kRitualNotStarted
            The ritual has not yet begun. Waiting for the player to get near, basically.

        kRitualInProgress
            The rounds and downs are happening. The performer is in a trance, but the
            extras will react to the player pretty much as usual. While in progress,
            the following steps take place, triggered by the performer:

            Round:
                The lights go off etc.
                Everyone walks to the next vertex.

            Pause:
                The performer turns to face the altar.
                The extras face the altar and ululate.

            Down:
                The performer walks to the altar.
                The lights come on etc.

            Bless:
                The performer waves the hand over the altar and chants.
                (The ritual ends here mid-blessing if it's at the last stage)

            Return:
                The performer walks back to the vertex.

        kRitualLastStage
            Di Rupo is walking down to the altar for the last time. The extras enter a
            trance and run to the altar too. Last chance for player intervention. Only
            the Pause / Down / Bless steps happen during this stage.

        kRitualFinale
            The Anax is torn apart, everyone celebrates, and the Prophet appears.

        kRitualEnded
            After the finale, there's nothing more to do.

        kRitualAborted
            The ritual was stopped--by the Hand being stolen, or the Anax, or di Rupo
            being KO'd or killed--and everyone gets angsty.
    */

    // Vertices in the order that the performer should visit them.
    // Can tweak this to adjust the ritual timing in very large increments.
    // Timing can also be tweaked more generally with M-RitualTrance Creature Time Warp.
    // But the last entry must be 6, because that's the victim's head.
    // FIXME: might in fact want to adjust time warp for Normal difficulty
    // FIXME: If the stages are changed, also need to adjust the LineNo 0-6 tags in the conv schema.
    //stages = [0, 1, 2, 3, 4, 5, 6]; // very fast
    stages = [2, 5, 1, 4, 0, 3, 6]; // With time warp 1.5, this takes 5:20 to complete.
    //stages = [4, 2, 0, 5, 3, 1, 6]; // very slow

    function OnSim()
    {
        if (message().starting) {
            if (DEBUG_SKIPTOTHEEND) {
                stages = [6];
            }

            if ((Status() == null) || (StageIndex() == null)) {
                SetStatus(eRitualStatus.kRitualNotStarted);
                SetStageIndex(0);
            }

            // FIXME: move all these to utility functions so we can get
            // things as we need them.

            // Check all linked entities and are accounted for.
            local performer = Link_GetScriptParamsDest("Performer", self);
            if (performer == 0) { Die("no performer."); return; }

            local victim = Link_GetScriptParamsDest("Victim", self);
            if (victim == 0) { Die("no victim."); return; }

            local extras = Link_GetAllScriptParamsDests("Extra", self);
            if (extras.len() == 0) { Die("no extras."); return; }

            local round_trols = Link_CollectPatrolPath(Link_GetAllScriptParamsDests("PerfRoundTrol", self));
            if (round_trols.len() != 7) { Die("need 7 round_trols."); return; }

            local down_convs = Link_GetAllScriptParamsDests("DownConv", self);
            if (down_convs.len() != 7) { Die("need 7 down_convs."); return; }

            local extra_round_trols = Link_CollectPatrolPath(Link_GetAllScriptParamsDests("ExtraRoundTrol", self));
            if (extra_round_trols.len() != 14) { Die("need 14 extra_round_trols."); return; }

            local lights = Link_GetAllScriptParamsDests("Light", self);
            if (lights.len() != 7) { Die("need 7 lights."); return; }

            local strips = Link_GetAllScriptParamsDests("Strip", self);
            if (strips.len() != 7) { Die("need 7 strips."); return; }

            local down_trols = Link_GetAllScriptParamsDests("DownTrol", self);
            if (down_trols.len() != 7) { Die("need 7 down_trols."); return; }

            local strobes = Link_GetAllScriptParamsDests("Strobe", self);
            if (strobes.len() == 0) { Die("no strobes."); return; }

            local perf_wait_conv = Link_GetScriptParamsDest("PerfWaitConv", self);
            if (perf_wait_conv == 0) { Die("no perf_wait_conv."); return; }

            local finale_convs = Link_GetAllScriptParamsDests("FinaleConv", self);
            if (finale_convs.len() != 7) { Die("need 7 finale_convs."); return; }

            local gores = Link_GetAllScriptParamsDests("Gore", self);
            if (gores.len() != 7) { Die("need 7 gores."); return; }

            local blood = Link_GetScriptParamsDest("Blood", self);
            if (blood == 0) { Die("no blood."); return; }

            local search_trols = Link_CollectPatrolPath(Link_GetAllScriptParamsDests("SearchTrol", self));
            if (down_trols.len() == 0) { Die("no search_trols."); return; }

            // FIXME: Maybe I only need one search conv for the perf (and one for each extra)? Try the "Search, Scan" tag.
            // note that the investigate ability doesn't seem to use the Search, Peek tags: that's for Assassins.
            local perf_search_convs = Link_GetAllScriptParamsDests("PerfSearchConv", self);
            if (perf_search_convs.len() == 0) { Die("no perf_search_convs."); return; }



            // FIXME: need to know if we're at the start of the mission,
            // or just loading a save! We should only do the following
            // at the start of a mission!

            // Start the performer in a trance so they won't spook
            // at anything before the ritual begins.
//            print("PERFORMER CTL: Starting trance");
            Object.AddMetaProperty(performer, "M-RitualTrance");

            if (DEBUG_GETONWITHIT) {
                Object.AddMetaProperty(performer, "M-GetOnWithIt");
            }

            // We don't care how many strobes there are, but make sure they're off to begin with
            foreach (strobe in strobes) {
                SendMessage(strobe, "TurnOff");
            }

            // Make sure the gores aren't "there" initially.
            foreach (gore in gores) {
                Object.AddMetaProperty(gore, "M-NotHere");
            }


            if (DEBUG_GETONWITHIT) {
                foreach (extra in extras) {
                    Object.AddMetaProperty(extra, "M-GetOnWithIt");
                }
            }
        }
    }

    function OnTurnOn()
    {
        Begin();
    }

    // ---- The ritual begins (kRitualInProgress)

    function Begin()
    {
        if (Status() == eRitualStatus.kRitualNotStarted) {
            SetStatus(eRitualStatus.kRitualInProgress);

            local stage_index = StageIndex();
            local stage = Stage()

            // FIXME: remove this whitespace
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");
            print(" ");

            print("RITUAL: Begin");
            print("RITUAL: Index " + stage_index + " is stage " + stage);

            // Seven times rounds and seven times downs - always begin with a round.
            print("RITUAL: Round " + stage);
            //FIXME: make this a method of ours
            //PunchDown("RitualRound", stage);
        } else {
            print("RITUAL ERROR: Incorrect status (" + Status() + ") to begin.");
        }
    }

    function End()
    {
        if (status == eRitualStatus.kRitualInProgress) {
            status = eRitualStatus.kRitualEnded;

            print("RITUAL: End");
            PunchDown("RitualEnd", current_stage);

            // FIXME: objectives tie in

            // Time for a grand finale before failing the mission.
            Finale();

            print("RITUAL DEATH: Beware! The Prophet has returned!");
            Object.Destroy(self);
        }
    }

    function Abort()
    {
        if (status == eRitualStatus.kRitualInProgress) {
            status = eRitualStatus.kRitualAborted;

            print("RITUAL: Abort");
            PunchDown("RitualAbort", current_stage);

            // FIXME: objectives tie-in

            print("RITUAL DEATH: Well done, you stopped the ritual!");
            Object.Destroy(self);
        }
    }

    function Die(reason)
    {
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        print("RITUAL DEATH: " + reason);
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        Object.Destroy(self);
    }

    // ---- Messages from child controllers

    function OnPerformerReachedVertex()
    {
        if (status == eRitualStatus.kRitualInProgress) {
            // Time for a pause
            print("RITUAL: Pause " + current_stage);
            PunchDown("RitualPause", current_stage);
        }
    }

    function OnPerformerFacedAltar()
    {
        if (status == eRitualStatus.kRitualInProgress) {
            // Time for a down
            print("RITUAL: Down " + current_stage);
            PunchDown("RitualDown", current_stage);
        }
    }

    function OnPerformerReachedAltar()
    {
        if (status == eRitualStatus.kRitualInProgress) {
            // Time for a bless
            print("RITUAL: Bless " + current_stage);
            PunchDown("RitualBless", current_stage);
        }
    }

    function OnPerformerFinishedBlessing()
    {
        if (status == eRitualStatus.kRitualInProgress) {
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
    }

    function OnPerformerReturnedToVertex()
    {
        if (status == eRitualStatus.kRitualInProgress) {
            // On to the next stage
            current_index = current_index + 1;
            if (current_index >= stages.len()) {
                print("RITUAL DEATH: me am go too far!");
                Object.Destroy(self);
                return;
            }
            current_stage = stages[current_index];
            print("RITUAL: Index " + current_index + " is stage " + current_stage);

            // Time for the next round
            print("RITUAL: Round " + current_stage);
            PunchDown("RitualRound", current_stage);
        }
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

    // ---- Finale, and messages for finale coordination

    function Finale()
    {
    }

    // ---- Utilities

    function Status() {
        return GetData("RitualStatus");
    }

    function SetStatus(status) {
        SetData("RitualStatus", status);
    }

    function StageIndex()
    {
        return GetData("RitualStageIndex");
    }

    function SetStageIndex(index)
    {
        SetData("RitualStageIndex", index);
    }

    function Stage() {
        return stages[StageIndex()];
    }
}

/*
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
                Link_SetContainType(link, eDarkContainType.kContainTypeAlt);
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
                Link_SetContainType(link, eDarkContainType.kContainTypeBelt);
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

    function OnRipAndTear()
    {
        // Pick up the pound of flesh and make it visible.
        local gore = Link_GetScriptParamsDest("PoundOfFlesh", self);
        if (gore != 0) {
            Container.Add(gore, self, eDarkContainType.kContainTypeAlt);
        }
        // Let the controller know.
        PunchUp("PerformerRipAndTear", gore);
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
 
    // ---- Messages from the master for the whole ritual

    function OnRitualBegin()
    {
        local stage = message().data;
        local trol = rounds[stage];
//        print("PERFORMER CTL: Starting patrol");
        SetPatrolTarget(trol);
        Link_SetCurrentPatrol(performer, trol);
        Object.AddMetaProperty(performer, "M-DoesPatrol");
    }

    function OnRitualEnd()
    {
        // Kill all the conversations
        foreach (down in downs) {
            SendMessage(down, "TurnOff");
        }

        // Performer doesn't patrol anymore.
        Object.RemoveMetaProperty(performer, "M-RitualTrance");
        Object.RemoveMetaProperty(performer, "M-DoesPatrol");
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
//        print("PERFORMER CTL: Patrolling to " + Object.GetName(trol) + " (" + trol + ") for stage " + stage);
        SetPatrolTarget(trol);
    }

    function OnRitualPause()
    {
        local stage = message().data;
        local down = downs[stage];
        // We call it a down, but really it's a system of a down.
        // The system drives all the facing, the downing, the
        // blessing, and the returning.
//        print("PERFORMER CTL: Starting conversation " + Object.GetName(down) + " (" + down + ") for stage " + stage);
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
//                print("PERFORMER CTL: reached target: " + Object.GetName(trol) + " (" + trol + ")");
                PunchUp("PerformerReachedVertex");
            } else {
//                print("PERFORMER CTL: reached troll trol: " + Object.GetName(trol) + " (" + trol + ")");
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
//        print("PERFORMER CTL: new target is: " + Object.GetName(trol) + " (" + trol + ")");
        Link_DestroyAll("Route", self);
        if (trol != 0) {
            Link.Create("Route", self, trol);
        }
    }

    function BeginRandomSearch()
    {
//        print("PERFORMER CTL: Now searching.");
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
//        print("PERFORMER CTL: Chose random search conv: " + Object_Description(conv));
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

    // ---- Messages from the master for the whole ritual

    // function OnRitualBegin()
    // {
    // }

    // function OnRitualEnd()
    // {
    // }

    // function OnRitualAbort()
    // {
    // }

    // ---- Messages for the finale

    function OnDismember()
    {
        // Get rid of the victim, show the gore, and a splash of blood
        SendMessage(blood, "TurnOn");
        foreach (gore in gores) {
            Object.RemoveMetaProperty(gore, "M-NotHere");
        }
        Object.Destroy(victim);
    }
}


class RitualFloorStrip extends SqRootScript
{
    // When turned on, brighten up and pulse illumination.

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
        // instead to face the altar (because their idle origin
        // tells them to do that).
        local extra = message().from;
        SendMessage(extra, "StopPatrolling");
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
//        print("EXTRA CTL: extras spaced every " + spacing + " points.");
        local performer_index = (2 * stage);
        foreach (extra_index, extra in available_extras) {
            local pick_index = (floor(performer_index + ((extra_index + 1) * spacing) + 0.5) % trols.len()).tointeger();
            local pick = trols[pick_index];
//            print("EXTRA CTL: extra " + extra_index + ": " + Object_Description(extra)
//                + " picked trol #" + pick_index + ": " + Object_Description(pick));
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
*/

class RitualExtra
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
           // print("EXTRA: " + Object_Description(self)
           //     + " patrolling directly to " + Object_Description(trol));
        } else {
           // print("EXTRA: " + Object_Description(self)
           //     + " patrolling to " + Object_Description(trol)
           //     + " via " + Object_Description(start_at_trol));
        }
    }

    function OnRunTo()
    {
        local trol = message().data;
        AI_SetIdleOrigin(self, trol);
        AI.MakeGotoObjLoc(self, trol, eAIScriptSpeed.kFast, eAIActionPriority.kHighPriorityAction);
    }

    function OnStopPatrolling()
    {
        // Don't patrol away.
        Object.RemoveMetaProperty(self, "M-DoesPatrol");
    }

    function OnRipAndTear()
    {
        // Pick up the pound of flesh and make it visible.
        local gore = Link_GetScriptParamsDest("PoundOfFlesh", self);
        if (gore != 0) {
            Container.Add(gore, self, eDarkContainType.kContainTypeAlt);
        }
    }

    // ---- Messages from the AI

    function OnPatrolPoint()
    {
        // Tell the controller we've reached our target patrol point
        local trol = message().patrolObj;
        if (trol == GetPatrolTarget()) {
//            print("EXTRA: " + Object_Description(self) + " reached target point " + Object_Description(trol));
            PunchUp("ExtraPatrolPoint", trol);
        } else {
//            print("EXTRA: " + Object_Description(self) + " reached non-target point " + Object_Description(trol));
//            print("EXTRA: " + Object_Description(self) + " continuing on to " + Object_Description(Link_GetCurrentPatrol(self)));
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
        print("EXTRA: " + Object_Description(self)
            + " alertness " + message().oldLevel
            + " ===================> " + message().level);

        if ((message().level > message().oldLevel)
            && (message().level >= eAIScriptAlertLevel.kModerateAlert))
        {
            // Stop patrolling and forget where we were going, so that when
            // we return to the ritual, we can go to our last idle spot instead.
            Object.RemoveMetaProperty(self, "M-DoesPatrol");
            Link_DestroyAll("AICurrentPatrol", self);

            // Be lazy about investigating though.
            Object.AddMetaProperty(self, "M-RitualLazyExtra");
        }
    }

    function OnObjActResult()
    {
        if (message().action == eAIAction.kAIGoto) {
            if (message().result == eAIActionResult.kActionDone) {
                PunchUp("ExtraRunToSucceeded");
            } else {
                PunchUp("ExtraRunToFailed");
            }
        }
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
        // print("EXTRA: " + Object_Description(self) + " new target is: " + Object.GetName(trol) + " (" + trol + ")");
        Link_DestroyAll("Route", self);
        if (trol != 0) {
            Link.Create("Route", self, trol);

            // We also want this to be our idle spot, so we'll wander back here
            // if we were alerted, and calmed down in between rounds.
            AI_SetIdleOrigin(self, trol);
        }
    }
}


class RitualLazyExtra extends SqRootScript
{
    // Makes extras give up investigating and return to normal alert levels
    // much sooner than normal. Default is investigation ends 30s after contact,
    // and alertness ends 120s after contact. That's way too long, given the
    // length of the whole ritual.

// FIXME: tweak these times when playtesting
// FIXME: maybe even make these times vary by difficulty?

    // Minimum time (in seconds) to investigate.
    kInvestigateMinAge = 10.0;

    // Maximum time (in seconds) to persist level 2 and 3 awareness, respectively.
    kAwarenessMaxAge2 = 10.0;
    kAwarenessMaxAge3 = 20.0;

    function OnBeginScript()
    {
        //print("LAZINESS: " + Object_Description(self) + " is lazy.");

        // Start the tweq.
        Property.Set(self, "StTweqBlink", "AnimS", 1);
    }

    function OnTweqComplete()
    {
        // Don't try to stop looking if we're busy attacking!
        if (! Link.AnyExist("AIAttack", self)) {
            //print("LAZINESS: " + Object_Description(self) + " is at alert " + AI_AlertLevel(self) + " and still lazy.");
            ExpireAwareness();
        } else {
            //print("LAZINESS: " + Object_Description(self) + " is busy attacking something.");
        }
    }

    function OnAlertness()
    {
        if (message().level < 2) {
            //print("LAZINESS: " + Object_Description(self) + " has calmed down. Back to work.");
            // Laziness worked, we can stop checking that we're lazy enough.
            Object.RemoveMetaProperty(self, "M-RitualLazyExtra");
        }
    }

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            //print("LAZINESS: " + Object_Description(self) + " is brain dead. Back to work (or not).");
            // We're brain dead, stop caring.
            Object.RemoveMetaProperty(self, "M-RitualLazyExtra");
        }
    }

    function ExpireAwareness()
    {
        // First of all, if we're investigating, we let that happen for a while
        local invest_link = Link.GetOne("AIInvest", self);
        if (invest_link != 0) {
            // Find out why we're investigating.
            local awareness_link = Link.GetOne("AIAwareness", self, LinkDest(invest_link));
            if (awareness_link != 0) {
                local age = (GetTime() - Awareness_LastContactTime(awareness_link));
                if (age < kInvestigateMinAge) {
                    // Let the investigation continue.
                    //print("LAZINESS: " + Object_Description(self) + " continuing fresh (" + age + "s) investigation: " + Awareness_Description(invest_link));
                    return;
                } else {
                    //print("LAZINESS: " + Object_Description(self) + " investigation is getting old (" + age + "s): " + Awareness_Description(invest_link));
                }
            } else {
                //print("LAZINESS: " + Object_Description(self) + " has no awareness link for its investigation.");
            }
        } else {
            //print("LAZINESS: " + Object_Description(self) + " is not investigating.");
        }

        // Okay, we're going to destroy some links, so cache the iterator first just in case.
        local links = [];
        foreach (link in Link.GetAll("AIAwareness", self)) {
            links.append(link);
        }
        // Conditionally destroy means: destroy these if there are no other reasons to stay alert (live friendlies).
        local conditionally_destroy_links = [];
        local keep_count = 0;
        foreach (link in links) {
            // Basic evidence
            local dest = LinkDest(link);
            local level = Awareness_AlertLevel(link);
            local age = (GetTime() - Awareness_LastContactTime(link));
            local have_los = Awareness_HaveLOS(link);

            // Derived evidence
            local is_me = (dest == self);
            local is_hostile_team = AI_HostileTeam(AI_Team(self), AI_Team(dest));
            local is_same_team = (AI_Team(self) == AI_Team(dest));
            local is_dead = (AI_Mode(dest) == eAIMode.kAIM_Dead);
            local is_low_level = (level < 2);
            local is_old = (((level == 2) && (age >= kAwarenessMaxAge2))
                || ((level == 3) && (age >= kAwarenessMaxAge3)));

            // Draw conclusions:
            local ignore = false;
            local destroy = false;
            local expire = false;
            local conditionally_destroy = false;
            if (is_low_level) {
                // This link isn't keeping us alerted, so ignore it.
                //print("LAZINESS: Ignoring low level: " + Awareness_Description(link));
                ignore = true;
            } else if (is_hostile_team) {
                if (is_old) {
                    // Guess it was just rats again.
                    //print("LAZINESS: Destroying old (" + age + "s) hostile: " + Awareness_Description(link));
                    destroy = true;
                } else {
                    //print("LAZINESS: Keeping recent (" + age + "s) hostile: " + Awareness_Description(link));
                }
            } else if (is_same_team) {
                if (is_me) {
                    if (is_old) {
                        // Well, I heard something, but that was a while ago.
                        //print("LAZINESS: Destroying old (" + age + "s) heard: " + Awareness_Description(link));
                        destroy = true;
                    } else {
                        //print("LAZINESS: Keeping recent (" + age + "s) heard: " + Awareness_Description(link));
                    }
                } else {
                    if (is_dead) {
                        // Friendly corpses aren't interesting once an investigation is over.
                        if (have_los) {
                            // But if it's still in sight, there's not much we can do,
                            // they *will* stay alert despite our best efforts.
                            //print("LAZINESS: Friendly corpse is in sight, leaving it alone: " + Awareness_Description(link));
                        } else {
                            // But keep the link around so they don't forget and start investigating it again.
                            //print("LAZINESS: Expiring friendly corpse: " + Awareness_Description(link));
                            expire = true;
                        }
                    } else {
                        // Friends don't let friends stay angry.
                        //print("LAZINESS: Conditionally destroying friendly: " + Awareness_Description(link));
                        conditionally_destroy = true;
                    }
                }
            } else {
                // Neutral team? Can they even alert you? Don't care, let's get rid of it.
                //print("LAZINESS: Destroying neutral: " + Awareness_Description(link));
                destroy = true;
            }

            // Act upon the conclusions.
            if (ignore) {
                // Well, what did you expect?
            } else if (destroy) {
                Link.Destroy(link);
            } else if (expire) {
                Awareness_Expire(link);
            } else if (conditionally_destroy) {
                conditionally_destroy_links.append(link);
            } else {
                ++keep_count;
            }
        }

        // When there's nothing to see, there's no reason to keep investigating.
        if (keep_count == 0) {
            //print("LAZINESS: " + Object_Description(self) + " is destroying its investigation (if any).");
            Link_DestroyAll("AIInvest", self);

            // And destroy the conditional ones
            foreach (link in conditionally_destroy_links) {
                //print("LAZINESS: Actually destroying conditional: " + Awareness_Description(link));
                Link.Destroy(link);
            }
        }

        if (keep_count == 0) {
            //print("LAZINESS CONCLUSION: No reason for " + Object_Description(self) + " to stay alert.");
            // HACK: sometimes despite all the awareness fudging, sometimes they don't calm
            // down soon enough. So let's force them to for now.
            // But if there's a body sitting right in front of them, they'll stay constantly on the
            // alert no matter what. Not much I can do about that.
            Property.Set(self, "AI_Alertness", "Level", 1);
            Property.Set(self, "AI_Alertness", "Peak", 1);
        } else {
            //print("LAZINESS CONCLUSION: " + Object_Description(self) + " should stay alert, there's trouble out there.");
        }
    }

    // ---- Utilities

    function Awareness_Description(link)
    {
        return ("AIAwareness (level " + Awareness_AlertLevel(link) + ") "
            + Object_Description(self) + " -> "
            + Object_Description(LinkDest(link)));
    }

    function Awareness_AlertLevel(link)
    {
        return LinkTools.LinkGetData(link, "Level");
    }

    function Awareness_LastContactTime(link)
    {
        return (LinkTools.LinkGetData(link, "Time last contact") / 1000.0);
    }

    function Awareness_HaveLOS(link)
    {
        local flags = LinkTools.LinkGetData(link, "Flags");
        return ((flags & 0x08) != 0); // "HaveLOS"
    }

    function Awareness_Expire(link)
    {
        // Anything more than two minutes ago is old news.
        local a_long_time_ago = (floor((GetTime() - 120)).tointeger() * 1000);
        LinkTools.LinkSetData(link, "Level enter time", a_long_time_ago);
        LinkTools.LinkSetData(link, "Time last contact", a_long_time_ago);
        LinkTools.LinkSetData(link, "Last true contact", a_long_time_ago);
    }
}

/*
class RitualFinaleController extends Controller
{
    waiting_for_extras = 9999;

    function OnRitualEnd()
    {
        // The ritual's ended, but the show is just beginning!

        // Make the stolen ais send messages to us too.
        Link_CreateScriptParams("Finale", self, performer);
        foreach (extra in extras) {
            Link_CreateScriptParams("Finale", self, extra);
        }

        // Performer stays entranced, but now moves at normal speed.
        Object.AddMetaProperty(performer, "M-RitualFinaleTrance");

        // Ignore any extras that are dead or busy.
        DiscardUnavailableExtras();

        // Make sure the extras don't patrol or get distracted anymore.
        foreach (extra in extras) {
            SendMessage(extra, "StopPatrolling");
            Object.AddMetaProperty(extra, "M-RitualFinaleTrance");
        }

        // The performer should be already in place, but send all available
        // extras to the altar.
        PlacesEveryone();

        // Now we wait for them all to tell us that they're ready (or
        // otherwise become unavailable).
        waiting_for_extras = extras.len();
    }

    // ---- Final functionality

    function DiscardUnavailableExtras()
    {
        // Filter out dead or KO'd extras cause they aren't coming
        // back in the finale. If they wanted to take part, they
        // should've stayed alive, now, shouldn't they?
        local available_extras = [];
        foreach (extra in extras) {
            if (AI_Mode(extra) != eAIMode.kAIM_Dead) {
                available_extras.append(extra);
            }
        }
        extras = available_extras;

        // FIXME: 
        //
        // PROBABLY should refactor this to be all under the one controller, with
        // more explicit stages, and debug-flags to control specific variations
        // (performer death, extra death, etc).
        //
        // More importantly, maybe the strobes should start and the extras run to
        // the altar just as the performer begins walking the last down? Gives a
        // little more time for that last minute "oh shit I need to stop this"
        // reaction.
        //
        // IDEEEEEEAAAAAAAAAA: at this point the player should have a last-ditch
        // chance to stop the ritual--by dispatching di Rupo. If they hurry, or
        // use an arrow, they can still get it done. (And maybe that'd stun or KO
        // all the extras too, if it goes wrong at that point?).
    }

    function PlacesEveryone()
    {
        // For whatever mad reason, it's vertex 6 that's the performer's place
        // at the finale. Too late to renumber everything now. Well, it's not
        // really, but I'm too lazy. Anyway the performer needs some head.
        Link_CreateScriptParams("PoundOfFlesh", performer, gores[6]);

        // Make sure di Rupo stays around at the altar while the extras get
        // here. We do that by giving her a new conversation to deal with.
        AI_SetIdleOrigin(performer, performer);
        AI.StartConversation(conv_perfwait);

        // The extras get the other chunks of meat and positions. We'll get
        // whatever gore is leftover for the explosion.
        PickGoresAndRunToAltar();
    }

    function ContinueWhenAllExtrasReady()
    {
        if (waiting_for_extras > 0) {
            print("FINALE CTL: Still waiting for " + waiting_for_extras + " extras.");
            return;
        }

        // Point of no return--well, that's in just a moment when we RIP AND TEAR!
        print("FINALE CTL: All extras ready.");

        // FIXME: here we need to make sure the Anax is no longer rescuable in any possible way
        // FIXME: the Hand should have vanished in a shower of sparks when the finale began, too.

        // Start pulling that Anax to pieces
        foreach (conv in conv_celebs) {
            AI.StartConversation(conv);
        }
    }

    function ExplodeVictim()
    {
        // Fling body parts everywhere, why don't you?
        local available_gores = Link_GetAllScriptParamsDests("PoundOfFlesh", self);
        local z_angles = [141.429, 192.857, 244.286, 295.714, 347.143, 38.571, 90.0];
        foreach (gore in available_gores) {
        //for (local i = 0; i < gores.len(); i++) {
            //local gore = gores[i];
            // Get its nominal index, so we can figure out the appropriate angle
            local i = gores.find(gore);

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

    function PickGoresAndRunToAltar()
    {
        local extra_trols = down_trols.slice(0, 6);
        local extra_gores = gores.slice(0, 6);
        local extra_round_trols = round_trols.slice(0, 6)
        foreach (extra in extras) {
            // Find the closest gore (well, the down points aren't evenly spread,
            // so find the closest trol_ritual_roundX and use its index.)
            local index = FindClosestTrolIndex(Object.Position(extra), extra_round_trols);
            local gore = extra_gores[index];
            local trol = extra_trols[index];
            extra_trols.remove(index);
            extra_gores.remove(index);
            extra_round_trols.remove(index);
            print("FINALE CTL: " + Object_Description(extra)
                + " has been allocated " + Object_Description(gore)
                + " and will go to " + Object_Description(trol));
            Link_CreateScriptParams("PoundOfFlesh", extra, gore);
            SendMessage(extra, "RunTo", trol);
        }
        // We'll take any unallocated gore bits ourselves
        foreach (gore in extra_gores) {
            print("FINALE CTL: " + Object_Description(gore) + " is unallocated, will explode.");
            Link_CreateScriptParams("PoundOfFlesh", self, gore);
        }
    }

    function FindClosestTrolIndex(pos, trols)
    {
        local closest_index = 0;
        local shortest_distance = 9999999;
        foreach (i, trol in trols) {
            local trol_pos = Object.Position(trol);
            local delta = (trol_pos - pos);
            // Ignore z, nobody's flying to their patrol point
            local distance = (delta.x * delta.x) + (delta.y * delta.y);
            if (distance < shortest_distance) {
                shortest_distance = distance;
                closest_index = i;
            }
        }
        return closest_index;
    }

    function MarkExtraAsReady(extra)
    {
        --waiting_for_extras;
        ContinueWhenAllExtrasReady();
    }

    function MarkExtraAsUnavailable(extra)
    {
        // Move this extra's gore back to our control.
        local link = Link_GetScriptParams("PoundOfFlesh", extra);
        if (link != 0) {
            local gore = LinkDest(link);
            Link.Destroy(link);
            Link_CreateScriptParams("PoundOfFlesh", self, gore);
        }

        --waiting_for_extras;
        ContinueWhenAllExtrasReady();
    }

    // ---- Messages from performers, extras etc.

    function OnPerformerBrainDead()
    {
        print("FINALE CTL: " + Object_Description(performer) + " is brain dead.");

        // FIXME: make sure this is ignored past the point of no return
        // (or make the performer invincible after that??)
    }

    function OnExtraRunToSucceeded()
    {
        local extra = message().from;
        print("FINALE CTL: " + Object_Description(extra) + " is at the altar.");
        MarkExtraAsReady(extra);
    }

    function OnExtraRunToFailed()
    {
        local extra = message().from;
        print("FINALE CTL: " + Object_Description(extra) + " couldn't reach altar. Stealing their gore.");
        MarkExtraAsUnavailable(extra);
    }

    function OnExtraBrainDead()
    {
        local extra = message().from;
        print("FINALE CTL: " + Object_Description(extra) + " is brain dead. Stealing their gore.");
        MarkExtraAsUnavailable(extra);
    }

    function OnExtraRipAndTear()
    {
        // Handle it the same as the perfomer. Too late to stop now (unless I
        // implement the last-minute reprieve).
        OnPerformerRipAndTear();
    }

    function OnPerformerRipAndTear()
    {
        if (victim != 0) {
            // This is the real point of no return
            print("FINALE CTL: Rip and tear! RIP AND TEAR!   ! ~  R I P  ~  A N D  ~  T E A R  ~ !");

            // The performer grabs their chunk of meat and everyone turns the victim into giblets
            SendMessage(victim_ctl, "Dismember");
            victim = 0;


            ExplodeVictim();
        }
    }

}
*/
