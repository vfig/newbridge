enum eGoals {
    /* Argaux and the job */
    kMeetArgaux             = 0,
    kFindArgauxsInfauxs     = 1,
    /* The Anax */
    kKidnapTheAnax          = 2,
    kBonusBurrickTrouble    = 3,
    /* The Hand */
    kStealTheHand           = 4,
    kBonusBanishTheGhost    = 5,
    /* Delivery */
    kDeliverTheItems        = 6,
    /* The Ritual */
    kStopTheRitual          = 7,
    kBonusSubvertTheRitual  = 8,
    kEscapeWithTheAnax      = 9,
    kReturnTheAnax          = 10, // Hard + Expert
    kBonusSellTheHand       = 11,
    /* Silly player */
    kKeepTheAnaxAlive       = 12,
    kDontBiteTheHand        = 13,
    /* Loot */
    kLootNormal             = 14,
    kLootHard               = 15,
    kLootExpert             = 16,
    kSpecialLootHard        = 17, // Hard + Expert special loot item (special 1)
    kSpecialLootExpert      = 18, // Expert special loot item (special 2)
    /* Thou shalt not murder */
    kDontKillBystanders     = 19,
    kDontKillHumans         = 20,
    /* Endgame */
    kReturnToTheStart       = 21
}

enum eMonologues {
    /* Argaux and the job */
    kWhereIsArgaux          = 1,
    kFoundArgauxsBody       = 6,
    kFoundArgauxsInfauxs    = 2,
    kFoundDiRuposInfos      = 4,
    /* The Anax */
    kEnteredTheSanctuary    = 5,
    kTheAnaxIsAPerson       = 3,
    /* The Ritual */
    kFoundTheRitual         = 7
}

Goal = {
    IsActive = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 0);
    }
    Activate = function(goal) {
        Quest.Set("goal_state_" + goal, 0);
    }
    IsComplete = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 1);
    }
    Complete = function(goal) {
        Quest.Set("goal_state_" + goal, 1);
    }
    IsCancelled = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 2);
    }
    Cancel = function(goal) {
        Quest.Set("goal_state_" + goal, 2);
    }
    IsFailed = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 3);
    }
    Fail = function(goal) {
        Quest.Set("goal_state_" + goal, 3);
    }
    IsVisible = function(goal) {
        return (Quest.Get("goal_visible_" + goal) == 1);
    }
    Hide = function(goal) {
        Quest.Set("goal_visible_" + goal, 0);
    }
    Show = function(goal) {
        Quest.Set("goal_visible_" + goal, 1);
    }

    SpeakMonologue(monologue) {
        if (Quest.Get("mlog_done_" + monologue) == 0) {
            // FIXME: play the voice line here
            print("FIXME: should play monologue " + monologue);
            CancelMonologue(monologue);
        }
    }
    CancelMonologue(monologue) {
        Quest.Set("mlog_done_" + monologue, 1);
    }
}


/* -------- Argaux and the job -------- */


class GoalArgauxsBody extends SqRootScript
{
    /* Put this on Argaux's body, and his key. */

    function OnFrobWorldBegin()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.SpeakMonologue(eMonologues.kFoundArgauxsBody);

        Goal.Cancel(eGoals.kMeetArgaux);
        Goal.Show(eGoals.kFindArgauxsInfauxs);
    }
}

class GoalTheFountain extends SqRootScript
{
    /* Put this on a concrete room at the fountain. */

    function OnPlayerRoomEnter()
    {
        Goal.SpeakMonologue(eMonologues.kWhereIsArgaux);
    }
}

class GoalSeizureNotice extends SqRootScript
{
    /* Put this on the notice on Argaux's door. */

    function OnFrobWorldEnd()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.SpeakMonologue(eMonologues.kFoundArgauxsBody);

        Goal.Cancel(eGoals.kMeetArgaux);
        Goal.Show(eGoals.kFindArgauxsInfauxs);
    }
}

class GoalArgauxsInfauxs extends SqRootScript
{
    /* Put this on the scroll with the job info in Argaux's bolt-hole. */

    function OnFrobInvEnd()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.CancelMonologue(eMonologues.kFoundArgauxsBody);
        Goal.SpeakMonologue(eMonologues.kFoundArgauxsInfauxs);
        Goal.CancelMonologue(eMonologues.kFoundDiRuposInfos);

        Goal.Cancel(eGoals.kMeetArgaux);
        if (Goal.IsActive(eGoals.kFindArgauxsInfauxs)) {
            // Don't complete it if it was already cancelled.
            Goal.Show(eGoals.kFindArgauxsInfauxs);
            Goal.Complete(eGoals.kFindArgauxsInfauxs);
        }
        Goal.Show(eGoals.kKidnapTheAnax);
        Goal.Show(eGoals.kStealTheHand);
        Goal.Show(eGoals.kDeliverTheItems);
    }
}

class GoalDiRuposInfos extends SqRootScript
{
    /* Put this on the di Rupo's diary with the job info. */

