// This enormous pile of bad code controls the big ritual setpiece
// at the end of the mission. Tread carefully, for here be jackals.

const DEBUG_GETONWITHIT = false;
const DEBUG_SKIPTOTHEEND = false;
const DEBUG_DISABLESTROBES = false;

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
    kSearching      = 2048,
}

RitualLogsEnabled <- function()
{
    return (0
        // Subjects
        | eRitualLog.kRitual
//        | eRitualLog.kPerformer
//        | eRitualLog.kExtra
//        | eRitualLog.kVictim
//        | eRitualLog.kLighting
//        | eRitualLog.kFinale
        // Contexts
//        | eRitualLog.kPathing
//        | eRitualLog.kAlertness
//        | eRitualLog.kLaziness
//        | eRitualLog.kSearching
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
    if ((log & eRitualLog.kSearching) != 0) { names.append("SEARCHING"); }
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

enum eRitualAbort
{
    kMissingHand        = 0,
    kMissingVictim      = 1,
    kPerformerBrainDead = 2,
    kPerformerAlerted   = 3,
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
    // FIXME: If the M-RitualTrance time warp is changed, need to adjust timing in OnLastBlessing()
    // FIXME: If the stages are changed, also need to adjust the LineNo 0-6 tags in the conv schema.
    // FIXME: If the stages are changed, the extras' starting points should also be updated.
    // FIXME: Actually I need to put the extras in starting positions anyway!
    // FIXME: If the stages or timing are changed, the timing of the particle systems should also be updated.
    // We skip the first stage, as we pretend it was done before the player arrives.
    stages = [2, 5, 1, 4, 0, 3, 6];
    //stages = [0, 1, 2, 3, 4, 5, 6]; // very fast
    //stages = [4, 2, 0, 5, 3, 1, 6]; // very slow

    function OnSim()
    {
        if (message().starting) {
            if ((Status() == null) || (StageIndex() == null)) {
                SetStatus(eRitualStatus.kNotStarted);
                // We always skip the first stage now; we pretend it happens
                // while Garrett is going through the caves.
                SetStageIndex(1);
                SetAwaitingExtras(Extras().len());
            }

            if (DEBUG_SKIPTOTHEEND) {
                SetStageIndex(6);
            }

            // Check linked objects needed for ...
            // ... the whole ritual ...
            Performer();
            Victim();
            Extras();
            // ... the main ritual ...
            PerfRoundTrols();
            DownConvs();
            ExtraRoundTrols();
            Markers();
            Strips();
            Particles();
            // ... the last stage ...
            DownTrols();
            Strobes();
            // ... the finale ...
            PerfWaitConv();
            FinaleConvs();
            Gores();
            BloodFX();
            ProphetSpawner();
            // ... aborting ...
            NoHandConv();
            NoVictimConv();

            // Start the performer in a trance so they won't spook
            // at anything before the ritual begins.
            RitualLog(eRitualLog.kPerformer, "Starting trance");
            local performer = Performer();
            if (performer != 0) {
                Object.AddMetaProperty(performer, "M-RitualTrance");
                if (DEBUG_GETONWITHIT) {
                    Object.AddMetaProperty(performer, "M-GetOnWithIt");
                }
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
            local stage_index = StageIndex();

            RitualLog(eRitualLog.kRitual, "Begin\n\n");

            // Skip any stages that come before this one.
            for (local i = 0; i < stage_index; i++) {
                SkipRound(i);
            }

            // First positions, everyone
            RitualLog(eRitualLog.kPerformer, "Teleporting directly to first position.");
            local performer = Performer();
            local trol = PerfRoundTrols()[stage];
            SendMessage(performer, "PatrolTo", trol, true);

            RitualLog(eRitualLog.kExtra, "All extras teleporting to first positions.");
            SendExtrasToVertices(stage, GetAvailableExtras(), true);

            // Seven times rounds and seven times downs - always begin with a round.
            StepRound();
        }
    }

    function SkipRound(stage_index)
    {
        local stage = stages[stage_index];
        RitualLog(eRitualLog.kRitual, "Skipping Round " + stage_index + ", Stage " + stage);

        // If we skip stages (only at the start), we still need to turn on their
        // effects!
        ActivateStrip(stage_index);
        ActivateParticles(stage_index);
    }

    function StepRound()
    {
        local stage = Stage();
        local stage_index = StageIndex();
        RitualLog(eRitualLog.kRitual, "Round " + stage_index + ", Stage " + stage);

        // Send the performer to their vertex
        local performer = Performer();
        local trol = PerfRoundTrols()[stage];
        SendMessage(performer, "PatrolTo", trol, false);

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
        RitualLog(eRitualLog.kRitual, "Down " + stage_index + ", Stage " + stage);

        // Normal lighting is for normal stages, not the last stage.
        if (Status() == eRitualStatus.kInProgress) {
            local marker = Markers()[stage];
            local prev_marker = Markers()[PreviousStage()];
            RitualLog(eRitualLog.kLighting, "Turning off " + Object_Description(prev_marker));
            SendMessage(prev_marker, "TurnOff");
            RitualLog(eRitualLog.kLighting, "Turning on " + Object_Description(marker));
            SendMessage(marker, "TurnOn");

            ActivateStrip(stage_index);

            // Change the ambience for the final stage
            if (stage_index == 6) {
                ChangeAmbience("ritual4");
            }
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

        if (Status() == eRitualStatus.kInProgress) {
            local next_marker = Markers()[NextStage()];
            RitualLog(eRitualLog.kLighting, "Pulsing " + Object_Description(next_marker));
            SendMessage(next_marker, "Pulse");

            ActivateParticles(stage_index);

            // Update the ambience
            if (stage_index == 3) {
                ChangeAmbience("ritual2");
            } else if (stage_index == 5) {
                ChangeAmbience("ritual3");
            }
        }
    }

    // ---- The Last Stage

    function LastStage()
    {
        if (Status() == eRitualStatus.kInProgress) {
            SetStatus(eRitualStatus.kLastStage);

            // Make sure the extras don't patrol or get distracted anymore.
            foreach (extra in Extras()) {
                SendMessage(extra, "StopPatrolling");
                Object.AddMetaProperty(extra, "M-RitualFinaleTrance");
            }

            // The performer and extras get their chunks of meat and positions. Any gore
            // that is unclaimed is for the explosion.
            PickGoresAndRunToAltar();

            // Turn on the strobe lights (or substitute)
            local strobes = Strobes();
            RitualLog(eRitualLog.kLighting, "Strobes are enabled.");
            // Make all the strobes flash horrendously
            foreach (marker in Markers()) {
                RitualLog(eRitualLog.kLighting, "Strobing " + Object_Description(marker));
                SendMessage(marker, "Strobe");
            }
            foreach (strobe in Strobes()) {
                RitualLog(eRitualLog.kLighting, "Turning on " + Object_Description(strobe));
                SendMessage(strobe, "TurnOn");
            }

            local stage_index = StageIndex();
            ActivateStrip(stage_index);
            ActivateParticles(stage_index);

            // The Down conversation will handle taking us up to the end of the
            // blessing, so just continue on with the stage stuff.
            StepDown();
        }
    }

    // ---- The Grand Finale

    function Finale()
    {
        if (Status() == eRitualStatus.kLastStage) {
            SetStatus(eRitualStatus.kFinale);
            // The ritual's ended, but the show is just beginning!
            // Time for a grand finale before failing the mission.
            RitualLog(eRitualLog.kRitual, "Finale");

            // Performer stays entranced, but no longer patrosl, and now moves at normal speed.
            local performer = Performer();
            Object.RemoveMetaProperty(performer, "M-DoesPatrol");
            Object.RemoveMetaProperty(performer, "M-RitualTrance");
            Object.AddMetaProperty(performer, "M-RitualFinaleTrance");

            // Make sure di Rupo stays around at the altar while the extras get
            // here. HACK: we do that by giving her a new conversation to deal with.
            AI_SetIdleOrigin(performer, performer);
            AI.StartConversation(PerfWaitConv());

            // Now we wait for them all to tell us that they're ready (or
            // otherwise become unavailable).
            ContinueWhenAllExtrasReady();
        }
    }

    function PickGoresAndRunToAltar()
    {
        // For whatever mad reason, it's vertex 6 that's the performer's place
        // at the finale. Too late to renumber everything now. Well, it's not
        // really, but I'm too lazy. Anyway the performer gets the victim's head.
        // And they should already be in position.
        local performer = Performer();
        Link_CreateScriptParams("PoundOfFlesh", performer, Gores()[6]);

        // Assign the remaining gores to available extras.
        local extras = GetAvailableExtras(true);
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

        // Keep any unclaimed gore bits ourselves for the explosion.
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
        RitualLog(eRitualLog.kFinale, "All extras ready.");

        // Point of no return--well, that's in just a moment when we RIP AND TEAR!
        // Make sure it's too late to rescue the Anax
        RitualLog(eRitualLog.kFinale, "Point of no return! You can't rescue the victim now.");
        Object_AddFrobAction(Victim(), eFrobAction.kFrobActionIgnore);

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
        local gores = Gores().slice(0, 6);
        local available_gores = Link_GetAllParams("PoundOfFlesh", self);
        local z_angles = [141.429, 192.857, 244.286, 295.714, 347.143, 38.571, 90.0];
        foreach (gore in available_gores) {
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

    function ActivateStrip(stage_index) {
        // Turn on this strip (and anything it's controlling!)
        local stage = stages[stage_index];
        local strip = Strips()[stage];
        RitualLog(eRitualLog.kLighting, "Turning on " + Object_Description(strip));
        SendMessage(strip, "TurnOn");

        // For the last stage, make all the strips glow steadily
        if (stage_index == 6) {
            foreach (strip in Strips()) {
                RitualLog(eRitualLog.kLighting, "Turning fully on " + Object_Description(strip));
                PostMessage(strip, "Fullbright");
            }
        }
    }

    function ActivateParticles(stage_index) {
        if (stage_index == 1) {
            // Start the big slow-build particles
            local particles = Particles();
            SendMessage(particles[0], "TurnOn");
        } else if (stage_index == 3) {
            // Start the medium particles
            local particles = Particles();
            SendMessage(particles[1], "TurnOn");
        } else if (stage_index == 5) {
            // Start the small intense person-shaped particles
            local particles = Particles();
            SendMessage(particles[2], "TurnOn");
        }
    }

    // ---- The End

    function End()
    {
        if (Status() == eRitualStatus.kFinale) {
            SetStatus(eRitualStatus.kEnded);
            RitualLog(eRitualLog.kRitual, "End");

            // Begin the countdown to mission failure.
            SendMessage(self, "RitualEnded");
        }
    }

    // ---- The Player Intervened

    function Abort(reason)
    {
        // Give the performer a moment to react.
        if ((Status() == eRitualStatus.kInProgress)
            || (Status() == eRitualStatus.kLastStage))
        {
            SetStatus(eRitualStatus.kAborted);
            RitualLog(eRitualLog.kRitual, "Abort");

            // Wake the performer from her trance (if not dead), and make
            // them look like they're searching for the player.
            local performer = Performer();
            if (AI_Mode(performer) != eAIMode.kAIM_Dead) {
                Object.RemoveMetaProperty(performer, "M-RitualTrance");
                Object.RemoveMetaProperty(performer, "M-RitualFinaleTrance");
                Object.RemoveMetaProperty(performer, "M-DoesPatrol");

                // HACK: you'll notice all the DownConvs have a Wait(100) between
                // sending PerformerReachedAltar and starting the blessing. This
                // allows the conversations below to get their speech in first--
                // otherwise the blessing speech plays despite (for example) the
                // hand having gone missing! I needed this hack because I couldn't
                // find a way to get this speech to be overrule the other (priority
                // settings in schema didn't affect it), nor could I reliably just
                // stop the other speech without muting the performer. It's all bad.
                if (reason == eRitualAbort.kMissingHand) {
                    AI.StartConversation(NoHandConv());
                } else if (reason == eRitualAbort.kMissingVictim) {
                    AI.StartConversation(NoVictimConv());
                } else {
                    // HACK: abort the down conversation by playing another.
                    AI.StartConversation(PerfWaitConv());
                }
                // We'll finish aborting when the conversation is done.
            } else {
                // Performer's dead, finish up right now.
                FinishAborting();
            }
        }
    }

    function FinishAborting()
    {
        if (Status() == eRitualStatus.kAborted) {
            RitualLog(eRitualLog.kRitual, "FinishAborting");

            // Stop the particle effects (they may take a while)
            local particles = Particles();
            foreach (particle in particles) {
                SendMessage(particle, "TurnOff");
            }

            // Stop the strips and whatever they control
            local strips = Strips();
            foreach (strip in strips) {
                SendMessage(strip, "TurnOff");
            }

            // Make the performer search for the player
            local performer = Performer();
            if (AI_Mode(performer) != eAIMode.kAIM_Dead) {
                // Bring out a weapon.
                SendMessage(performer, "DrawDagger");

                // Make sure the performer will investigate a little before searching.
                // These are singleton links, so destroy any existing ones first!
                local player = Object.Named("Player");
                Link_DestroyAll("AIInvest", performer);
                Link.Create("AIInvest", performer, player);
                Link_DestroyAll("AIAwareness", performer, player);
                Link.Create("AIAwareness", performer, player);

                // Even after investigating, the performer should search around endlessly,
                // starting at a random point.
                Object.AddMetaProperty(performer, "M-RitualSearcher");
            }

            // Make all the extras search too.
            foreach (extra in Extras()) {
                if (AI_Mode(extra) != eAIMode.kAIM_Dead) {
                    Object.RemoveMetaProperty(extra, "M-RitualFinaleTrance");
                    Object.RemoveMetaProperty(extra, "M-DoesPatrol");
                    Object.RemoveMetaProperty(extra, "M-RitualLazyExtra");
                    Object.AddMetaProperty(extra, "M-RitualSearcher");
                }
            }

            // Stop here if we're not waiting for the performer
            if (AI_Mode(performer) == eAIMode.kAIM_Dead) {
                Die("Well done, you stopped the ritual!");
            }
        }
    }

    // ---- Errors

    function Die(reason)
    {
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        print("RITUAL DEATH: " + reason);
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        Object.Destroy(self);
    }

    // ---- Utilities

    function GetAvailableExtras(ignore_busy = false)
    {
        local extras = Extras();
        local available_extras = [];
        // Find the extras available to participate in this round:
        // those who are dead, unconscious, or off searching for
        // or attacking the player are excused.
        foreach (extra in extras) {
            if (AI_Mode(extra) == eAIMode.kAIM_Dead) {
                RitualLog(eRitualLog.kExtra | eRitualLog.kAlertness,
                    Object_Description(extra) + " is at dead, and temporarily excused.");
            } else if ((! ignore_busy) && (Link.AnyExist("AIAttack", extra) || Link.AnyExist("AIInvest", extra))) {
                RitualLog(eRitualLog.kExtra | eRitualLog.kAlertness,
                    Object_Description(extra) + " is at attacking or investigating, and temporarily excused.");
            } else {
                available_extras.append(extra);
            }
        }
        RitualLog(eRitualLog.kExtra, available_extras.len() + " extras available.");
        return available_extras;
    }

    function SendExtrasToVertices(stage, extras, teleport = false)
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
            local closest_trol = (teleport ? -1 : FindClosestTrol(Object.Position(extra), trols));
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

    function ChangeAmbience(region) {
        local room = Object.Named("RoomRitualChamber");
        if (room == 0) { print("XXXXXX Can't find RoomRitualChamber"); return; }
        Property.Set(room, "Ambient", "Schema Name", region)
        local controller = Object.Named("AmbienceController");
        if (controller == 0) return;
        PostMessage(controller, "RegionChange", region);
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
            if (StageIndex() == (stages.len() - 1)) {
                LastStage();
            } else {
                StepDown();
            }
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
        }
    }

    function OnPerformerConsumedHand()
    {
        if (Status() == eRitualStatus.kLastStage) {
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

    // ---- Messages from performers, extras etc.

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
        // Well, I _suppose_ we can leave you out of the rest of the ritual
        local extra = message().from;
        RitualLog(eRitualLog.kExtra, Object_Description(extra) + " is excused from the ritual due to brain death.");
        Link_DestroyAll("ScriptParams", self, extra);
        MarkExtraAsUnavailable(extra);
    }

    function OnRipAndTear()
    {
        if (Status() == eRitualStatus.kFinale) {
            // This is the real point of no return!
            RitualLog(eRitualLog.kFinale,
                "Rip and tear! RIP AND TEAR!   ! ~  R I P  ~  A N D  ~  T E A R  ~ !");

            // Play a sound for the summoning of the prophet
            Sound.PlaySchemaAmbient(self, "nbritfinale2");
            // Also change the ambience
            ChangeAmbience("ritual5");

            TearVictimApart();
            ExplodeVictim();
            SendMessage(ProphetSpawner(), "TurnOn");
            End();
        }
    }

    function OnConversationFinished()
    {
        local name = message().data;
        if ((name == "NoHandConv")
            || (name == "NoVictimConv")
            || (name == "PerfWaitConv"))
        {
            if (Status() == eRitualStatus.kAborted) {
                FinishAborting();
            }
        }
    }

    // ---- Messages of abort conditions

    function OnPerformerNoticedHandMissing()
    {
        RitualLog(eRitualLog.kRitual, "Hand has been stolen");
        Abort(eRitualAbort.kMissingHand);
    }

    function OnPerformerNoticedVictimMissing()
    {
        RitualLog(eRitualLog.kRitual, "Victim has been unkidnapped");
        Abort(eRitualAbort.kMissingVictim);
    }

    function OnPerformerAlerted()
    {
        RitualLog(eRitualLog.kRitual, "Performer alerted");
        Abort(eRitualAbort.kPerformerAlerted);
    }

    function OnPerformerBrainDead()
    {
        RitualLog(eRitualLog.kRitual, "Performer is brain dead");
        Abort(eRitualAbort.kPerformerBrainDead);
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

    function NextStage() {
        local next_index = ((StageIndex() + 1) % 7);
        return stages[next_index];
    }

    function PreviousStage() {
        local prev_index = ((StageIndex() + 6) % 7);
        return stages[prev_index];
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

    function Markers()
    {
        local markers = Link_GetAllParams("Marker", self);
        if (markers.len() != 7) { Die("need 7 Marker(s)."); }
        return markers;
    }

    function Strips()
    {
        local strips = Link_GetAllParams("Strip", self);
        if (strips.len() != 7) { Die("need 7 Strip(s)."); }
        return strips;
    }

    function Particles()
    {
        local particles = Link_GetAllParams("Particles", self);
        if (particles.len() != 3) { Die("need 3 Particles."); }
        return particles;
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

    function NoHandConv()
    {
        local conv = Link_GetOneParam("NoHandConv", self);
        if (conv == 0) { Die("no NoHandConv."); }
        return conv;
    }

    function NoVictimConv()
    {
        local conv = Link_GetOneParam("NoVictimConv", self);
        if (conv == 0) { Die("no NoVictimConv."); }
        return conv;
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

    function ProphetSpawner()
    {
        local obj = Link_GetOneParam("ProphetSpawner", self);
        if (obj == 0) { Die("no ProphetSpawner."); }
        return obj;
    }
}


class RitualPerformer extends SqRootScript
{
    // ---- Messages from the controller

    function OnPatrolTo()
    {
        local trol = message().data;
        local teleport = message().data2;

        SetPatrolTarget(trol);
        if (teleport) {
            Object.Teleport(self, Object.Position(trol), Object.Facing(trol));
            ReachedPatrolTarget(trol);
        } else {
            if (Link_GetCurrentPatrol(self) == 0) {
                Link_SetCurrentPatrol(self, trol);
            }
            Object.AddMetaProperty(self, "M-DoesPatrol");
        }
    }

    function OnWait()
    {
        local conv = Link_GetOneParam("WaitConv", self);
        if (conv != 0) {
            AI.StartConversation(conv);
        } else {
            RitualLog(eRitualLog.kPerformer, "ERROR: no WaitConv.");
        }
    }

    // ---- Messages from AI and scripts

    function OnPatrolPoint()
    {
        // Tell the controller we've reached another patrol point (not necessarily the right one)
        local trol = message().patrolObj;
        if (trol == GetPatrolTarget()) {
            RitualLog(eRitualLog.kPerformer | eRitualLog.kPathing, "reached target: " + Object.GetName(trol) + " (" + trol + ")");
            ReachedPatrolTarget(trol);
        } else {
            RitualLog(eRitualLog.kPerformer | eRitualLog.kPathing, "reached trol: " + Object.GetName(trol) + " (" + trol + ")");
        }
    }

    function OnStartWalking()
    {
        PunchUp("PerformerFacedAltar");
    }

    function OnNoticedVictimMissing()
    {
        RitualLog(eRitualLog.kPerformer, "noticed victim has gone missing.");
        PunchUp("PerformerNoticedVictimMissing");
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
                // The hand's been stolen!
                RitualLog(eRitualLog.kPerformer, "noticed hand has gone missing.");
                PunchUp("PerformerNoticedHandMissing");
            }
        } else {
            // The hand's been stolen!
            RitualLog(eRitualLog.kPerformer, "noticed hand has gone missing.");
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

    function OnLastBlessingStart()
    {
        RitualLog(eRitualLog.kPerformer, "Last blessing starts.");

        // Play a sound that continues until the prophet appears
        Sound.PlaySchemaAmbient(self, "nbritfinale1");

        // The last blessing is happening. Start a timer for consuming the
        // hand, so it happens mid-motion.
        SetOneShotTimer("ConsumeHand", 2.0);
    }

    function OnTimer()
    {
        if (message().name == "ConsumeHand") {
            // Make the Hand vanish! It's consumed by magic, dummy, you don't eat it.
            local hand = Link_GetOneParam("Hand", self);
            if (hand != 0) {
                RitualLog(eRitualLog.kPerformer, "Consuming the Hand.");

                // Spawn an effect for the hand being consumed
                local fx = Object.BeginCreate("FinaleHandExplode");
                if (fx != 0) {
                    Object.Teleport(fx, vector(0,0,0), vector(0,0,0), hand);
                    Object.EndCreate(fx);
                    // The hand animation has 18 frames, at 15fps, so let's
                    // destroy it when we're done.
                    SetOneShotTimer("FinaleHandExplode", (18.0 / 15.0), fx);
                }

                // This destroys the hand and its hacked particles. Nice!
                Object.Destroy(hand);
            } else {
                RitualLog(eRitualLog.kPerformer, "ERROR: Can't find the Hand!");
            }
            PunchUp("PerformerConsumedHand")

        } else if (message().name == "FinaleHandExplode") {
            // Clean up the animation
            RitualLog(eRitualLog.kPerformer, "Cleaning up Hand fx.");
            local fx = message().data;
            if (fx != 0) {
                Object.Destroy(fx);
            }
        }
    }

    function OnConversationFinished()
    {
        local name = message().data;
        if (name == "DownConv") {
            // Tell the controller we've finished going down
            PunchUp("PerformerReturnedToVertex");
        } else {
            RitualLog(eRitualLog.kPerformer, "conversation finished: " + name);
            PunchUp(message().message, message().data);
        }
    }

    function OnAlertness()
    {
        RitualLog(eRitualLog.kPerformer | eRitualLog.kAlertness,
            Object_Description(self) + " alertness "
            + message().oldLevel + " ======> " + message().level);

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

    function ReachedPatrolTarget(trol)
    {
        SetPatrolTarget(0);
        PunchUp("PerformerReachedTarget", trol);
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

class RitualExtra extends SqRootScript
{
    // ---- Messages from the controller

    function OnPatrolTo()
    {
        local trol = message().data;
        local start_at_trol = message().data2;
        local direct = (start_at_trol == 0);
        local teleport = (start_at_trol < 0);
        SetPatrolTarget(trol);
        if (teleport) {
            Object.Teleport(self, Object.Position(trol), Object.Facing(trol));
            RitualLog(eRitualLog.kExtra | eRitualLog.kPathing,
                Object_Description(self)
                + " teleporting to " + Object_Description(trol));
            ReachedPatrolTarget(trol);
        } else if (direct) {
            // Go directly to the target
            Link_SetCurrentPatrol(self, trol);
            Object.AddMetaProperty(self, "M-DoesPatrol");
            RitualLog(eRitualLog.kExtra | eRitualLog.kPathing,
                Object_Description(self)
                + " patrolling directly to " + Object_Description(trol));
        } else {
            // If we're not already patrolling, use the suggested start point
            if (Link_GetCurrentPatrol(self) == 0) {
                Link_SetCurrentPatrol(self, start_at_trol);
            }
            Object.AddMetaProperty(self, "M-DoesPatrol");
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
            ReachedPatrolTarget(trol);
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
            Object_Description(self) + " alertness "
            + message().oldLevel + " ======> " + message().level);

        // If we're searching, let it handle alertness.
        if (! Object.HasMetaProperty(self, "M-RitualSearcher")) {

            if ((message().level > message().oldLevel)
                && (message().level >= eAIScriptAlertLevel.kModerateAlert))
            {
                // Stop patrolling and forget where we were going, so that when
                // we return to the ritual, we can go to our last idle spot instead.
                Object.RemoveMetaProperty(self, "M-DoesPatrol");
                Link_DestroyAll("AICurrentPatrol", self);
            }
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

    function ReachedPatrolTarget(trol)
    {
        PunchUp("ExtraReachedTarget", trol);
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
    }


    function OnEndScript()
    {
        RitualLog(eRitualLog.kLaziness,
            Object_Description(self) + " is no longer lazy.");
        Property.Set(self, "StTweqBlink", "AnimS", 0);
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
        if (message().level >= 2) {
            // Start the tweq.
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " is alert, but lazy.");
            Property.Set(self, "StTweqBlink", "AnimS", 1);
        } else if (message().level < 2) {
            // Laziness worked, we can stop checking that we're lazy enough.
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " has calmed down. Back to work.");
            Property.Set(self, "StTweqBlink", "AnimS", 0);
        }
    }

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            RitualLog(eRitualLog.kLaziness,
                Object_Description(self) + " is brain dead. Back to work (or not).");
            // We're brain dead, stop caring.
            Property.Set(self, "StTweqBlink", "AnimS", 0);
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

class RitualSearcher extends SqRootScript
{
    function OnBeginScript()
    {
        RitualLog(eRitualLog.kSearching,
            Object_Description(self) + " now searching.");

        // Pick a random search trol to start
        local trols = Link_CollectPatrolPath(Link_GetAllParams("SearchTrol", self));
        if (trols.len() > 0) {
            local i = Data.RandInt(0, (trols.len() - 1));
            local trol = trols[i];
            if (trol != 0) {
                RitualLog(eRitualLog.kSearching,
                    Object_Description(self) + " starting search at " + Object_Description(trol));
                Link_SetCurrentPatrol(self, trol);
            } else {
                RitualLog(eRitualLog.kSearching,
                    "ERROR: " Object_Description(self) + " can't find SearchTrol(s).");
            }
        }

        // These metaproperties govern walking around with the "Search"
        // motion tags on low alert, and without them on high alert.
        if (AI_AlertLevel(self) >= 3) {
            Object.AddMetaProperty(self, "M-RitualSearchHigh");
        } else {
            Object.AddMetaProperty(self, "M-RitualSearchModerate");
        }
    }

    function PlaySearchConv()
    {
        local conv = Link_GetOneParam("SearchConv", self);
        if (conv != 0) {
            AI.StartConversation(conv);
        } else {
            RitualLog(eRitualLog.kSearching,
                "ERROR: " Object_Description(self) + " can't find SearchConv.");
        }
    }

    function OnPatrolPoint()
    {
        local trol = message().patrolObj;
        RitualLog(eRitualLog.kSearching,
            Object_Description(self) + " is at " + Object_Description(trol));
        PlaySearchConv();
    }
}


class RitualProphetSpawner extends SqRootScript
{
    function OnTurnOn()
    {
        SetOneShotTimer("Spawn", 2.0);
    }

    function OnTimer()
    {
        if (message().name == "Spawn") {
            // Teleport the Prophet here, dismiss the particles, and animate him.
            local prophet = Link_GetOneParam("Prophet", self);
            local particle_hack = Link_GetOneParam("ParticleHack", self);
            local conv = Link_GetOneParam("ProphetConv", self);
            Object.Teleport(prophet, vector(0,0,0), vector(0,0,0), self);
            SendMessage(particle_hack, "TurnOn");
            AI.StartConversation(conv);
        }
    }
}


class RitualParticleHack extends SqRootScript
{
    function OnTurnOn()
    {
        // Let me fall! The attached particles will fall with me.
        if (Property.Possessed(self, "PhysControl")) {
            Property.Set(self, "PhysControl", "Controls Active", 0);
        }
    }
}


class RitualCrystal extends SqRootScript
{
    function OnSim() {
        if (message().starting) {
            // Start in the off state
            PostMessage(self, "TurnOff");
        }
    }

    function OnTurnOn() {
        LightMode(ANIM_LIGHT_MODE_MAXIMUM);
        SetFlickering(false);
        Illuminate(1.0);
        AmbientHack(true);
    }

    function OnTurnOff() {
        LightMode(ANIM_LIGHT_MODE_MINIMUM);
        SetFlickering(false);
        Illuminate(0.15);
        AmbientHack(true);
    }

    function OnPulse() {
        LightSpeed(1000);
        LightMode(ANIM_LIGHT_MODE_SMOOTH);
        SetFlickering(true);
        AmbientHack(true);
    }

    function OnStrobe() {
        LightSpeed(200);
        LightMode(ANIM_LIGHT_MODE_MINIMUM);
        SetFlickering(true);
        AmbientHack(true);
    }

    function OnDisable() {
        LightMode(ANIM_LIGHT_MODE_EXTINGUISH);
        SetFlickering(false);
        // Ew gross. These numbers don't make sense, but
        // this is as low as we can go without parts of
        // us looking solid black!
        Illuminate(-0.04);
        AmbientHack(false);
    }

    function OnEnable() {
        // Do nothing, we need more specific instructions.
    }

    function OnImDyingHere() {
        LightMode(ANIM_LIGHT_MODE_EXTINGUISH);
        SetFlickering(false);
        // Ew gross. See OnDisable();
        Illuminate(-0.04);
        AmbientHack(false);
    }

    function OnTweqComplete() {
        if ((message().Type == eTweqType.kTweqTypeFlicker)
            && (message().Op == eTweqOperation.kTweqOpFrameEvent))
        {
            Illuminate(GetAnimLightIntensity(false));
        }
    }

    function LightSpeed(milliseconds) {
        if (Property.Possessed(self, "AnimLight")) {
            Property.Set(self, "AnimLight", "millisecs to brighten", milliseconds);
            Property.Set(self, "AnimLight", "millisecs to dim", milliseconds);
        }
    }

    function LightMode(mode) {
        if (Property.Possessed(self, "AnimLight")) {
            Light.SetMode(self, mode);
        }
    }

    function Illuminate(amount) {
        if (amount < -1.0) { amount = -1.0; }
        if (amount > 1.0) { amount = 1.0; }

        // if (Property.Possessed(self, "SelfIllum")) {
        //     Property.SetSimple(self, "SelfIllum", amount);
        // }

        if (Property.Possessed(self, "ExtraLight")) {
            Property.Set(self, "ExtraLight", "Amount (-1..1)", amount);
        }
    }

    function GetAnimLightIntensity(relative_to_min_brightness) {
        // Returns the light intensity as a float between 0.0 and 1.0
        // If relative_to_min_brightness, then 0.0 means the light is
        // at its min brightness; otherwise 0.0 means the light is at
        // zero brightness.
        if (Property.Possessed(self, "AnimLight")) {
            // We can still get a tweqcomplete after disable sometimes,
            // so just double check the light is still on.
            if (Light.GetMode(self) == ANIM_LIGHT_MODE_EXTINGUISH) {
                return 0.0;
            }

            local rise_period = Property.Get(self, "AnimLight", "millisecs to brighten");
            local fall_period = Property.Get(self, "AnimLight", "millisecs to dim");
            local max_brightness = Property.Get(self, "AnimLight", "max brightness");
            local min_brightness = Property.Get(self, "AnimLight", "min brightness");
            local rising = Property.Get(self, "AnimLight", "currently rising?");
            local countdown = Property.Get(self, "AnimLight", "current countdown");

            // Figure out how bright to appear from the light's brightness
            local relative_intensity = (rising
                ? ((rise_period - countdown).tofloat() / rise_period)
                : (countdown.tofloat() / fall_period));
            if (relative_to_min_brightness) {
                local brightness_range = (max_brightness - min_brightness);
                local brightness = (min_brightness + (relative_intensity * brightness_range));
                local absolute_intensity = ((max_brightness > 0.0)
                    ? (brightness / max_brightness)
                    : 0.0);
                return absolute_intensity;
            } else {
                return relative_intensity;
            }
        } else {
            return 0.0;
        }
    }

    function AmbientHack(turned_on) {
        if (Property.Possessed(self, "AmbientHacked")) {
            local flags = Property.Get(self, "AmbientHacked", "Flags");
            if (! turned_on) {
                flags = (flags | AMBFLG_S_TURNEDOFF);
            } else {
                flags = (flags & ~AMBFLG_S_TURNEDOFF);
            }
            Property.Set(self, "AmbientHacked", "Flags", flags);
        }
    }

    function SetFlickering(on) {
        if (Property.Possessed(self, "StTweqBlink")) {
            // Turn on or off the flicker tweq
            local animS = Property.Get(self, "StTweqBlink", "AnimS");
            animS = (on ? (animS | TWEQ_AS_ONOFF) : (animS & ~TWEQ_AS_ONOFF));
            Property.Set(self, "StTweqBlink", "AnimS", animS);
        }
    }
}

class RitualMarker extends RitualCrystal
{
    function OnBeginScript() {
        if (! IsDataSet("State")) {
            SetData("State", 1);
        }
        if (! IsDataSet("SavedMessage")) {
            SetData("SavedMessage", "TurnOff");
        }
        if (! IsDataSet("ReenableTimer")) {
            SetData("ReenableTimer", 0);
        }
    }

    function OnTurnOn() {
        if (IsAlive()) {
            SaveMessage();
            if (IsEnabled()) {
                base.OnTurnOn();
                ForwardMessage();
            }
        }
    }

    function OnTurnOff() {
        if (IsAlive()) {
            SaveMessage();
            if (IsEnabled()) {
                base.OnTurnOff();
                // We want to be brighter than the fingers
                Illuminate(0.3);
                ForwardMessage();
            }
        }
    }

    function OnPulse() {
        if (IsAlive()) {
            SaveMessage();
            if (IsEnabled()) {
                base.OnPulse();
                ForwardMessage();
            }
        }
    }

    function OnStrobe() {
        if (IsAlive()) {
            SaveMessage();
            if (IsEnabled()) {
                base.OnStrobe();
                ForwardMessage();
            }
        }
    }

    function OnDisable() {
        if (IsAlive()) {
            if (IsEnabled()) {
                base.OnDisable();
                // We want to be brighter than the fingers
                Illuminate(0.0);
                ForwardMessage();
                // Stop acting on messages
                SetData("State", 0);
            }
            // If we're enabled we start it; if disabled we restart it.
            RestartTimer();
        }
    }

    function OnEnable() {
        if (IsAlive()) {
            if (IsEnabled()) {
                base.OnEnable();
                ForwardMessage();
            } else {
                // Resume acting on messages
                SetData("State", 1);
                base.OnEnable();
                ForwardMessage();
                SendSavedMessage()
            }
        }
    }

    function OnTimer() {
        if (message().name == "Reenable") {
            SetData("ReenableTimer", 0);
            PostMessage(self, "Enable");
        }
    }

    function OnSlain() {
        // Die
        SetData("State", 2);

        // Kill the timer if it's there
        StopTimer();

        // Do visual and audio effects
        // This is a hack, but it'll have to do.
        base.OnImDyingHere();

        // Become unrendered and nonphysical - we can't actually
        // let ourselves be destroyed, because that would break
        // the ritual controller!
        Property.SetSimple(self, "RenderType", 1);
        Property.Set(self, "CollisionType", "", 4);

        // Tell all our friends (the juggler will ignore it, but the others will respond)
        Link.BroadcastOnAllLinks(self, "ImDyingHere", "ControlDevice");

        // And disown any of our friends that hang around
        Link_DestroyAll("ControlDevice", self);
    }

    function IsEnabled() {
        return (GetData("State") == 1);
    }

    function IsAlive() {
        return (GetData("State") != 2);
    }

    function ForwardMessage() {
        Link.BroadcastOnAllLinks(self, message().message, "ControlDevice");
    }

    function SaveMessage() {
        SetData("SavedMessage", message().message);
    }

    function SendSavedMessage() {
        local message = GetData("SavedMessage");
        if (message != "") {
            SendMessage(self, message);
        }
    }

    function RestartTimer() {
        // Set a timer to reenable myself.
        StopTimer();
        local timer = SetOneShotTimer("Reenable", 15.0);
        SetData("ReenableTimer", timer);
    }

    function StopTimer() {
        local timer = GetData("ReenableTimer");
        if (timer != 0) {
            KillTimer(timer);
            SetData("ReenableTimer", 0);
        }
    }

    // A marker can be disabled with water, a blackjack, or KO gas.
    // Basically, reward the player for figuring it's part of the
    // solution, but don't be picky about their approach.

    function OnWaterStimStimulus() {
        SendMessage(self, "Disable");
    }

    function OnKnockoutStimulus() {
        SendMessage(self, "Disable");
    }

    function OnKOGasStimulus() {
        SendMessage(self, "Disable");
    }
}

class RitualLight extends SqRootScript
{
    // Just converts messages passed on from RitualMarker into
    // TurnOns and TurnOffs as appropriate

    function OnPulse() {
        SendMessage(self, "TurnOff");
    }

    function OnStrobe() {
        SendMessage(self, "TurnOff");
    }

    function OnDisable() {
        SendMessage(self, "TurnOff");
    }

    function OnImDyingHere() {
        Light.SetMode(self, ANIM_LIGHT_MODE_EXTINGUISH);
    }
}

class RitualPylon extends SqRootScript
{
    function OnTurnOn() {
        SetFlickering(true);
    }

    function OnTurnOff() {
        SetFlickering(false);
    }

    function OnTweqComplete() {
        if ((message().Type == eTweqType.kTweqTypeFlicker)
            && (message().Op == eTweqOperation.kTweqOpFrameEvent))
        {
            // Toggle self-illumination
            local selfillum = Property.Get(self, "ExtraLight", "Amount (-1..1)");
            selfillum = ((selfillum == 0.4) ? 1.0 : 0.4);
            Property.Set(self, "ExtraLight", "Amount (-1..1)", selfillum);
        }
    }

    function SetFlickering(on) {
        if (Property.Possessed(self, "StTweqBlink")) {
            // Turn on or off the flicker tweq
            local animS = Property.Get(self, "StTweqBlink", "AnimS");
            animS = (on ? (animS | TWEQ_AS_ONOFF) : (animS & ~TWEQ_AS_ONOFF));
            Property.Set(self, "StTweqBlink", "AnimS", animS);
        }
    }
}

class RitualBeamer extends SqRootScript
{
    function OnTurnOn() {
        Illuminate(true);
    }

    function OnTurnOff() {
        Illuminate(false);
    }

    function Illuminate(on) {
        // Toggle self-illumination
        local selfillum = Property.Get(self, "ExtraLight", "Amount (-1..1)");
        selfillum = (on ? 0.8 : 0.25);
        Property.Set(self, "ExtraLight", "Amount (-1..1)", selfillum);
    }
}
