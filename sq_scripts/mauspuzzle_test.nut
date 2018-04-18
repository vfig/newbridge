class MausPuzzle extends SqRootScript
{
    solution = "";

    function OnBeginScript()
    {
        local link = Link.GetOne(linkkind("ScriptParams"), self);
        local data = LinkTools.LinkGetData(link, "");
        solution = data.tostring();
        print("Solution is '" + solution + "'");
    }

    function AdvancePuzzle(value)
    {
        local progress = GetData("MausPuzzleProgress");
        if (progress == null) {
            progress = "";
        }

        if (progress.len() < solution.len()) {
            // Advance the progress
            progress += value;
            SetData("MausPuzzleProgress", progress);
            print ("Progress is: '" + progress + "'");

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
            print("  disabling " + Object.GetName(lever) + " (" + lever + ")");
            EnableFrob(lever, false);
        }

        // Turn on all ControlDevice links
        local links = Link.GetAll(linkkind("ControlDevice"), self);
        foreach (link in links) {
            local target = LinkDest(link);
            print("  turning on " + Object.GetName(target) + " (" + target + ")");
            SendMessage(target, "TurnOn");
        }
    }

    function ResetPuzzle()
    {
        SetData("MausPuzzleProgress", null);
        //print ("Progress is: '\"\"'");

        // Turn off all linked levers
        local links = Link.GetAll(linkkind("~ControlDevice"), self);
        foreach (link in links) {
            local lever = LinkDest(link);
            EnableFrob(lever, true);
            SendMessage(lever, "TurnOff");
        }
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

    function OnTurnOn()
    {
        // local msg = message();

        // print(
        //     Object.GetName(msg.from)
        //     + " (" + msg.from + ") -> "
        //     + Object.GetName(msg.to)
        //     + " (" + msg.to + "): "
        //     + msg.message
        //     + " [" + msg.data + "]");

        local lever = message().from;
        local link = Link.GetOne(linkkind("ScriptParams"), lever, self);
        local data = LinkTools.LinkGetData(link, "").tostring();
        EnableFrob(lever, false);
        AdvancePuzzle(data);
    }

    function OnTurnOff()
    {
        local msg = message();

        print(
            Object.GetName(msg.from)
            + " (" + msg.from + ") -> "
            + Object.GetName(msg.to)
            + " (" + msg.to + "): "
            + msg.message
            + " [" + msg.data + "]");
   }
}