    function OnFrobWorldEnd()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.CancelMonologue(eMonologues.kFoundArgauxsBody);
        if (Goal.IsActive(eGoals.kMeetArgaux)) {
            // If the player doesn't know Argaux is dead, use the line where Garrett is cutting Argaux out of the job.
            Goal.CancelMonologue(eMonologues.kFoundArgauxsInfauxs);
            Goal.SpeakMonologue(eMonologues.kFoundDiRuposInfos);
        } else {
            // If the player already knows Argaux is dead, use the line where Garrett is taking on the job anyway.
            Goal.SpeakMonologue(eMonologues.kFoundArgauxsInfauxs);
            Goal.CancelMonologue(eMonologues.kFoundDiRuposInfos);
        }

        Goal.Cancel(eGoals.kMeetArgaux);
        if (Goal.IsActive(eGoals.kFindArgauxsInfauxs)) {
            // Don't cancel it if it was already completed.
            Goal.Cancel(eGoals.kFindArgauxsInfauxs);
        }
        Goal.Show(eGoals.kKidnapTheAnax);
        Goal.Show(eGoals.kStealTheHand);
        Goal.Show(eGoals.kDeliverTheItems);
    }
}


/* -------- The Anax -------- */


class GoalEnterTheSanctuary extends SqRootScript
{
    /* Put this on a concrete room at the sanctuary. */

    function OnPlayerRoomEnter()
    {
        Goal.SpeakMonologue(eMonologues.kEnteredTheSanctuary);
    }
}

class GoalReadingAboutTheAnax extends SqRootScript
{
    /* Put this on:
        - the Anax's diary,
        - the notice about where the Anax is sleeping,
        - the letter from the Priest to the Warden,
        - any other readables that reveal the Anax is a person.
    */

    function OnFrobWorldEnd()
    {
        Goal.SpeakMonologue(eMonologues.kTheAnaxIsAPerson);
    }
}

class GoalSeeingTheAnax extends SqRootScript
{
    /* Put this on a concrete room where the player can see the Anax. */

    function OnPlayerRoomEnter()
    {
        Goal.SpeakMonologue(eMonologues.kTheAnaxIsAPerson);
    }
}

class GoalTheSanctuaryAnax extends WhenPlayerCarrying
{
    /* Put this on the Anax in the sanctuary. */

    function OnPlayerPickedUp()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            Goal.Complete(eGoals.kKidnapTheAnax);
        }
    }

    function OnPlayerDropped()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            Goal.Activate(eGoals.kKidnapTheAnax);
        }
    }
}


/* -------- The Hand -------- */


class GoalTheMausoleumHand extends WhenPlayerCarrying
{
    /* Put this on the Hand in the catacombs. */

    function OnPlayerPickedUp()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            Goal.Complete(eGoals.kStealTheHand);
        }
    }

    function OnPlayerDropped()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            Goal.Activate(eGoals.kStealTheHand);
        }
    }
}


/* -------- Delivery -------- */


class GoalNearTheFishmongers extends SqRootScript
{
    /* Put this on a concrete room in front of the fishmongers. 
       Add a ControlDevice link to its door. */

    function OnPlayerRoomEnter()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            // FIXME: we haven't defined this line!
            //Goal.SpeakMonologue(eMonologues.kThisIsTheDeliverySpot);

            if (Goal.IsComplete(eGoals.kKidnapTheAnax)
                && Goal.IsComplete(eGoals.kStealTheHand))
            {
                // Open the door to the fishmongers when approaching with the items.
                Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
            }
        } else if (Goal.IsComplete(eGoals.kDeliverTheItems)) {
            // Close the door to the fishmongers again when leaving.
            Link.BroadcastOnAllLinks(self, "TurnOff", "ControlDevice");
        }
    }
}

class GoalEnterTheFishmongers extends SqRootScript
{
    /* Put this on a concrete room inside the fishmongers. */

    function OnPlayerRoomEnter()
    {
        // FIXME: we haven't defined this line!
        //Goal.CancelMonologue(eMonologues.kThisIsTheDeliverySpot);

        // FIXME: we haven't defined this conversation properly
        //Goal.StartConversation(eConversations.kAtTheDeliverySpot);
    }
}

class GoalDeliverTheItems extends MultipleDeliveries
{
    /* Put this on the concrete room where the items should be delivered.
       On The Anax and The Prophet's Hand put the ItemToDeliver script, with
       a ScriptParams("DeliveryRoom") link to this room. */

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }

    function OnItemDelivered() {
        local item = message().data;
        DisableItemWorldFrob(item);

        base.OnItemDelivered();
    }

    function OnAllItemsDelivered() {
    {
        Goal.Complete(eGoals.kKidnapTheAnax);
        Goal.Complete(eGoals.kStealTheHand);
        Goal.Complete(eGoals.kDeliverTheItems);

        // FIXME: we haven't defined this conversation properly
        //Goal.StartConversation(eConversations.kDeliveryIsDone);
    }
}


/* -------- The Ritual -------- */


class GoalDamnKeepers extends SqRootScript
{
    /* Put this on each concrete room where the Keeper intervention can happen. */

