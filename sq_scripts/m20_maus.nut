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


/* SendMessageTrap: a trap that does a buncha stuff.

    When receiving a TurnOn message, it goes through all its ScriptParams
    links in order, and, according to each one's data:

        "TurnOn": sends the destination a "TurnOn" message.

        "TurnOff": sends the destination a "TurnOff" message.

        "Destroy": destroys the destination.
*/
class SendMessageTrap extends SqRootScript
{
    function OnTurnOn()
    {
        print("SendMessageTrap:");
        local links = Link.GetAll(linkkind("ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local target = LinkDest(link);
            print("  preview: " + data + " -> " + Object.GetName(target) + " (" + target + ")");
        }
        local links = Link.GetAll(linkkind("ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local target = LinkDest(link);
            print("  send: " + data + " -> " + Object.GetName(target) + " (" + target + ")");
            if (data == "TurnOn") {
                SendMessage(target, "TurnOn");
            } else if (data == "TurnOff") {
                SendMessage(target, "TurnOff");
            } else if (data == "Destroy") {
                Object.Destroy(target);
            }
        }
    }
}

/* RotateLever: a simple lever that rotates when frobbed.

    The lever will also respond to TurnOn/TurnOff messages, and will
    still send the appropriate message to its ControlDevice targets,
    but will not play a sound.

    Requires an object with:

        Tweq > Rotate:
            Halt: Stop Tweq
            AnimC: Sim
            MiscC: Scripts
            CurveC: [None]
            Primary Axis: 1/2/3 for x/y/z as appropriate.
            x/y/z rate-low-high: as desired

        Tweq > RotateState:
            AnimS: [None]; or Reverse if to start the lever in the On position.

        Schema:
            Appropriate class tags if you want lever sounds.
*/

enum eTweqAnimS {
  kActive = 0x1
  kReverse = 0x2
}

class RotateLever extends SqRootScript
{
    // -- Messages

    function OnBeginScript()
    {
        if (!Property.Possessed(self, "StTweqRotate")) {
            print("RotateLever object " + self + " needs StTweqRotate property!");
        }
    }

    function OnFrobWorldEnd()
    {
        // Animate the rotate tweq to the opposite state
        local AnimS = Property.Get(self, "StTweqRotate", "AnimS");
        local isActive = ((AnimS & eTweqAnimS.kActive) != 0);
        local isReverse = ((AnimS & eTweqAnimS.kReverse) != 0);
        local shouldReverse = (isActive ? !isReverse : isReverse);
        local newAnimS = eTweqAnimS.kActive | (shouldReverse ? eTweqAnimS.kReverse : 0);
        Property.Set(self, "StTweqRotate", "AnimS", newAnimS);
    
        // Play the appropriate sound
        local tags = "Event StateChange, DirectionState " + (shouldReverse ? "Reverse" : "Forward");
        Sound.HaltSchema(self, "", self);
        Sound.PlayEnvSchema(self, tags, self, 0, eEnvSoundLoc.kEnvSoundAtObjLoc);
    }

    function OnTweqComplete()
    {
        if (message().Type == eTweqType.kTweqTypeRotate) {
            // Send TurnOn/TurnOff messages to targets
            local isReverse = (message().Dir == eTweqDirection.kTweqDirReverse);
            local newMessage = (isReverse ? "TurnOff" : "TurnOn");
            Link.BroadcastOnAllLinks(self, newMessage, "ControlDevice");
        }
    }

    function OnTurnOn()
    {
        // Animate the rotate tweq to the on state
        Property.Set(self, "StTweqRotate", "AnimS", (eTweqAnimS.kActive));
    }

    function OnTurnOff()
    {
        // Animate the rotate tweq to the off state
        Property.Set(self, "StTweqRotate", "AnimS", (eTweqAnimS.kActive | eTweqAnimS.kReverse));
    }
}

class MausDoorBoard extends SqRootScript
{
    /* Sends RevertToDoor to the mausoleum front doors, and opens them. */
    function OnSlain()
    {
        Link.BroadcastOnAllLinks(self, "RevertToDoor", "ControlDevice");
        Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
    }
}

class MausFrontDoor extends SqRootScript
{
    /* Makes the mausoleum doors play a different "locked" sound unil ReverToDoor received. */
    function OnFrobWorldEnd()
    {
        Sound.PlaySchemaAtObject(self, "doormaus_locked", self);
        // Send a ControlDevice onward only if the player frobbed us (for VO etc. that we don't want AI triggering)
        if (Object.GetName(message().Frobber) == "Player") {
            Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
        }
    }

    function OnRevertToDoor()
    {
        // Remove the scripts that are overriding StdDoor etc.
        Property.Remove(self, "Scripts");
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
            } else {
                UpdatePuzzleSounds();
            }
        }
    }

    function CompletePuzzle()
    {
        TurnOffLevers();
        DisableLevers();
        UpdatePuzzleSounds();
        TurnOnTargets("Success");
        Object.Destroy(self);
    }

    function ResetPuzzle(punish)
    {
        SetProgress("");
        TurnOffLevers();
        UpdatePuzzleSounds();
        if (punish) {
            TurnOnTargets("Failure");
        }
    }

    function UpdatePuzzleSounds()
    {
        local progress = GetProgress();
        local solution = GetSolution();
        ActivateSounds(progress.len(), solution.len());
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

    function ActivateSounds(step, total)
    {
        local links = Link.GetAll(linkkind("ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            if (data.find("Sound") == 0) {
                local target = LinkDest(link);
                local message = ((data == "Sound" + step) ? "TurnOn" : "TurnOff");
                SendMessage(target, message);
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
        local progress = GetData("MausPuzzleProgress");
        if (progress == null) {
            progress = "";
        }
        return progress;
    }

    function SetProgress(progress)
    {
        SetData("MausPuzzleProgress", progress);
    }
}

class TheProphet extends SqRootScript
{
    function OnTurnOn()
    {
        // Wake the prophet up!
        Object.RemoveMetaProperty(self, "M-InactiveProphet");
    }
}