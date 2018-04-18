/* MausPuzzle: Mausoleum puzzle, that requires the player to frob several levers in the correct order.

    1. Create a TrigTrap and attach the MausPuzzle script.
    2. Add a ScriptParams link from MausPuzzle to itself, and set the data to the magic word.
    3. Create levers, and a ControlDevice link from each to the MausPuzzle.
    4. Add a ScriptParams link from each lever to the MausPuzzle, and set the data to the letter associated with that lever.
    5. Add a ControlDevice link from the MausPuzzle to whatever should be sent TurnOn when the player is successful.

*/

class MausPuzzle extends SqRootScript
{
    solution = "";

    function OnBeginScript()
    {
        local link = Link.GetOne(linkkind("ScriptParams"), self);
        local data = LinkTools.LinkGetData(link, "");
        solution = data.tostring();
    }

    function OnTurnOn()
    {
        local lever = message().from;
        local link = Link.GetOne(linkkind("ScriptParams"), lever, self);
        local data = LinkTools.LinkGetData(link, "").tostring();
        EnableFrob(lever, false);
        AdvancePuzzle(data);
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

    function AdvancePuzzle(value)
    {
        local progress = GetProgress();

        if (progress.len() < solution.len()) {
            // Advance the progress
            progress += value;
            SetProgress(progress);

            // Check for success or failure
            if (progress.len() == solution.len()) {
                if (progress == solution) {
                    CompletePuzzle();
                } else {
                    ResetPuzzle();
                }
            }
        }
    }

    function CompletePuzzle()
    {
        // Disable all linked levers
        local links = Link.GetAll(linkkind("~ControlDevice"), self);
        foreach (link in links) {
            local lever = LinkDest(link);
            EnableFrob(lever, false);
        }

        // Turn on all ControlDevice links
        local links = Link.GetAll(linkkind("ControlDevice"), self);
        foreach (link in links) {
            local target = LinkDest(link);
            SendMessage(target, "TurnOn");
        }
    }

    function ResetPuzzle()
    {
        SetProgress("");

        // Turn off all linked levers
        local links = Link.GetAll(linkkind("~ControlDevice"), self);
        foreach (link in links) {
            local lever = LinkDest(link);
            EnableFrob(lever, true);
            SendMessage(lever, "TurnOff");
        }

        PunishPlayer();
    }

    function EnableFrob(lever, enable)
    {
        const ScriptFlag = 2;
        const IgnoreFlag = 8;
        if (enable) {
            Property.Set(lever, "FrobInfo", "World Action", ScriptFlag);
        } else {
            Property.Set(lever, "FrobInfo", "World Action", IgnoreFlag);
        }
    }

    function PunishPlayer()
    {
        // So: this works, but Garrett doesn't make a sound? What gives?
        local player = ObjID("Player");
        Damage.Damage(player, self, 2.0, ObjID("MagicZapStim"));


        //Damage.Damage(player, 0, 5.0, ObjID("MagicZapStim"));
        //ActReact.BeginContact(self, player);
        //ActReact.Stimulate(player, "MagicZapStim", 2.0);
        //ActReact.EndContact(self, player);
        //local link = Link.GetOne(linkkind("Weapon"), self);
        //local weapon = LinkDest(link);
        //Damage.Damage(player, weapon, 2.0);

        // This doesn't work cause the thing doesn't collied with the player
        //local player = ObjID("Player");
        //local playerLocation = Property.Get(player, "Position", "Location")
        //local missile = Object.BeginCreate(ObjID("MagicMissile"));
        //Property.Set(missile, "Position", "Location", playerLocation);
        //Object.EndCreate(missile);
   }
}