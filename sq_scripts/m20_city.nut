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