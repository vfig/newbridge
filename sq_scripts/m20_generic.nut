class ItemToDeliver extends SqRootScript
{
    /* Put this on an object with a ScriptParams("DeliveryRoom") link to one
       or more rooms where it should be delivered to. It will broadcast
       ItemDelivered/ItemNotDelivered messages to all ScriptParams("NotifyDelivery")
       objects when things change. */

    //-- Messages

    function OnBeginScript()
    {
        if (! IsDataSet("ItemIsDelivered")) {
            SetData("ItemIsDelivered", 0);
        }
        if (! IsDataSet("ItemInDeliveryRoom")) {
            SetData("ItemInDeliveryRoom", 0);
        }
        CheckForDelivery();
    }

    function OnContained()
    {
        CheckForDelivery();
    }

    function OnObjRoomTransit()
    {
        local room = message().ToObjId;
        SetData("ItemInDeliveryRoom", (IsDeliveryRoom(room) ? 1 : 0));
        CheckForDelivery();
    }

    //-- Functions

    function IsDeliveryRoom(room)
    {
        local links = Link.GetAll(linkkind("ScriptParams"), self);
        local is_goal = false;
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local target = LinkDest(link);
            if (data == "DeliveryRoom" && Object.InheritsFrom(room, target)) {
                is_goal = true;
            }
        }
        return is_goal;
    }

    function IsInContainer()
    {
        return Link.AnyExist("~Contains", self);
    }

    function IsInDeliveryRoom()
    {
        return GetData("ItemInDeliveryRoom");
    }

    function CheckForDelivery()
    {
        local already_delivered = (GetData("ItemIsDelivered") == 1);
        local is_delivered = (IsInDeliveryRoom() && ! IsInContainer());
        if (is_delivered != already_delivered) {
            SetData("ItemIsDelivered", (is_delivered ? 1 : 0));
            NotifyDelivery(is_delivered);
        }
    }

    function NotifyDelivery(is_delivered)
    {
        local links = Link.GetAll(linkkind("ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local target = LinkDest(link);
            if (data == "NotifyDelivery") {
                SendMessage(target, (is_delivered ? "ItemDelivered" : "ItemNotDelivered"), self);
            }
        }
    }
}
