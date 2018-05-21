// FIXME: for the sake of saving, need to review everything here,
// and might want to track more things with more links and/or SetData
// instead of member variables.
// Also need to consider OnSim() vs OnBeginScript().

const DEBUG_GETONWITHIT = true;
const DEBUG_SKIPTOTHEEND = true;
const DEBUG_DISABLESTROBES = true;

// ---- Logging

enum eRitualLog
{
    // Subjects
    kRitual         = 1,
    kPerformer      = 2,
    kExtra          = 4,
    kVictim         = 8,
    kLighting       = 16,
    kFinale         = 32,
    // Contexts
    kPathing        = 256,
    kAlertness      = 512,
    kLaziness       = 1024,
}

RitualLogsEnabled <- function()
{
    return (0
        // Subjects
        | eRitualLog.kRitual
        | eRitualLog.kPerformer
        | eRitualLog.kExtra
        | eRitualLog.kVictim
//        | eRitualLog.kLighting
        | eRitualLog.kFinale
        // Contexts
//        | eRitualLog.kPathing
        | eRitualLog.kAlertness
//        | eRitualLog.kLaziness
        );
}

RitualLogName <- function(log)
{
    local function concat(prev, cur) {
        return (prev + " " + cur);
    }
    local names = [];
    if ((log & eRitualLog.kRitual) != 0) { names.append("RITUAL"); }
    if ((log & eRitualLog.kPerformer) != 0) { names.append("PERFORMER"); }
    if ((log & eRitualLog.kExtra) != 0) { names.append("EXTRA"); }
    if ((log & eRitualLog.kVictim) != 0) { names.append("VICTIM"); }
    if ((log & eRitualLog.kLighting) != 0) { names.append("LIGHTING"); }
    if ((log & eRitualLog.kPathing) != 0) { names.append("PATHING"); }
    if ((log & eRitualLog.kAlertness) != 0) { names.append("ALERTNESS"); }
    if ((log & eRitualLog.kLaziness) != 0) { names.append("LAZINESS"); }
    local name = names.reduce(concat);
    return ((name == null) ? "" : name);
}

RitualLog <- function(log, message)
{
    if ((RitualLogsEnabled() & log) == log) {
        print(RitualLogName(log) + ": " + message);
    }
}

// ---- The Ritual

enum eRitualStatus
{
    kNotStarted       = 0,
    kInProgress       = 1,
    kLastStage        = 2,
    kFinale           = 3,
    kEnded            = 4,
    kAborted          = 5,
}

class RitualController extends SqRootScript
{
    /* The overall ritual runs through these statuses:

        kNotStarted
            The ritual has not yet begun. Waiting for the player to get near, basically.

        kInProgress
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

        kLastStage
            Di Rupo is walking down to the altar for the last time. The extras enter a
            trance and run to the altar too. Last chance for player intervention. Only
            the Pause / Down / Bless steps happen during this stage.

        kFinale
            The Anax is torn apart, everyone celebrates, and the Prophet appears.

        kEnded
            After the finale, there's nothing more to do.

        kAborted
            The ritual was stopped--by the Hand being stolen, or the Anax, or di Rupo
            being KO'd or killed--and everyone gets angsty.
    */

