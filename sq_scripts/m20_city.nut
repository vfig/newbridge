class BigClock extends SqRootScript
{
    // Put this on a ClockFace, and add a ScriptTiming property
    // set to the number of minutes past midnight for it to show.

    function OnBeginScript()
    {
        if (! IsDataSet("StartingTime")) {
            local now = GetTime();
            local minutesPastMidnight = Property.Get(self, "ScriptTiming");
            local start = (now - (60 * minutesPastMidnight));
            SetData("StartingTime", start);
        }

        if (! IsDataSet("UpdateTimer")) {
            local timer = SetOneShotTimer(self, 5);
            SetData("UpdateTimer", timer);
        }

        UpdateClockFace();
    }

    function OnTimer()
    {
        local timer;
        if (IsDataSet("UpdateTimer")) {
            timer = GetData("UpdateTimer");
            KillTimer(timer);
        }
        timer = SetOneShotTimer(self, 5);
        SetData("UpdateTimer", timer);

        UpdateClockFace();
    }

    function UpdateClockFace()
    {
        local start = GetData("StartingTime");
        local now = GetTime();
        local elapsed = (now - start);
        local minutes = (elapsed / 60.0) % 60.0;
        local hours = (elapsed / 3600.0) % 24.0;

        // 180 sets hour hand pointing straight down at midnight.
        // -57 sets minute hand straight up at zero.
        local minuteAngle = -57.0 + ((minutes * -360.0)) / 60.0;
        local hourAngle = 180.0 + ((hours * -360.0)) / 24.0;

        Property.Set(self, "JointPos", "Joint 2", minuteAngle);
        Property.Set(self, "JointPos", "Joint 1", hourAngle);
    }
}


class VanishingAct extends SqRootScript
{
    // Put this on an object with an inactive Flicker tweq, and an
    // Alpha property. When it receives the TurnOff message,
    // it will disappear in 10 seconds and then destroy itself.

    period = 10.0;

    function OnTurnOff()
    {
        SetData("VanishingTime", message().time);
        SetFlickering(true);
    }

    function OnTweqComplete()
    {
        // Figure out how much time has passed since the last update
        local time = message().time
        local previous_time = GetData("VanishingTime").tointeger();
        local elapsed = (time - previous_time) / 1000.0;
        if (elapsed < 0) {
            elapsed = 0;
        } else if (elapsed > period) {
            elapsed = period;
        }
        SetData("VanishingTime", message().time);

        // Calculate the alpha change corresponding to the elapsed time
        local alpha = Property.Get(self, "RenderAlpha", "").tofloat();
        alpha = alpha - (elapsed / period);
        if (alpha <= 0) {
            SetFlickering(false);
            Object.Destroy(self);
        }

        // Update alpha accordingly
        Property.Set(self, "RenderAlpha", "", alpha);
    }


    function SetFlickering(on) {
        // Turn on or off the flicker tweq
        local animS = Property.Get(self, "StTweqBlink", "AnimS");
        local newAnimS = (on ? (animS | 1) : (animS & ~1));
        Property.Set(self, "StTweqBlink", "AnimS", newAnimS);
    }
}

class VanishSoon extends VanishingAct
{
    // Begins vanishing after Script > Timing seconds
    function OnSim() {
        if (message().starting) {
            local timing = Property.Get(self, "ScriptTiming").tofloat();
            SetOneShotTimer("BeginVanishing", timing);
        }
    }

    function OnTimer() {
        if (message().name == "BeginVanishing") {
            SendMessage(self, "TurnOff");
        }
    }
}

class SetIdlingDirections extends SqRootScript
{
    // When a "SetIdlingDirection" message is received,
    // parameter 1 should be which field (1, 2, or 3),
    // and parameter 2 should be the facing direction.
    //
    // Note that Idling: Directions sets up its timer on
    // sim start, and the weight fields all have the same
    // name, so the only thing we can do from script is
    // change the directions.
    //
    // So, set up the AI initially with the times you
    // want and the weights you want, but set all the
    // directions initially to the same default.
    //
    function OnSetIdlingDirection() {
        if (Property.Possessed(self, "AI_IdleDirs")) {
            local fields = ["Facing 1: direction", "Facing 2: direction", "Facing 3: direction"];
            local field_index = message().data.tointeger() - 1;
            if (field_index < 0 || field_index > 2) { field_index = 0; }
            local angle = message().data2.tofloat();
            Property.Set(self, "AI_IdleDirs", fields[field_index], angle);
        }
    }
}

