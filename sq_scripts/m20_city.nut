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

    previous_time = 0;
    period = 10.0;

    function OnTurnOff()
    {
        previous_time = message().time;
        SetFlickering(true);
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

class SwitchableJoints extends SqRootScript
{
    // Put this on an object with a Joints tweq.
    // When it receives TurnOn, it will turn on the joints;
    // when it receives TurnOff, it will turn them off again (what a twist!)
    function OnTurnOn() {
        if (Property.Possessed(self, "StTweqJoints")) {
            local animS = Property.Get(self, "StTweqJoints", "AnimS");
            animS = (animS | TWEQ_AS_ONOFF);
            Property.Set(self, "StTweqJoints", "AnimS", animS);
        }
    }

    function OnTurnOff() {
        if (Property.Possessed(self, "StTweqJoints")) {
            local animS = Property.Get(self, "StTweqJoints", "AnimS");
            animS = (animS & ~TWEQ_AS_ONOFF);
            Property.Set(self, "StTweqJoints", "AnimS", animS);
        }
    }
}

class TurbineSounds extends SqRootScript
{
    // Put this on a turbine object with an AmbientHacked.
    // When it receives TurnOn, it will play a start sound and turn on its sound.
    // when it receives TurnOff, it will turn them off again (what a twist!)
    function OnTurnOn() {
        // Immediately turn on the ambient loop
        if (Property.Possessed(self, "AmbientHacked")) {
            local flags = Property.Get(self, "AmbientHacked", "Flags");
            flags = (flags & ~AMBFLG_S_TURNEDOFF);
            Property.Set(self, "AmbientHacked", "Flags", flags);
        }

        Sound.HaltSchema(self, "m20turboff");
        Sound.PlaySchemaAtObject(self, "m20turbon", self);
    }

    function OnTurnOff() {
        // Immediately turn off the ambient loop
        if (Property.Possessed(self, "AmbientHacked")) {
            local flags = Property.Get(self, "AmbientHacked", "Flags");
            flags = (flags | AMBFLG_S_TURNEDOFF);
            Property.Set(self, "AmbientHacked", "Flags", flags);
        }

        Sound.HaltSchema(self, "m20turbon");
        Sound.PlaySchemaAtObject(self, "m20turboff", self);
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

        // Show the map
        Debug.Command("automap");
    }
}

class PleaseKillMe extends SqRootScript
{
    function OnFrobInvEnd() {
        Container.Remove(self);
        Object.Teleport(self, vector(2, 0, 2), vector(), Object.Named("Player"));
        Damage.Slay(self, 0);
    }
}