    // Vertices in the order that the performer should visit them.
    // Can tweak this to adjust the ritual timing in very large increments.
    // Timing can also be tweaked more generally with M-RitualTrance Creature Time Warp.
    // But the last entry must be 6, because that's the victim's head.
    // FIXME: might in fact want to adjust time warp for Normal difficulty
    // FIXME: If the stages are changed, also need to adjust the LineNo 0-6 tags in the conv schema.
    // FIXME: If the stages are changed, the extras' starting points should also be updated.
    // FIXME: Actually I need to put the extras in starting positions anyway!
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
                SetStatus(eRitualStatus.kNotStarted);
                SetStageIndex(0);
                SetAwaitingExtras(Extras().len());
            }

            // FIXME: move all these to utility functions so we can get
            // things as we need them.

            // Check linked objects needed for ...
            // ... the whole ritual ...
            Performer();
            Victim();
            Extras();
            // ... the main ritual ...
            PerfRoundTrols();
            DownConvs();
            ExtraRoundTrols();
            Lights();
            Strips();
            // ... the last stage ...
            DownTrols();
            Strobes();
            // ... the finale ...
            PerfWaitConv();
            FinaleConvs();
            Gores();
            BloodFX();
            // ... aborting ...
            SearchTrols();
            PerfSearchConvs();


            // FIXME: need to know if we're at the start of the mission,
            // or just loading a save! We should only do the following
            // at the start of a mission!

            // Start the performer in a trance so they won't spook
            // at anything before the ritual begins.
            RitualLog(eRitualLog.kPerformer, "Starting trance");
            local performer = Performer();
            Object.AddMetaProperty(performer, "M-RitualTrance");
            if (DEBUG_GETONWITHIT) {
                Object.AddMetaProperty(performer, "M-GetOnWithIt");
            }

            local extras = Extras();
            if (DEBUG_GETONWITHIT) {
                foreach (extra in extras) {
                    Object.AddMetaProperty(extra, "M-GetOnWithIt");
                }
            }

            // We don't care how many strobes there are, but make sure they're off to begin with
            foreach (strobe in Strobes()) {
                SendMessage(strobe, "TurnOff");
            }

            // Make sure the gores aren't "there" initially.
            foreach (gore in Gores()) {
                Object.AddMetaProperty(gore, "M-NotHere");
            }
        }
    }

    function OnTurnOn()
    {
        Begin();
    }

    // ---- The ritual begins (kInProgress)

    function Begin()
    {
        if (Status() == eRitualStatus.kNotStarted) {
            SetStatus(eRitualStatus.kInProgress);

            local stage = Stage()

            // FIXME: remove this whitespace
            print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

            RitualLog(eRitualLog.kRitual, "Begin");

            // First positions, everyone
            RitualLog(eRitualLog.kPerformer, "Patrolling directly to first position.");
            local performer = Performer();
            local trol = PerfRoundTrols()[stage];
            SendMessage(performer, "PatrolTo", trol);

            RitualLog(eRitualLog.kExtra, "All extras patrolling directly to first positions.");
            SendExtrasToVertices(stage, GetAvailableExtras(), true);

            // Seven times rounds and seven times downs - always begin with a round.
            StepRound();
        }
    }

    function StepRound()
    {
        local stage = Stage();
        local stage_index = StageIndex();
        RitualLog(eRitualLog.kRitual, "Round " + stage_index + ", Stage " + stage);

        // Send the performer to their vertex
        local performer = Performer();
        local trol = PerfRoundTrols()[stage];
        SendMessage(performer, "PatrolTo", trol);

        // Send the extras to their vertices
        SendExtrasToVertices(stage, GetAvailableExtras());
    }

    function StepPause()
    {
        local stage = Stage();
        local stage_index = StageIndex();
        RitualLog(eRitualLog.kRitual, "Pause " + stage_index + ", Stage " + stage);

        // We call it a down, but really it's a system of a down.
        // The system drives all the facing, the downing, the
        // blessing, and the returning.
        local down = DownConvs()[stage];
        RitualLog(eRitualLog.kPerformer, "Starting conv " + Object_Description(down));
        AI.StartConversation(down);

        // FIXME: Extras suddenly get a desire to make some noise
    }

    function StepDown()
    {
        local stage = Stage();
        local stage_index = StageIndex();
        if (stage_index == (stages.len() - 1)) {
            SetStatus(eRitualStatus.kLastStage);
        }
        RitualLog(eRitualLog.kRitual, "Down " + stage_index + ", Stage " + stage);

        if (Status() == eRitualStatus.kLastStage) {
            local strobes = Strobes();
            if (DEBUG_DISABLESTROBES || (strobes.len() == 0)) {
                RitualLog(eRitualLog.kLighting, "Strobes are disabled.");
                // Just turn on all the lights.
                foreach (light in Lights()) {
                    RitualLog(eRitualLog.kLighting, "Turning on " + Object_Description(light));
                    SendMessage(light, "TurnOn");
                }
            } else {
                RitualLog(eRitualLog.kLighting, "Strobes are enabled.");
                // Make all the strobes flash horrendously
                foreach (light in Lights()) {
                    RitualLog(eRitualLog.kLighting, "Turning off " + Object_Description(light));
                    SendMessage(light, "TurnOff");
                }
                foreach (strobe in Strobes()) {
                    RitualLog(eRitualLog.kLighting, "Turning on " + Object_Description(strobe));
                    SendMessage(strobe, "TurnOn");
                }
            }
            // Make all the strips glow steadily
            foreach (strip in Strips()) {
                RitualLog(eRitualLog.kLighting, "Turning fully on " + Object_Description(strip));
                SendMessage(strip, "Fullbright");
            }
        } else {
            local light = Lights()[stage];
            RitualLog(eRitualLog.kLighting, "Turning on " + Object_Description(light));
            SendMessage(light, "TurnOn");

            local strip = Strips()[stage];
            RitualLog(eRitualLog.kLighting, "Turning on " + Object_Description(light));
            SendMessage(strip, "TurnOn");
        }
    }

    function StepBless()
    {
        local stage = Stage();
        local stage_index = StageIndex();
        RitualLog(eRitualLog.kRitual, "Bless " + stage_index + ", Stage " + stage);
    }

    function StepReturn()
    {
        local stage = Stage();
        local stage_index = StageIndex();
        RitualLog(eRitualLog.kRitual, "Return " + stage_index + ", Stage " + stage);

        local light = Lights()[stage];
        RitualLog(eRitualLog.kLighting, "Turning off " + Object_Description(light));
        SendMessage(light, "TurnOff");
    }

    // ---- The Grand Finale

    function Finale()
    {
        if (Status() == eRitualStatus.kLastStage) {
            SetStatus(eRitualStatus.kFinale);
            // The ritual's ended, but the show is just beginning!
            // Time for a grand finale before failing the mission.
            RitualLog(eRitualLog.kRitual, "Finale");

            // FIXME: objectives tie in

            // Kill all the down conversations
            foreach (down in DownConvs()) {
                SendMessage(down, "TurnOff");
            }
            // Performer stays entranced, but no longer patrosl, and now moves at normal speed.
            local performer = Performer();
            Object.RemoveMetaProperty(performer, "M-DoesPatrol");
            Object.RemoveMetaProperty(performer, "M-RitualTrance");
            Object.AddMetaProperty(performer, "M-RitualFinaleTrance");

            // Make sure di Rupo stays around at the altar while the extras get
            // here. We do that by giving her a new conversation to deal with.
            AI_SetIdleOrigin(performer, performer);
            AI.StartConversation(PerfWaitConv());

            // Ignore any extras that are dead or busy.
            // FIXME: does this work as a mutating function like this?
            DiscardUnavailableExtras();

            // Make sure the extras don't patrol or get distracted anymore.
            foreach (extra in Extras()) {
                SendMessage(extra, "StopPatrolling");
                Object.AddMetaProperty(extra, "M-RitualFinaleTrance");
            }

            // The performer should be already in place, but send all available
            // extras to the altar.
            // FIXME: of course we want that to be last stage, but that's post-refactor
    
            // For whatever mad reason, it's vertex 6 that's the performer's place
            // at the finale. Too late to renumber everything now. Well, it's not
            // really, but I'm too lazy. Anyway the performer needs some head.
            Link_CreateScriptParams("PoundOfFlesh", performer, Gores()[6]);

            // The extras get the other chunks of meat and positions. Any gore
            // that is unclaimed is for the explosion.
            PickGoresAndRunToAltar();

            // Now we wait for them all to tell us that they're ready (or
            // otherwise become unavailable).
            ContinueWhenAllExtrasReady();
        }
    }

    function DiscardUnavailableExtras()
    {
        // Filter out dead or KO'd extras cause they aren't coming
        // back in the finale. If they wanted to take part, they
        // should've stayed alive, now, shouldn't they?

        // FIXME: restore this
        //
        // local available_extras = [];
        // foreach (extra in extras) {
        //     if (AI_Mode(extra) != eAIMode.kAIM_Dead) {
        //         available_extras.append(extra);
        //     }
        // }
        // extras = available_extras;

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

    function PickGoresAndRunToAltar()
    {
        // FIXME: needs to be only available ones?
        local extras = Extras();
        local down_trols = DownTrols().slice(0, 6);
        local gores = Gores().slice(0, 6);
        local round_trols = PerfRoundTrols().slice(0, 6)
        foreach (extra in extras) {
            // Find the closest gore (well, the down points aren't evenly spread,
            // so find the closest trol_ritual_roundX and use its index.)
            local index = FindClosestTrolIndex(Object.Position(extra), round_trols);
            local gore = gores[index];
            local trol = down_trols[index];
            down_trols.remove(index);
            gores.remove(index);
            round_trols.remove(index);
            RitualLog(eRitualLog.kFinale,
                Object_Description(extra)
                + " has been allocated " + Object_Description(gore)
                + " and will go to " + Object_Description(trol));
            Link_CreateScriptParams("PoundOfFlesh", extra, gore);
            SendMessage(extra, "RunTo", trol);
        }
        // Keep any unclaimed gore bits ourselves for the explosion
        foreach (gore in gores) {
            RitualLog(eRitualLog.kFinale,
                Object_Description(gore) + " is unallocated, will explode.");
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
        StopAwaitingOneExtra();
    }

    function MarkExtraAsUnavailable(extra)
    {
        // Move this extra's gore back to our control.
        local link = Link_GetOneScriptParams("PoundOfFlesh", extra);
        if (link != 0) {
            local gore = LinkDest(link);
            Link.Destroy(link);
            Link_CreateScriptParams("PoundOfFlesh", self, gore);
        }
        StopAwaitingOneExtra();
    }

    function ContinueWhenAllExtrasReady()
    {
        if (AwaitingExtras() > 0) {
            RitualLog(eRitualLog.kFinale,
                "Still waiting for " + AwaitingExtras() + " extras.");
            return;
        }

        // Point of no return--well, that's in just a moment when we RIP AND TEAR!
        RitualLog(eRitualLog.kFinale, "All extras ready.");

        // FIXME: here we need to make sure the Anax is no longer rescuable in any possible way
        // FIXME: the Hand should have vanished in a shower of sparks when the finale began, too.

        // Start pulling that Anax to pieces
        foreach (conv in FinaleConvs()) {
            AI.StartConversation(conv);
        }
    }

    function TearVictimApart()
    {
        // The performer grabs their chunk of meat and everyone turns the victim into giblets
        foreach (gore in Gores()) {
            Object.RemoveMetaProperty(gore, "M-NotHere");
        }
        Object.Destroy(Victim());

        SendMessage(BloodFX(), "TurnOn");
    }

    function ExplodeVictim()
    {
        // Fling body parts everywhere, why don't you?
        local available_gores = Link_GetAllParams("PoundOfFlesh", self);
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
                RitualLog(eRitualLog.kFinale,
                    "ERROR: gore " + i + " not in valid position!");
                continue;
            } else {
                Property.Set(gore, "PhysControl", "Controls Active", 0);
            }

            // And launch!
            Physics.Activate(gore);
            Physics.SetVelocity(gore, vel);
        }
    }

    // ---- The End

    function End()
    {
        SetStatus(eRitualStatus.kEnded);
        RitualLog(eRitualLog.kRitual, "End");
        Die("Beware! The Prophet has returned!");
    }

    // ---- Oh no, the player got in the way! Abort! Abort!

    function Abort()
    {
        if ((Status() == eRitualStatus.kInProgress)
            || (Status() == eRitualStatus.kLastStage))
        {
            status = eRitualStatus.kAborted;

            RitualLog(eRitualLog.kRitual, "Abort");
            PunchDown("RitualAbort", current_stage);

            // FIXME: objectives tie-in

            Die("Well done, you stopped the ritual!");
        }
    }

    function Die(reason)
    {
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        print("RITUAL DEATH: " + reason);
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        Object.Destroy(self);
    }

    // ---- Utilities

    function GetAvailableExtras()
    {
        local extras = Extras();
        local available_extras = [];
        // Find the extras available to participate in this round:
        // those who are dead, unconscious, or off searching for
        // or attacking the player are excused.
        foreach (extra in extras) {
            // FIXME: we can't use alert status! They can stay alerted for too long!
            // FIXME: we should only excuse them if they are (a) investigating, (b) attacking, or (c) brain-dead.
            local level = AI.GetAlertLevel(extra);
            if (level < eAIScriptAlertLevel.kModerateAlert) {
                available_extras.append(extra);
            } else {
                RitualLog(eRitualLog.kExtra | eRitualLog.kAlertness,
                    Object_Description(extra)
                    + " is at alert " + level
                    + " and temporarily excused.");
            }
        }
        RitualLog(eRitualLog.kExtra, available_extras.len() + " extras available.");
        return available_extras;
    }

    function SendExtrasToVertices(stage, extras, go_directly = false)
    {
        // The performer will be at index stage*2 in the trol ring;
        // pick roughly-evenly-spaced places for the extras around the
        // rest of the ring.
        local trols = ExtraRoundTrols();
        local picked_trols = [];
        local spacing = (trols.len() / (extras.len() + 1.0));
        local performer_index = (2 * stage);
        foreach (extra_index, extra in extras) {
            local pick_index = (floor(performer_index + ((extra_index + 1) * spacing) + 0.5) % trols.len()).tointeger();
            local pick = trols[pick_index];
            RitualLog(eRitualLog.kExtra | eRitualLog.kPathing,
                "extra #" + extra_index + ": " + Object_Description(extra)
                + " picked trol #" + pick_index + ": " + Object_Description(pick));
            picked_trols.append(pick);
            local closest_trol = (go_directly ? 0 : FindClosestTrol(Object.Position(extra), trols));
            SendMessage(extra, "PatrolTo", pick, closest_trol);
        }
    }

    function FindClosestTrol(pos, trols)
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

    // ---- Messages from performer, extras, and victims

    function OnPerformerReachedTarget()
    {
        RitualLog(eRitualLog.kPerformer, "Reached target.");
        if (Status() == eRitualStatus.kInProgress) {
            StepPause();
        }
    }

    function OnPerformerFacedAltar()
    {
        RitualLog(eRitualLog.kPerformer, "Faced altar.");
        if (Status() == eRitualStatus.kInProgress) {
            StepDown();
        }
    }

    function OnPerformerReachedAltar()
    {
        RitualLog(eRitualLog.kPerformer, "Reached altar.");
        if ((Status() == eRitualStatus.kInProgress)
            || (Status() == eRitualStatus.kLastStage))
        {
            StepBless();
        }
    }

    function OnPerformerFinishedBlessing()
    {
        RitualLog(eRitualLog.kPerformer, "Finished blessing.");
        if (Status() == eRitualStatus.kInProgress) {
            StepReturn();
        } else if (Status() == eRitualStatus.kLastStage) {
            // Time for a grand finale
            Finale();
        }
    }

    function OnPerformerReturnedToVertex()
    {
        if (Status() == eRitualStatus.kInProgress) {
            // On to the next stage
            SetStageIndex(StageIndex() + 1);
            StepRound();
        } else {
            Die("me am go too far!");
        }
    }

    function OnExtraReachedTarget()
    {
        local extra = message().from;
        SendMessage(extra, "StopPatrolling");
    }

