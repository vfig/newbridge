/* MausDouse: Douse a torch when entering a room.

    1. Create a concrete room and attach the MausDouse script.

    2. Add a ControlDevice link, room -> torch
*/

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

class MausDouse extends SqRootScript
{
    // -- Messages

    function OnPlayerRoomEnter()
    {
        // Turn off all targets
        local links = Link.GetAll(linkkind("ControlDevice"), self);
        foreach (link in links) {
            local target = LinkDest(link);
            SendMessage(target, "TurnOff");
        }
        // And never fire again
        Object.Destroy(self);
    }
}

class MausGateControl extends SqRootScript
{
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