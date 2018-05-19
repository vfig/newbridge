Object_Description <- function(obj)
{
    return (Object.GetName(obj) + " (" + obj + ")");
}

/* Get the ScriptParams link with the given data */
Link_GetScriptParams <- function(data = "", from = 0, to = 0)
{
    local links = Link.GetAll("ScriptParams", from, to);
    foreach (link in links) {
        local link_data = LinkTools.LinkGetData(link, "");
        if (link_data == data) {
            return link;
        }
    }
    return 0;
}

/* Get the ~ScriptParams link with the given data */
Link_GetInverseScriptParams <- function(data = "", from = 0, to = 0)
{
    local links = Link.GetAll("~ScriptParams", from, to);
    foreach (link in links) {
        local link_data = LinkTools.LinkGetData(link, "");
        if (link_data == data) {
            return link;
        }
    }
    return 0;
}

/* Get the dest of the ScriptParams link with the given data */
Link_GetScriptParamsDest <- function(data = "", from = 0)
{
    return LinkDest(Link_GetScriptParams(data, from));
}

/* Get the dest of the ScriptParams link with the given data */
Link_GetInverseScriptParamsDest <- function(data = "", from = 0)
{
    return LinkDest(Link_GetInverseScriptParams(data, from));
}

/* Get the destinations of all ScriptParams links with the given data */
Link_GetAllScriptParamsDests <- function(data = "", from = 0)
{
    local dests = [];
    local links = Link.GetAll("ScriptParams", from);
    foreach (link in links) {
        local link_data = LinkTools.LinkGetData(link, "");
        if (link_data == data) {
            dests.append(LinkDest(link));
        }
    }
    return dests;
}

/* Create a new ScriptParams link with the given data */
Link_CreateScriptParams <- function(data = "", from = 0, to = 0)
{
    local link = Link.Create("ScriptParams", from, to);
    LinkTools.LinkSetData(link, "", data);
    return link;
}

/* Get the AIConversationActor link with the given id */
Link_GetConversationActor <- function(actor_id, conversation)
{
    local links = Link.GetAll("AIConversationActor", conversation);
    foreach (link in links) {
        local link_data = LinkTools.LinkGetData(link, "Actor ID");
        if (link_data == actor_id) {
            return link;
        }
    }
    return 0;
}

Link_DestroyAll <- function(kind, from = 0, to = 0)
{
    local links = Link.GetAll(kind, from, to);
    foreach (link in links) {
        Link.Destroy(link);
    }
}

Link_GetCurrentPatrol <- function(ai)
{
    // AICurrentPatrol is a singleton link
    local link = Link.GetOne("AICurrentPatrol", ai);
    if (link != 0) {
        return LinkDest(link);
    } else {
        return 0;
    }
}

Link_SetCurrentPatrol <- function(ai, trol)
{
    // AICurrentPatrol is a singleton link, so make sure to delete any existing ones.
    Link_DestroyAll("AICurrentPatrol", ai);
    if (trol != 0) {
        Link.Create("AICurrentPatrol", ai, trol);
    }
}

Link_CollectPatrolPath <- function(trols)
{
    local seen = {};
    local queue = [];
    local all = [];
    foreach (trol in trols) {
        queue.append(trol);
    }
    while (queue.len() > 0) {
        local trol = queue.pop();
        all.append(trol);
        seen[trol] <- true;
        local links = Link.GetAll("AIPatrol", trol);
        local count = 0;
        foreach (link in links) {
            local dest = LinkDest(link);
            if (! seen.rawin(dest)) {
                queue.append(dest);
            }
            count += 1;
        }
    }
    return all;
}


enum eContainType
{
   kContainTypeAlt = -3,
   kContainTypeHand = -2, 
   kContainTypeBelt = -1,
   kContainTypeGeneric = 0,
}

Link_SetContainType <- function(link, type)
{
    LinkTools.LinkSetData(link, "", type);
}

enum eFrobWhere
{
    kFrobWorld = 0,
    kFrobInv = 1,
    kFrobTool = 2,
}

enum eFrobAction
{
    kFrobActionMove = 1,
    kFrobActionScript = 2,
    kFrobActionDelete = 4,
    kFrobActionIgnore = 8,
    kFrobActionFocusScript = 16,
    kFrobActionToolCursor = 32,
    kFrobActionUseAmmo = 64,
    kFrobActionDefault = 128,
    kFrobActionDeselect = 256,
}

Object_FrobField <- function(where)
{
    if (where == eFrobWhere.kFrobTool) {
        return "Tool Action";
    } else if (where == eFrobWhere.kFrobInv) {
        return "Inv Action";
    } else {
        return "World Action";
    }
}

Object_GetFrobAction <- function(obj, where = eFrobWhere.kFrobWorld)
{
    return Property.Get(obj, "FrobInfo", Object_FrobField(where));
}

Object_SetFrobAction <- function(obj, action, where = eFrobWhere.kFrobWorld)
{
    Property.Set(obj, "FrobInfo", Object_FrobField(where), action);
}

Object_AddFrobAction <- function(obj, action, where = eFrobWhere.kFrobWorld)
{
    local frob = Object_GetFrobAction(obj, where);
    frob = frob | action;
    Object_SetFrobAction(obj, frob, where);
}

Object_RemoveFrobAction <- function(obj, action, where = eFrobWhere.kFrobWorld)
{
    local frob = Object_GetFrobAction(obj, where);
    frob = frob & ~action;
    Object_SetFrobAction(obj, frob, where);
}

class WhenPlayerCarrying extends SqRootScript
{
    /* Sends "PlayerPickedUp" and "PlayerDropped" when the player picks up
       or drops this item. */