////////////////////

    // ---- Messages from performers, extras etc.

    function OnPerformerBrainDead()
    {
        RitualLog(eRitualLog.kFinale,
            Object_Description(performer) + " is brain dead.");

        // FIXME: make sure this is ignored past the point of no return
        // (or make the performer invincible after that??)
    }

    function OnExtraRunToSucceeded()
    {
        local extra = message().from;
        RitualLog(eRitualLog.kFinale,
            Object_Description(extra) + " is at the altar.");
        MarkExtraAsReady(extra);
    }

    function OnExtraRunToFailed()
    {
        local extra = message().from;
        RitualLog(eRitualLog.kFinale,
            Object_Description(extra) + " couldn't reach altar. Stealing their gore.");
        MarkExtraAsUnavailable(extra);
    }

    function OnExtraBrainDead()
    {
        local extra = message().from;
        RitualLog(eRitualLog.kFinale,
            Object_Description(extra) + " is brain dead. Stealing their gore.");
        MarkExtraAsUnavailable(extra);
    }

    function OnRipAndTear()
    {
        if (Status() == eRitualStatus.kFinale) {
            // This is the real point of no return!
            RitualLog(eRitualLog.kFinale,
                "Rip and tear! RIP AND TEAR!   ! ~  R I P  ~  A N D  ~  T E A R  ~ !");

            TearVictimApart();
            ExplodeVictim();
            End();
        }
    }


