Object_Description <- function(obj)
{
    local name;
    if (obj == 0) {
        name = "[nothing]";
    } else {
        name = Object.GetName(obj);
        if (name == "") {
            // Look up the archetype's name instead.
            local archetype_name = Object.GetName(Object.Archetype(obj));
            if (archetype_name == "") {
                name = "[unknown]";
            } else {
                local first = archetype_name.slice(0, 1).toupper();
                if (first == "A" || first == "E" || first == "I" || first == "O" || first == "U") {
                    name = "an " + archetype_name;
                } else {
                    name = "a " + archetype_name;
                }
            }
        }
    }
    return (name + " (" + obj + ")");
}

/* Get the ScriptParams link with the given data */
Link_GetOneScriptParams <- function(data = "", from = 0, to = 0)
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

/* Get all ScriptParams links with the given data */
Link_GetAllScriptParams <- function(data = "", from = 0, to = 0)
{
    local links = Link.GetAll("ScriptParams", from, to);
    local matching_links = [];
    foreach (link in links) {
        local link_data = LinkTools.LinkGetData(link, "");
        if (link_data == data) {
            matching_links.append(link);
        }
    }
    return matching_links;
}

/* Get the ~ScriptParams link with the given data */
Link_GetOneInverseScriptParams <- function(data = "", from = 0, to = 0)
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
Link_GetOneParam <- function(data = "", from = 0)
{
    return LinkDest(Link_GetOneScriptParams(data, from));
}

