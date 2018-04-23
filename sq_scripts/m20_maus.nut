function EnableFrob(obj, enable)
{
    const ScriptFlag = 2;
    const IgnoreFlag = 8;
    if (enable) {
        Property.Set(obj, "FrobInfo", "World Action", ScriptFlag);
    } else {
        Property.Set(obj, "FrobInfo", "World Action", IgnoreFlag);
    }
}

enum eTweqAnimS {
  kActive = 0x1
  kReverse = 0x2
}

class MausLever extends SqRootScript
{
    // -- Messages

    function OnFrobWorldEnd()
    {
        // Animate the rotate tweq to the opposite state
        local AnimS = Property.Get(self, "StTweqRotate", "AnimS");
        local isActive = ((AnimS & eTweqAnimS.kActive) != 0);
        local isReverse = ((AnimS & eTweqAnimS.kReverse) != 0);
        local shouldReverse = (isActive ? !isReverse : isReverse);
        local newAnimS = eTweqAnimS.kActive | (shouldReverse ? eTweqAnimS.kReverse : 0);
        Property.Set(self, "StTweqRotate", "AnimS", newAnimS);
    }

    function OnTweqComplete()
    {
        if (message().Type == eTweqType.kTweqTypeRotate) {
            local isReverse = (message().Dir == eTweqDirection.kTweqDirReverse);
            local newMessage = (isReverse ? "TurnOff" : "TurnOn");
            Link.BroadcastOnAllLinks(self, newMessage, "ControlDevice");
        }
        // print("OnTweqComplete:");
        // print("  Type: " + message().Type);
        // print("  Op: " + message().Op);
        // print("  Dir: " + message().Dir);
        // local AnimS = Property.Get(self, "StTweqRotate", "AnimS");
        // print("  & AnimS: " + AnimS);
    }
}

class MausGateControl extends SqRootScript
{
    /* MausGateControl: TurnOn doors and disable frobbing them when
       receiving a TurnOn message for the first time.

        1. Attach the MausGateControl script to a switch or something.

        2. Add ControlDevice links to each door.
    */

    // -- Messages

    function OnTurnOn()
    {
        // Open all gates, and disable frobbing them
        local links = Link.GetAll(linkkind("ControlDevice"), self);
        foreach (link in links) {
            local target = LinkDest(link);
            SendMessage(target, "TurnOn");
            EnableFrob(target, false);
        }
        // And never fire again
        Object.Destroy(self);
    }
}


class MausPuzzle extends SqRootScript
{
    /* MausPuzzle: Mausoleum puzzle, that requires the player to frob several levers in the correct order.

        1. Create a TrigTrap and attach the MausPuzzle script.

        2. Add a ScriptParams link, puzzle -> puzzle, data: the magic word.

        3. Create on lever for each letter in the magic word.

        4. With each lever:
            a) Add a ControlDevice link, lever -> puzzle.
            b) Add a ScriptParams link, lever -> puzzle, data: the letter for this lever.

        5. Add a ScriptParams link, puzzle -> whatever, data: "Success"; whatever will be sent TurnOn when the player succeeds.
        
        6. Add a ScriptParams link, puzzle -> whatever, data: "Failure"; whatever will be sent TurnOn when the player fails.

    */

    // -- Messages

    function OnTurnOn()
    {
        local lever = message().from;
        local link = Link.GetOne(linkkind("ScriptParams"), lever, self);
        local data = LinkTools.LinkGetData(link, "").tostring();
        AdvancePuzzle(data);
    }

    function OnTurnOff()
    {
        ResetPuzzle(false);
    }

    // -- Puzzle logic

    function AdvancePuzzle(value)
    {
        local progress = GetProgress();
        local solution = GetSolution();

        if (progress.len() < solution.len()) {
            // Advance the progress
            progress += value;
            SetProgress(progress);

            // Check for success or failure
            if (progress.len() == solution.len()) {
                if (progress == solution) {
                    CompletePuzzle();
                } else {
                    ResetPuzzle(true);
                }
            }
        }
    }

    function CompletePuzzle()
    {
        TurnOffLevers();
        DisableLevers();
        TurnOnTargets("Success");
        Object.Destroy(self);
    }

    function ResetPuzzle(punish)
    {
        SetProgress("");
        TurnOffLevers();
        if (punish) {
            TurnOnTargets("Failure");
        }
    }

    // -- Interaction with other objects

    function TurnOffLevers()
    {
        local links = Link.GetAll(linkkind("~ControlDevice"), self);
        foreach (link in links) {
            local lever = LinkDest(link);
            SendMessage(lever, "TurnOff");
        }
    }

    function DisableLevers()
    {
        local links = Link.GetAll(linkkind("~ControlDevice"), self);
        foreach (link in links) {
            local lever = LinkDest(link);
            EnableFrob(lever, false);
        }
    }

    function TurnOnTargets(matching_data)
    {
        local links = Link.GetAll(linkkind("ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            if (data == matching_data) {
                local target = LinkDest(link);
                SendMessage(target, "TurnOn");
            }
        }
    }

    // -- Data management

    function GetSolution()
    {
        local link = Link.GetOne(linkkind("ScriptParams"), self, self);
        local data = LinkTools.LinkGetData(link, "");
        if (data == null) {
            data = "";
        }
        return data.tostring();
    }

    function GetProgress()
    {
        local progress = GetData("MausPuzzleProgress_" + self);
        if (progress == null) {
            progress = "";
        }
        return progress;
    }

    function SetProgress(progress)
    {
        SetData("MausPuzzleProgress_" + self, progress);
    }
}