//////////////////////////////////
    // ---- Messages of abort conditions

    function OnPerformerNoticedHandMissing()
    {
        RitualLog(eRitualLog.kRitual, "Hand has been stolen");
        Abort();
    }

    function OnPerformerNoticedHandMissing()
    {
        RitualLog(eRitualLog.kRitual, "Victim has been unkidnapped");
        Abort();
    }

    function OnPerformerAlerted()
    {
        RitualLog(eRitualLog.kRitual, "Performer alerted");
        Abort();
    }

    function OnPerformerBrainDead()
    {
        RitualLog(eRitualLog.kRitual, "Performer is brain dead");
        Abort();
    }

    // ---- Ritual status

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

    function AwaitingExtras()
    {
        return GetData("AwaitingExtras");
    }

    function StopAwaitingOneExtra()
    {
        SetAwaitingExtras(AwaitingExtras() - 1);
    }

    function SetAwaitingExtras(count)
    {
        SetData("AwaitingExtras", count);
        // If in the finale, check if we're ready to continue.
        if (Status() == eRitualStatus.kFinale) {
            ContinueWhenAllExtrasReady();
        }
    }

    // ---- Linked entities

    function Performer()
    {
        local performer = Link_GetOneParam("Performer", self);
        if (performer == 0) { Die("no Performer."); }
        return performer;
    }

    function Victim()
    {
        local victim = Link_GetOneParam("Victim", self);
        if (victim == 0) { Die("no Victim."); }
        return victim;
    }

    function Extras()
    {
        local extras = Link_GetAllParams("Extra", self);
        if (extras.len() == 0) { Die("no Extra(s)."); }
        return extras;
    }

    function PerfRoundTrols()
    {
        local trols = Link_CollectPatrolPath(Link_GetAllParams("PerfRoundTrol", self));
        if (trols.len() != 7) { Die("need 7 PerfRoundTrol(s)."); }
        return trols;
    }

    function DownConvs()
    {
        local convs = Link_GetAllParams("DownConv", self);
        if (convs.len() != 7) { Die("need 7 DownConv(s)."); }
        return convs;
    }

    function ExtraRoundTrols()
    {
        local trols = Link_CollectPatrolPath(Link_GetAllParams("ExtraRoundTrol", self));
        if (trols.len() != 14) { Die("need 14 ExtraRoundTrol(s)."); }
        return trols;
    }

    function Lights()
    {
        local lights = Link_GetAllParams("Light", self);
        if (lights.len() != 7) { Die("need 7 Light(s)."); }
        return lights;
    }

    function Strips()
    {
        local strips = Link_GetAllParams("Strip", self);
        if (strips.len() != 7) { Die("need 7 Strip(s)."); }
        return strips;
    }

    function DownTrols()
    {
        local trols = Link_GetAllParams("DownTrol", self);
        if (trols.len() != 7) { Die("need 7 DownTrol(s)."); }
        return trols;
    }

    function Strobes()
    {
        local strobes = Link_GetAllParams("Strobe", self);
        if (strobes.len() == 0) { Die("no Strobe(s)."); }
        return strobes;
    }

    function PerfWaitConv()
    {
        local conv = Link_GetOneParam("PerfWaitConv", self);
        if (conv == 0) { Die("no PerfWaitConv."); }
        return conv;
    }

    function FinaleConvs()
    {
        local convs = Link_GetAllParams("FinaleConv", self);
        if (convs.len() != 7) { Die("need 7 FinaleConv(s)."); }
        return convs;
    }

    function Gores()
    {
        local gores = Link_GetAllParams("Gore", self);
        if (gores.len() != 7) { Die("need 7 Gore(s)."); }
        return gores;
    }

    function BloodFX()
    {
        local fx = Link_GetOneParam("BloodFX", self);
        if (fx == 0) { Die("no BloodFX."); }
        return fx;
    }

    function SearchTrols()
    {
        local trols = Link_CollectPatrolPath(Link_GetAllParams("SearchTrol", self));
        if (trols.len() == 0) { Die("no SearchTrol(s)."); }
        return trols;
    }

    function PerfSearchConvs()
    {
        // FIXME: Maybe I only need one search conv for the perf (and one for each extra)? Try the "Search, Scan" tag.
        // note that the investigate ability doesn't seem to use the Search, Peek tags: that's for Assassins.
        local convs = Link_GetAllParams("PerfSearchConv", self);
        if (convs.len() == 0) { Die("no PerfSearchConv(s)."); }
        return convs;
    }
}


