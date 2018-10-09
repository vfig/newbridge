class AlasPoorBurrick extends SqRootScript
{
    function OnTurnOn() {
        local player = Object.Named("Player");
        Sound.PlayVoiceOver(player, "alaspoorburrick");
    }
}

class InfuriatingPainting extends SqRootScript
{
    function OnFrobWorldEnd() {
        // Make the painting level... for a short while
        Object.AddMetaProperty(self, "FrobInert");
        if (ReadyToChangeDroopTo(false)) {
            ActReact.React("tweq_control", 1.0, self, 0,
                eTweqType.kTweqTypeRotate,
                eTweqDo.kTweqDoDefault);
        }
    }

    function OnTimer() {
        if (message().name == "Droop") {
            if (ReadyToChangeDroopTo(true)) {
                ActReact.React("tweq_control", 1.0, self, 0,
                    eTweqType.kTweqTypeRotate,
                    eTweqDo.kTweqDoDefault);
            }
        }
    }

    function OnTweqComplete() {
        if ((message().Type == eTweqType.kTweqTypeRotate)
            && (message().Dir == eTweqDirection.kTweqDirForward))
        {
            // It's drooped, it can be frobbed to undroop.
            Object.RemoveMetaProperty(self, "FrobInert");
        } else {
            // Set a timer for it to droop again
            local timing = Property.Get(self, "ScriptTiming").tofloat();
            SetOneShotTimer("Droop", timing)
        }
    }

    function ReadyToChangeDroopTo(drooped) {
        local AnimS = Property.Get(self, "StTweqRotate", "AnimS");
        local isActive = ((AnimS & TWEQ_AS_ONOFF) != 0);
        local isReverse = ((AnimS & TWEQ_AS_REVERSE) != 0);
        if (isActive) {
            return false;
        } else {
            return (drooped == (! isReverse));
        }
    }
}

class ButlerRoomBell extends SqRootScript
{
    function OnTurnOn() {
        Activate();
    }

    function OnFrobWorldEnd() {
        Activate();
    }

    function Activate() {
        Sound.PlaySchemaAtObject(self, "dinner_bell", self);
        AI.Signal(Object.Named("Baltasar"), "WakeUp");
    }
}