    function OnPlayerRoomEnter()
    {
        if (! Goal.IsVisible(eGoals.kStopTheRitual)) {

            // FIXME: needs work for gate and Keeper scripting. Will need a Conversation to be involved.

            Goal.Show(eGoals.kStopTheRitual);
            Goal.Show(eGoals.kReturnTheAnax);
        }
    }
}


class GoalStopTheRitualByForce extends SqRootScript
{
    /* Put this on the ritual-performing Lady di Rupo. Fires if she is knocked out or killed. */

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            Goal.Complete(eGoals.kStopTheRitual);
            Goal.Show(eGoals.kEscapeWithTheAnax);
        }
    }
}


class GoalStopTheRitualByTheft extends WhenPlayerCarrying
{
    /* Put this on the ritual versions of The Anax and The Prophet's Hand. Fires if they're picked up by the player. */

    function PlayerCarryingChanged(is_carrying)
    {
        if (is_carrying) {
            Goal.Complete(eGoals.kStopTheRitual);
            Goal.Show(eGoals.kEscapeWithTheAnax);
        }
    }
}


class GoalEscapeWithTheAnax extends SqRootScript
{
    /* Put this on the concrete room where the Anax should be carried to fulfill
       the "escape" goal. */

    function OnObjectRoomEnter()
    {
        // FIXME: determine if the Anax is the object in question
        local item = message().MoveObjId;
        if (false) {
            Goal.Complete(eGoals.kEscapeWithTheAnax);
        }
    }
}


class GoalReturnTheAnax extends SqRootScript
{
    /* Put this on the concrete room where the Anax should be delivered to the sanctuary.

       On the ritual Anax, put ItemToDeliver script, with a ScriptParams("DeliveryRoom") link
       to the room. */

    function OnItemDelivered()
    {
        local item = message().data;
        DisableItemWorldFrob(item);
        Goal.Complete(eGoals.kRescueTheAnax);
    }

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }
}


/* -------- Silly player -------- */


class GoalKeepTheAnaxAlive extends SqRootScript
{
    /* Put this on all the Anaxes. */

    function OnSlain()
    {
        Goal.Show(eGoals.kKeepTheAnaxAlive);
        Goal.Fail(eGoals.kKeepTheAnaxAlive);
    }
}


class GoalTheHandThatFeeds extends PreserveMe
{
    /* Put this on pre-ritual Lady di Rupo and all the Keepers. */

    function OnNotPreserved()
    {
        Goal.Show(eGoals.kDontBiteTheHand);
        Goal.Fail(eGoals.kDontBiteTheHand);
    }
}


/* -------- Loot -------- */


class GoalSellTheHand
{
    /* Put this on the concrete room where the ritual hand should be delivered.
       On the ritual hand put the ItemToDeliver script, with a ScriptParams("DeliveryRoom")
       link to this room. Add a ControlDevice link to the conversation to trigger. */

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }

    function OnItemDelivered() {
        local item = message().data;
        DisableItemWorldFrob(item);

        Goal.Show(eGoals.kBonusSellTheHand);
        Goal.Complete(eGoals.kBonusSellTheHand);

        Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
    }
}


/* ------------- */


class GoalUpdateLootGoals extends SqRootScript
{
    /* Put this on a loot item that has value, but shouldn't count towards loot
       objectives (e.g. payment for a job). It adds its own loot values to the
       values of all loot goals. Needs FrobInfo > World: Move/Script to work.
    */
    function OnFrobWorldEnd()
    {
        AddLootValuesToGoals();
    }

    function AddLootValuesToGoals()
    {
        if (Property.Possessed(self, "Loot")) {
            local item_gold = Property.Get(self, "Loot", "Gold").tointeger();
            local item_gems = Property.Get(self, "Loot", "Gems").tointeger();
            local item_goods = Property.Get(self, "Loot", "Art").tointeger();
            local item_total = item_gold + item_gems + item_goods;
            for (local goal = 0; goal < 32; goal += 1) {
                local state_name = "goal_state_" + goal;
                if (! Quest.Exists(state_name)) break;
                local total_name = "goal_loot_" + goal;
                local gold_name = "goal_gold_" + goal;
                local gems_name = "goal_gems_" + goal;
                local goods_name = "goal_goods_" + goal;
                if (Quest.Exists(total_name)) {
                    local goal_total = Quest.Get(total_name).tointeger();
                    Quest.Set(total_name, goal_total + item_total);
                }
                if (Quest.Exists(gold_name)) {
                    local goal_gold = Quest.Get(gold_name).tointeger();
                    Quest.Set(gold_name, goal_gold + item_gold);
                }
                if (Quest.Exists(gems_name)) {
                    local goal_gems = Quest.Get(gems_name).tointeger();
                    Quest.Set(gems_name, goal_gems + item_gems);
                }
                if (Quest.Exists(goods_name)) {
                    local goal_goods = Quest.Get(goods_name).tointeger();
                    Quest.Set(goods_name, goal_goods + item_goods);
                }
            }
        }
    }
}