class RitualPerformer extends SqRootScript
{
    // ---- Messages from the controller

    function OnPatrolTo()
    {
        local trol = message().data;
        SetPatrolTarget(trol);
        if (Link_GetCurrentPatrol(self) == 0) {
            Link_SetCurrentPatrol(self, trol);
        }
        Object.AddMetaProperty(self, "M-DoesPatrol");
    }

    // ---- Messages from AI and scripts

    function OnNoticedVictimMissing()
    {
        PunchUp("PerformerNoticedVictimMissing");
    }

    function OnPatrolPoint()
    {
        // Tell the controller we've reached another patrol point (not necessarily the right one)
        local trol = message().patrolObj;
        if (trol == GetPatrolTarget()) {
            RitualLog(eRitualLog.kPerformer | eRitualLog.kPathing, "reached target: " + Object.GetName(trol) + " (" + trol + ")");
            SetPatrolTarget(0);
            PunchUp("PerformerReachedTarget", trol);
        } else {
            RitualLog(eRitualLog.kPerformer | eRitualLog.kPathing, "reached trol: " + Object.GetName(trol) + " (" + trol + ")");
            // FIXME: we should do our own searching maybe?
            // the ritual controller doesn't need to get involved: we can have the link to the
            // search conv. In fact, it could be even be a different metaproperty+script that manages searching,
            // and is the same for the performer and all the extras. But that comes later.
        }
    }