/* Get the destinations of all ScriptParams links with the given data */
Link_GetAllParams <- function(data = "", from = 0)
{
    local links = Link_GetAllScriptParams(data, from);
    return links.map(LinkDest);
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

Link_BroadcastOnAllLinks <- function(message, kind, from, data = 0, data2 = 0)
{
    local links = Link.GetAll(kind, from);
    foreach (link in links) {
        SendMessage(LinkDest(link), message, data, data2);
    }
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

Link_SetContainType <- function(link, type)
{
    // Type should be an eDarkContainType value.
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

Object_SetFrobInert <- function(obj, inert)
{
    local metaprop = Object.Named("FrobInert");
    local has_metaprop = Object.HasMetaProperty(obj, metaprop);
    if (inert && (! has_metaprop)) {
        Object.AddMetaProperty(obj, metaprop);
    } else if ((! inert) && has_metaprop) {
        Object.RemoveMetaProperty(obj, metaprop);
    }
}

AI_AlertLevel <- function(ai)
{
    return Property.Get(self, "AI_Alertness", "Level");
}

AI_HostileTeam <- function(team1, team2)
{
    return ((team1 != eAITeam.kAIT_Neutral)
        && (team2 != eAITeam.kAIT_Neutral)
        && (team1 != team2));
}

AI_Mode <- function(ai)
{
    return Property.Get(ai, "AI_Mode", "");
}

AI_SetIdleOrigin <- function(ai, target)
{
    local pos = Object.Position(target);
    local facing = floor(Object.Facing(target).z + 0.5).tointeger();
    Property.Set(ai, "AI_IdleOrgn", "Original Location", pos);
    Property.Set(ai, "AI_IdleOrgn", "Original Facing", facing);
}

AI_Team <- function(ai)
{
    return Property.Get(ai, "AI_Team", "");
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
       each of the items to watch for; each item must also have the ItemToWatch
       script on it, if you want the script to trigger when the player is already
       in the room and picks the item up.

       This will send "ItemsArrived(true)" to itself when the player is in the room
       and is carrying all the items.
    */

    function GetPlayerInRoom()
    {
        if (IsDataSet("WFIPlayerInRoom")) {
            return GetData("WFIPlayerInRoom");
        } else {
            return false;
        }
    }

    function SetPlayerInRoom(in_room)
    {
        SetData("WFIPlayerInRoom", in_room);
    }

    function OnPlayerRoomEnter()
    {
        SetPlayerInRoom(true);
        CheckForAllItems();
    }

    function OnPlayerRoomExit()
    {
        SetPlayerInRoom(false);
    }

    function OnWatchedItemContained()
    {
        CheckForAllItems();
    }

    function CheckForAllItems()
    {
        if (GetPlayerInRoom()) {
            local player = Object.Named("Player");
            local all_items = true;
            local links = Link.GetAll("ScriptParams", self);
            foreach (link in links) {
                local data = LinkTools.LinkGetData(link, "");
                local target = LinkDest(link);
                if (data == "WatchThis") {
                    local item_present = (Container.IsHeld(player, target) != 0x7FFFFFFF);
                    if (! item_present) {
                        all_items = false;
                        break;
                    }
                }
            }
            SendMessage(self, "ItemsArrived", all_items);
        }
    }
}


class ItemToWatch extends SqRootScript
{
    function OnContained()
    {
        local watcher = GetWatcher();
        if (watcher != null) {
            SendMessage(watcher, "WatchedItemContained", self);
        }
    }

    function GetWatcher() {
        local links = Link.GetAll("~ScriptParams", self);
        local watcher = null;
        foreach (link in links) {
            if (LinkTools.LinkGetData(link, "") == "WatchThis") {
                watcher = LinkDest(link);
                break;
            }
        }
        return watcher;
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
        // When trying to drop an item, if there's no space, it will get uncontained
        // and immediately contained again. So we delay the actual delivery check until
        // after that's had a chance to happen. This way a failed drop won't count as
        // a delivery.
        PostMessage(self, "_DelayedCheckForDelivery");
    }

    function On_DelayedCheckForDelivery()
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


class StartsOn extends SqRootScript
{
    // Put this on a n object to send it TurnOn when the mission starts.

    function OnSim()
    {
        if (message().starting) {
            SendMessage(self, "TurnOn");
        }
    }
}


class StartsOff extends SqRootScript
{
    // Put this on a n object to send it TurnOff when the mission starts.

    function OnSim()
    {
        if (message().starting) {
            SendMessage(self, "TurnOff");
        }
    }
}


/* Normally particles won't render on an object that's contained--even if the
   object ends up rendered after all, on an Alt or Belt location. For this hack,
   create a clone of the particles, and ParticleAttachement it to a rendered,
   fully transparent marker, that is then DetailAttachement linked to the AI
   with the belt. This script then destroys those two hack objects when this
   thing is pickpocketed. */
class HackBeltParticles extends WhenPlayerCarrying
{
    function OnPlayerPickedUp()
    {
        local detail_link = Link.GetOne("~DetailAttachement", self);
        if (detail_link != 0) {
            local hack_marker = LinkDest(detail_link);
            local particle_link = Link.GetOne("~ParticleAttachement", hack_marker);
            if (particle_link != 0) {
                // We've identified the hack, kill them all!
                local particles = LinkDest(particle_link);
                Object.Destroy(particles);
                Object.Destroy(hack_marker);
            }
        }
    }
}

/* Sends itself TurnOff a few seconds after receiving TurnOn */
class AutoTurnOff extends SqRootScript
{
    timer = 0;

    function OnTurnOn()
    {
        // If we get multiple TurnOns before the timer fires, kill the old timer.
        if (timer != 0) {
            KillTimer(timer);
            timer = 0;
        }

        timer = SetOneShotTimer("AutoTurnOff", 6.0);
    }

    function OnTimer()
    {
        if (message().name == "AutoTurnOff") {
            SendMessage(self, "TurnOff");
            timer = 0;
        }
    }
}

/* Adds and removes "(Unconscious)" / "(Corpse)" to an AI's 'Object Name' property
   when their status changes.  If the AI's name refers to an OBJNAMES.STR entry,
   that will be read when the game starts.  To localise the status labels, add
   the 'Name_UncStatus' and 'Name_CorpseStatus' strings to OBJNAMES.STR. */
class AIStatusSuffix extends SqRootScript
{
    function UpdateSuffix()
    {
        // What is my original given name?
        local name = GetData("AIStatusName");
        if (name == "" || name == null) {
            name = Data.GetObjString(self, "objnames");
            SetData("AIStatusName", name);
        }

        // Am I dead or unconscious?
        local suffix = "";
        local mode = Property.Get(self, "AI_Mode");
        if (mode == eAIMode.kAIM_Dead) {
            local hp = Property.Get(self, "HitPoints");
            if (hp <= 0) {
                local text = Data.GetString("objnames.str", "Name_CorpseStatus");
                if (text == "") { text = "(Corpse)"; }
                suffix = " " + text;
            } else {
                local text = Data.GetString("objnames.str", "Name_UncStatus");
                if (text == "") { text = "(Unconscious)"; }
                suffix = " " + text;
            }
        }

        // Update my name property
        local prop = ("@hack: \"" + name + suffix + "\"");
        Property.SetSimple(self, "GameName", prop);
    }

    function OnSim()
    {
        if (message().starting) {
            UpdateSuffix();
        }
    }

    function OnAIModeChange()
    {
        UpdateSuffix();
    }

    function OnSlain()
    {
        UpdateSuffix();
    }
}

class LockboxFrobSound extends SqRootScript
{
    function OnFrobWorldEnd()
    {
        if (Locked.IsLocked(self)) {
            Sound.PlaySchemaAtObject(self, "locked", self);
        }
    }
}

class GoldDoorHack extends SqRootScript
{
    /* Thief 1/Gold: put this script on the Door archetype.
       It must come first in the list of scripts, before
       StdDoor! It will fix two door problems:

       1. If a door gets stuck while opening, frobbing it again
          will make it close. This replicates Thief 2 behaviour
          in this circumstance, where Thief 1/Gold would always
          keep trying to open the door. This improves usability
          and also prevents players getting stuck behind an
          opening door.

       2. If a door is part of a Double set, then they will now
          synchronise their locked state. Unlocking one door
          will unlock the other, and locking one door again will
          lock the other also. This improves usability where one
          door of a doubled pair could be locked while the other
          was unlocked. This replicates Thief 2 behaviour in this
          circumstance.
     */
    function OnDoorOpen() {
        // Evidently we're no longer blocked from opening.
        ClearData("BlockedFromOpening");
    }

    function OnDoorClose() {
        // Evidently we're no longer blocked from opening.
        ClearData("BlockedFromOpening");
    }

    function OnDoorHalt() {
        if (message().PrevActionType == eDoorAction.kOpening) {
            // If the door was blocked while opening, then remember
            // this, so the next time it's frobbed it'll close instead.
            SetData("BlockedFromOpening", true);
        } else {
            // Evidently we're no longer blocked from opening.
            ClearData("BlockedFromOpening");
        }
    }

    function OnFrobWorldEnd() {
        if (IsDataSet("BlockedFromOpening")) {
            ClearData("BlockedFromOpening");
            // Don't pass this message on to StdDoor, or it'll keep
            // trying to open the door!
            BlockMessage();
            // We want to close the door this time instead.
            Door.CloseDoor(self);
        }
    }

    function OnSynchUp() {
        // This is just copied from T2's GIZMO.SCR
        local other_door = message().from;
        if(Property.Possessed(other_door, "Locked")
            && Property.Possessed(self, "Locked"))
        {
            local other_locked = Property.Get(other_door, "Locked");
            local locked = Property.Get(self, "Locked");
            if (locked != other_locked) {
                Property.CopyFrom(self, "Locked", other_door);
            }
        }
    }
}

class TrapFlipFlop extends SqRootScript
{
    /* When receiving TurnOn messages, passes on TurnOn, TurnOff, ...
       alternating. Ignores TurnOff. */
    function OnBeginScript() {
        if (! IsDataSet("LastSentOn")) {
            SetData("LastSentOn", false);
        }
    }

    function OnTurnOn() {
        local last_sent_on = GetData("LastSentOn");
        local sending_on = (! last_sent_on);
        SetData("LastSentOn", sending_on);
        local message = (sending_on ? "TurnOn" : "TurnOff");
        Link.BroadcastOnAllLinks(self, message, "ControlDevice");
    }
}