class ActivateMapPageOne extends SqRootScript
{
    function OnFrobInvEnd() {
        // Enable page 1 if it's not already
        local max_page = Quest.Get("map_max_page");
        if (max_page < 1) {
            Quest.Set("map_max_page", 1);
        }

        // Select page 1, and show the map.
        Quest.Set("map_cur_page", 1);
        Debug.Command("automap");
    }
}

class UpdateAutomap extends SqRootScript
{
    /* Put this on a concrete room, or a room archetype. If it has a
       "newmap" design note that's formatted as "page,location", then
       it waits for the quest variable "map_max_page" to change. When
       it does, if it's now >= the newmap page, then replace the
       automap property with the newmap values.

       Allows rooms to have an appropriate automap property to begin
       with, then a more specific one as more map pages are found. */
    function OnBeginScript() {
        if ("newmap" in userparams()) {
            Quest.SubscribeMsg(self, "map_max_page");
        }
    }

    function OnEndScript() {
        if ("newmap" in userparams()) {
            Quest.UnsubscribeMsg(self, "map_max_page");
        }
    }

    function OnQuestChange()
    {
        if ((message().m_pName == "map_max_page")
            && (message().m_oldValue != message().m_newValue)
            && ("newmap" in userparams())
            && (! IsDataSet("AutomapUpdated")))
        {
            local raw = userparams().newmap;
            local comma = raw.find(",");
            if (comma != null) {
                local page = raw.slice(0, comma).tointeger();
                local loc = raw.slice(comma + 1).tointeger();
                if (page <= message().m_newValue) {
                    Property.Set(self, "Automap", "Page", page);
                    Property.Set(self, "Automap", "Location", loc);
                    SetData("AutomapUpdated", true);
                }
            }
        }
    }
}

class CardTrick extends SqRootScript
{
    function OnSim() {
        if (! IsDataSet("CardCount")) {
            SetData("CardCount", 52);
        }
    }

    function OnFrobInvEnd() {
        local player = Object.Named("Player");
        local count = GetData("CardCount");
        local bad_luck = (Data.RandFlt0to1() > 0.90);
        if (bad_luck || (count <= 42)) {
            // Explode the pack
            Container.Remove(self);
            Object.Teleport(self, vector(2, 0, 2), vector(), player);
            Damage.Slay(self, 0);
        } else {
            // Launch a single card
            SetData("CardCount", (count - 1));
            local archetype = Object.Archetype(self);
            local link = Link.GetOne("Flinderize", archetype);
            if (link) {
                local flinder = LinkDest(link);
                // (270, 0, 90) puts the card in portrait orientation, with its
                // back facing the player.
                local variation = Data.RandFltNeg1to1();
                local facing = vector(
                    270 + 20.0 * variation,
                    0 + 20.0 * variation,
                    90.0 + 45.0 * variation);
                // Launch the card from just below the camera location.
                local offset = vector(0, 0, -1.0);
                local pos = (offset + Camera.GetPosition() - Object.Position(player));
                local card = Object.Create(flinder);
                Object.Teleport(card, pos, facing, player);
                // Launch the card forward and a little bit up. We don't use
                // Physics.LaunchProjectile, because it reorients the card!
                local vel = vector(45.0, 0, 5.0);
                local world_vel = (Camera.CameraToWorld(vel) - Camera.GetPosition());
                Physics.SetGravity(card, 1.0);
                Physics.SetVelocity(card, world_vel);
            }
        }
    }
}

class WakeMeUpInside extends SqRootScript
{
    // Wake me up (I'm the guard that's sleeping standing up) if I am turned
    // on for more than one second (no, not like that).
    wakeup_timer = 0;

    function OnTurnOn() {
        wakeup_timer = SetOneShotTimer("WakeMeUpInside", 1.0);
        AI.Signal(self, "WakeUp");
    }

    function OnTurnOff() {
        if (wakeup_timer != 0) {
            KillTimer(wakeup_timer);
            wakeup_timer = 0;
        }
    }

    function OnTimer() {
        if (message().name == "WakeMeUpInside") {
            wakeup_timer = 0;
            CantWakeUp();
        }
    }

    function CantWakeUp() {
        Object.AddMetaProperty(self, "M-StillGroggy");
        Object.RemoveMetaProperty(self, "M-SleepingStandingUp");
        AI.MakeGotoObjLoc(self, self, eAIScriptSpeed.kNormalSpeed, eAIActionPriority.kNormalPriorityAction, null);
    }
}

class ClearMyHead extends SqRootScript
{
    function OnBeginScript() {
        SetOneShotTimer("ClearMyHead", 4.0);
    }

    function OnTimer() {
        if (message().name == "ClearMyHead") {
            AI.ClearAlertness(self);
            Object.RemoveMetaProperty(self, "M-StillGroggy");
        }
    }
}