    function OnStartWalking()
    {
        PunchUp("PerformerFacedAltar");
    }

    function OnUnpocketHand()
    {
        // Transfer the Hand to the Alt location, and make it unfrobbable
        local hand = Link_GetOneParam("Hand", self);
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
        local hand = Link_GetOneParam("Hand", self);
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
        local dagger = Link_GetOneParam("Dagger", self);
        if (dagger != 0) {
            // Dagger's already there, just not rendered! So render it.
            Property.Set(dagger, "HasRefs", "", true);
        }
    }

    function OnRipAndTear()
    {
        // Pick up the pound of flesh and make it visible.
        local gore = Link_GetOneParam("PoundOfFlesh", self);
        if (gore != 0) {
            Container.Add(gore, self, eDarkContainType.kContainTypeAlt);
        }
        // Let the controller know.
        PunchUp("RipAndTear", gore);
    }

    // ---- Utilities

    function PunchUp(message, data = 0, data2 = 0)
    {
        Link_BroadcastOnAllLinks(message, "~ScriptParams", self, data, data2);
    }

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
        RitualLog(eRitualLog.kPerformer | eRitualLog.kPathing, "new target is: " + Object.GetName(trol) + " (" + trol + ")");
        Link_DestroyAll("Route", self);
        if (trol != 0) {
            Link.Create("Route", self, trol);
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


class RitualPerformerController
{
 
    // ---- Messages from the master for the whole ritual



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



    // ---- Messages from the performer

    function OnPerformerPatrolPoint()
    {
        if (GetData("IsSearching")) {
            PlayRandomSearchConv();
        } else {
        }
    }


    // ---- Utilities

    function BeginRandomSearch()
    {
        RitualLog(eRitualLog.kPerformer, "Now searching.");
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
        RitualLog(eRitualLog.kPerformer, "Chose random search conv: " + Object_Description(conv));
        AI.StartConversation(conv);
    }
}


class DisableStrobes extends SqRootScript
{
    // Can use a .dml to patch this onto RitualLightingController to disable strobes.
    function OnSim()
    {
        if (message().starting) {
            // Destroy all strobe links
            local links = Link_GetAllScriptParams("Strobe", self);
            foreach (link in links) {
                Link.Destroy(link);
            }
        }
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


// FIXME: clean this up
class RitualExtraController
{


    // ---- Messages from the extras


    function OnExtraBrainDead()
    {
        // Well, I _suppose_ we can leave you out of the rest of the ritual
        local extra = message().from;
        Link_DestroyAll("ScriptParams", self, extra);
        local index = extras.find(extra);
        if (index != null) {
            extras.remove(index);
        }
        RitualLog(eRitualLog.kExtra, Object_Description(extra) + " is excused from the ritual due to brain death.");
    }

    // ---- Utilities


}


class RitualExtra extends SqRootScript
{
    // ---- Messages from the controller

    function OnPatrolTo()
    {
        local trol = message().data;
        local start_at_trol = message().data2;
        local direct = (start_at_trol == 0);
        SetPatrolTarget(trol);
        if (direct) {
            // Go directly to the target
            Link_SetCurrentPatrol(self, trol);
        } else {
            // If we're not already patrolling, use the suggested start point
            if (Link_GetCurrentPatrol(self) == 0) {
                Link_SetCurrentPatrol(self, start_at_trol);
            }
        }
        Object.AddMetaProperty(self, "M-DoesPatrol");
        if (direct) {
            RitualLog(eRitualLog.kExtra | eRitualLog.kPathing,
                Object_Description(self)
                + " patrolling directly to " + Object_Description(trol));
        } else {
            RitualLog(eRitualLog.kExtra | eRitualLog.kPathing,
                Object_Description(self)
                + " patrolling to " + Object_Description(trol)
                + " via " + Object_Description(start_at_trol));
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
        local gore = Link_GetOneParam("PoundOfFlesh", self);
        if (gore != 0) {
            Container.Add(gore, self, eDarkContainType.kContainTypeAlt);
        }
        PunchUp("RipAndTear", gore);
    }

    // ---- Messages from the AI

    function OnPatrolPoint()
    {
        // Tell the controller we've reached our target patrol point
        local trol = message().patrolObj;
        if (trol == GetPatrolTarget()) {
            RitualLog(eRitualLog.kExtra | eRitualLog.kPathing,
                Object_Description(self)
                + " reached target point " + Object_Description(trol));
            PunchUp("ExtraReachedTarget", trol);
        } else {
            RitualLog(eRitualLog.kExtra | eRitualLog.kPathing,
                Object_Description(self)
                + " reached non-target point " + Object_Description(trol)
                + ", continuing on to " + Object_Description(Link_GetCurrentPatrol(self)));
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
        RitualLog(eRitualLog.kExtra | eRitualLog.kAlertness,
            Object_Description(self)
            + message().oldLevel + " ===================> " + message().level);

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

    function PunchUp(message, data = 0, data2 = 0)
    {
        Link_BroadcastOnAllLinks(message, "~ScriptParams", self, data, data2);
    }

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
        RitualLog(eRitualLog.kExtra | eRitualLog.kPathing, 
            Object_Description(self)
            + " new target is: " + Object.GetName(trol) + " (" + trol + ")");
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
        RitualLog(eRitualLog.kLaziness,
            Object_Description(self) + " is lazy.");

        // Start the tweq.
        Property.Set(self, "StTweqBlink", "AnimS", 1);
    }

    function OnTweqComplete()
    {
        // Don't try to stop looking if we're busy attacking!
        if (! Link.AnyExist("AIAttack", self)) {
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " is at alert " + AI_AlertLevel(self) + " and still lazy.");
            ExpireAwareness();
        } else {
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " is busy attacking something.");
        }
    }

    function OnAlertness()
    {
        if (message().level < 2) {
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " has calmed down. Back to work.");
            // Laziness worked, we can stop checking that we're lazy enough.
            Object.RemoveMetaProperty(self, "M-RitualLazyExtra");
        }
    }

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " is brain dead. Back to work (or not).");
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
                    RitualLog(eRitualLog.kLaziness,
                        Object_Description(self) + " continuing fresh (" + age + "s) investigation: " + Awareness_Description(invest_link));
                    return;
                } else {
                    RitualLog(eRitualLog.kLaziness,
                        Object_Description(self) + " investigation is getting old (" + age + "s): " + Awareness_Description(invest_link));
                }
            } else {
                RitualLog(eRitualLog.kLaziness,
                    Object_Description(self) + " has no awareness link for its investigation.");
            }
        } else {
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " is not investigating.");
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
                RitualLog(eRitualLog.kLaziness,
                    "Ignoring low level: " + Awareness_Description(link));
                ignore = true;
            } else if (is_hostile_team) {
                if (is_old) {
                    // Guess it was just rats again.
                    RitualLog(eRitualLog.kLaziness,
                        "Destroying old (" + age + "s) hostile: " + Awareness_Description(link));
                    destroy = true;
                } else {
                    RitualLog(eRitualLog.kLaziness,
                        "Keeping recent (" + age + "s) hostile: " + Awareness_Description(link));
                }
            } else if (is_same_team) {
                if (is_me) {
                    if (is_old) {
                        // Well, I heard something, but that was a while ago.
                        RitualLog(eRitualLog.kLaziness,
                            "Destroying old (" + age + "s) heard: " + Awareness_Description(link));
                        destroy = true;
                    } else {
                        RitualLog(eRitualLog.kLaziness,
                            "Keeping recent (" + age + "s) heard: " + Awareness_Description(link));
                    }
                } else {
                    if (is_dead) {
                        // Friendly corpses aren't interesting once an investigation is over.
                        if (have_los) {
                            // But if it's still in sight, there's not much we can do,
                            // they *will* stay alert despite our best efforts.
                            RitualLog(eRitualLog.kLaziness,
                                "Friendly corpse is in sight, leaving it alone: " + Awareness_Description(link));
                        } else {
                            // But keep the link around so they don't forget and start investigating it again.
                            RitualLog(eRitualLog.kLaziness,
                                "Expiring friendly corpse: " + Awareness_Description(link));
                            expire = true;
                        }
                    } else {
                        // Friends don't let friends stay angry.
                        RitualLog(eRitualLog.kLaziness,
                            "Conditionally destroying friendly: " + Awareness_Description(link));
                        conditionally_destroy = true;
                    }
                }
            } else {
                // Neutral team? Can they even alert you? Don't care, let's get rid of it.
                RitualLog(eRitualLog.kLaziness,
                    "Destroying neutral: " + Awareness_Description(link));
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
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " is destroying its investigation (if any).");
            Link_DestroyAll("AIInvest", self);

            // And destroy the conditional ones
            foreach (link in conditionally_destroy_links) {
                RitualLog(eRitualLog.kLaziness,
                    "Actually destroying conditional: " + Awareness_Description(link));
                Link.Destroy(link);
            }
        }

        if (keep_count == 0) {
            RitualLog(eRitualLog.kLaziness,
                "CONCLUSION: No reason for " + Object_Description(self) + " to stay alert.");
            // HACK: sometimes despite all the awareness fudging, sometimes they don't calm
            // down soon enough. So let's force them to for now.
            // But if there's a body sitting right in front of them, they'll stay constantly on the
            // alert no matter what. Not much I can do about that.
            Property.Set(self, "AI_Alertness", "Level", 1);
            Property.Set(self, "AI_Alertness", "Peak", 1);
        } else {
            RitualLog(eRitualLog.kLaziness,
                "CONCLUSION: " + Object_Description(self) + " should stay alert, there's trouble out there.");
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
