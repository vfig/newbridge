/* MausDouse: Douse a torch when entering a room.

    1. Create a concrete room and attach the MausDouse script.

    2. Add a ControlDevice link, room -> torch
*/

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