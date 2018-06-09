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