    function OnContained()
    {
        if (message().container == Object.Named("Player")) {
            if (message().event == eContainsEvent.kContainAdd) {
                SendMessage(self, "PlayerPickedUp");
            } else if (message().event == eContainsEvent.kContainRemove) {
                SendMessage(self, "PlayerDropped");
            }
        }
    }
}


class WatchForItems extends SqRootScript
{
    /* Put this on a concrete room, with ScriptParams("WatchThis") links to
       each of the items to watch for. It will send "ItemsArrived(true)" when
       all the items are in the room. */

    item_state = {};

    function IsWatching(obj) {
        local link = Link.GetOne("ScriptParams", self, obj);
        return ((link != 0) && (LinkTools.LinkGetData(link, "") == "WatchThis"));
    }

    function OnObjectRoomEnter()
    {
        local item = message().MoveObjId;
        if (IsWatching(item)) {
            item_state[item] <- true;
            CheckForAllItems();
        }
    }

    function OnObjectRoomExit()
    {
        local item = message().MoveObjId;
        if (IsWatching(item)) {
            item_state[item] <- false;
            CheckForAllItems();
        }
    }

    function OnCreatureRoomEnter()
    {
        OnObjectRoomEnter();
    }

    function OnCreatureRoomExit()
    {
        OnObjectRoomExit();
    }
    
    function CheckForAllItems()
    {
        local all_items = true;
        local links = Link.GetAll("ScriptParams", self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local target = LinkDest(link);
            if (data == "WatchThis") {
                local item_present = ((target in item_state) && item_state[target]);
                if (! item_present) {
                    all_items = false;
                    break;
                }
            }
        }

        SendMessage(self, "ItemsArrived", all_items);
    }
}


class ItemToDeliver extends SqRootScript
{
    /* Put this on an object with a ScriptParams("DeliveryRoom") link to one
       or more rooms where it should be delivered to. It will broadcast
       ItemDelivered/ItemNotDelivered messages to the room, and to all
       ScriptParams("NotifyDelivery") objects when things change. */

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
            if (data == "DeliveryRoom" || data == "NotifyDelivery") {
                SendMessage(target, (is_delivered ? "ItemDelivered" : "ItemNotDelivered"), self);
            }
        }
    }
}


class MultipleDeliveries extends SqRootScript
{
    /* Sends "AllItemsDelivered" when all items linked
       to this with ScriptParams("DeliveryRoom" or "NotifyDelivery")
       have been delivered, and "AllItemsNotDelivered" when not. */

    function OnBeginScript()
    {
        local links = Link.GetAll(linkkind("~ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local item = LinkDest(link);
            if (data == "DeliveryRoom" || data == "NotifyDelivery") {
                if (! IsDataSet("ItemDelivered_" + item)) {
                    SetData("ItemDelivered_" + item, 0);
                }
            }
        }
    }

    function OnItemDelivered()
    {
        local item = message().data;
        SetData("ItemDelivered_" + item, 1);
        CheckForAllDeliveries();
    }

    function OnItemNotDelivered()
    {
        local item = message().data;
        SetData("ItemDelivered_" + item, 0);
        CheckForAllDeliveries();
    }

    function CheckForAllDeliveries()
    {
        local all_delivered = true;
        local links = Link.GetAll(linkkind("~ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local item = LinkDest(link);
            if (data == "DeliveryRoom" || data == "NotifyDelivery") {
                local delivered = (GetData("ItemDelivered_" + item) == 1);
                all_delivered = all_delivered && delivered;
            }
        }

        if (all_delivered) {
            SendMessage(self, "AllItemsDelivered");
        } else {
            SendMessage(self, "AllItemsNotDelivered");
        }
    }
}


class PreserveMe extends SqRootScript
{
    /* Sends "NotPreserved" to self when KOd or killed, or if harmed
       by the player. */

    function IsPlayerResponsible(damage_message)
    {
        local player = Object.Named("Player");
        local culprit = damage_message.culprit;
        for (;;) {
            if (culprit == 0) return false;
            if (culprit == player) return true;

            // Follow the culpability links to see if we find a player.
            local link = Link.GetOne(linkkind("~CulpableFor"), culprit);
            if (link == 0) {
                culprit = 0;
            } else {
                culprit = LinkDest(link);
            }
        }
    }

    function OnDamage()
    {
        if (IsPlayerResponsible(message())) {
            SendMessage(self, "NotPreserved");
        }
    }

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            SendMessage(self, "NotPreserved");
        }
    }
}


class GarrettConversationActor extends SqRootScript
{
    // Put this on an conversation actor, with steps in the conversation
    // that send PlayVO("schema") messages to the actor, followed by
    // Wait with a suitable time.

    function OnPlayVO()
    {
        local schema = message().data;
        Sound.PlayVoiceOver(self, schema);
    }
}


class DoorStartsOpen extends SqRootScript
{
    // Put this on a door to have it open when the mission starts.

    function OnSim()
    {
        if (message().starting) {
            SendMessage(self, "Open");
        }
    }
}


/* Put this script on a conversation, and then you can send "TurnOff" to it to
   stop it dead. Make sure to give Actor 6 one step somewhere--"Nothing()" is
   fine for the action--or it will be ignored and its death will be in vain. */
class ConversationKiller extends SqRootScript
{
    function OnTurnOff()
    {
        // Kill the AIConversationActor links to force the conversation to stop.
        local links = Link.GetAll("AIConversationActor", self);
        foreach (link in links) {
            local actor = LinkDest(link);
            AI.SetScriptFlags(actor, 1); // 1 == kSpeechOff
            Link.Destroy(link);
        }
    }
}
