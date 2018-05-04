class GoalMeetArgaux extends SqRootScript
{
    /* Put this on a concrete room. */

    function OnPlayerRoomEnter()
    {
        Activate();
    }

    function Activate()
    {
        if (Quest.Get("goal_state_0") == 0) {
            // Cancel 'Meet Argaux'
            Quest.Set("goal_state_0", 2);
            // Show 'Find out what Argaux was up to'
            Quest.Set("goal_visible_1", 1);
        }
    }
}

class GoalFindArgauxsInfauxs extends SqRootScript
{
    /* Put this on book/scrolls to frob for info, with FrobInfo > Script flags as appropriate */

    function OnFrobWorldEnd()
    {
        Activate();
    }

    function OnFrobInvEnd()
    {
        Activate();
    }

    function Activate()
    {
        if (Quest.Get("goal_state_1") == 0) {
            // Complete 'Find Argauxs Infauxs'
            Quest.Set("goal_state_0", 2);
            Quest.Set("goal_visible_1", 1);
            Quest.Set("goal_state_1", 1);
            // Show 'Kidnap the Anax', 'Steal the Hand', and 'Deliver the Items'
            Quest.Set("goal_visible_2", 1);
            Quest.Set("goal_visible_3", 1);
            Quest.Set("goal_visible_4", 1);
        }
    }
}

class GoalKidnapTheAnax extends SqRootScript
{
    /* Put this on The Anax */
    function OnContained()
    {
        if (message().container == Object.Named("Player")) {
            if (message().event == eContainsEvent.kContainAdd) {
                Activate();
            } else if (message().event == eContainsEvent.kContainRemove) {
                Deactivate();
            }
        }
    }

    function Activate()
    {
        // Only possible to affect this goal before 'Deliver the Items' is done.
        if (Quest.Get("goal_state_4") == 0) {
            // Complete 'Kidnap the Anax'
            Quest.Set("goal_state_2", 1);
        }
    }

    function Deactivate()
    {
        // Only possible to affect this goal before 'Deliver the Items' is done.
        if (Quest.Get("goal_state_4") == 0) {
            // Reset 'Kidnap the Anax'
            Quest.Set("goal_state_2", 0);
        }
    }
}

class GoalStealTheHand extends SqRootScript
{
    /* Put this on The Prophet's Hand */
    function OnContained()
    {
        if (message().container == Object.Named("Player")) {
            if (message().event == eContainsEvent.kContainAdd) {
                Activate();
            } else if (message().event == eContainsEvent.kContainRemove) {
                Deactivate();
            }
        }
    }

    function Activate()
    {
        // Only possible to affect this goal before 'Deliver the Items' is done.
        if (Quest.Get("goal_state_4") == 0) {
            // Complete 'Kidnap the Anax'
            Quest.Set("goal_state_3", 1);
        }
    }

    function Deactivate()
    {
        // Only possible to affect this goal before 'Deliver the Items' is done.
        if (Quest.Get("goal_state_4") == 0) {
            // Reset 'Kidnap the Anax'
            Quest.Set("goal_state_3", 0);
        }
    }
}

class GoalDeliverTheItems extends SqRootScript
{
    /* Put this on the concrete room where the items should be delivered.
       On The Anax and The Prophet's Hand put the ItemToDeliver script, with
       a ScriptParams("DeliveryRoom") link and a ScriptParams("NotifyDelivery")
       link to the target (concrete) room. */

    function OnBeginScript()
    {
        local links = Link.GetAll(linkkind("~ScriptParams"), self);
        foreach (link in links) {
            local data = LinkTools.LinkGetData(link, "");
            local item = LinkDest(link);
            if (data == "NotifyDelivery") {
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
        DisableItemWorldFrob(item);
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
            if (data == "NotifyDelivery") {
                local delivered = (GetData("ItemDelivered_" + item) == 1);
                all_delivered = all_delivered && delivered;
            }
        }
        if (all_delivered) {
            Activate();
        }
    }

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }

    function Activate()
    {
        if (Quest.Get("goal_state_4") == 0) {
            Quest.Set("goal_state_4", 1);
            // Force completion of the get item goals too.
            Quest.Set("goal_state_2", 1);
            Quest.Set("goal_state_3", 1);
        }
    }
}

class GoalDamnKeepers extends SqRootScript
{
    /* Put this somewhere, I dunno, where the damn keeper intervention activates it. */

    function OnFrobWorldEnd()
    {
        Quest.Set("goal_visible_5", 1);
        Quest.Set("goal_visible_6", 1);
    }
}

class GoalStopTheRitualByForce extends SqRootScript
{
    /* Put this on the ritual-performing Lady di Rupo. Fires if she is knocked out or killed. */

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            Activate();
        }
    }

    function Activate()
    {
        if (Quest.Get("goal_state_5") == 0) {
            Quest.Set("goal_state_5", 1);
        }
    }
}

class GoalStopTheRitualByTheft extends SqRootScript
{
    /* Put this on the ritual clones of The Anax and The Prophet's Hand. Fires if they're picked up by the player. */

    function OnContained()
    {
        if (message().container == Object.Named("Player")) {
            if (message().event == eContainsEvent.kContainAdd) {
                Activate();
            }
        }
    }

    function Activate()
    {
        if (Quest.Get("goal_state_5") == 0) {
            Quest.Set("goal_state_5", 1);
        }
    }
}

class GoalRescueTheAnax extends SqRootScript
{
    /* Put this on the concrete room where the Anax should be delivered.

       On the Anax, put ItemToDeliver script, with a ScriptParams("DeliveryRoom") link
       and a ScriptParams("NotifyDelivery") link to the target (concrete) room. */

    function OnItemDelivered()
    {
        local item = message().data;
        DisableItemWorldFrob(item);
        Activate();
    }

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }

    function Activate()
    {
        if (Quest.Get("goal_state_6") == 0) {
            Quest.Set("goal_state_6", 1);
        }
    }
}

class GoalKeepTheAnaxAlive extends SqRootScript
{
    /* Put this on all the Anaxes. */

    function OnSlain()
    {
        Activate();
    }

    function Activate()
    {
        Quest.Set("goal_visible_7", 1);
        Quest.Set("goal_state_7", 3);
    }
}

class GoalTheHandThatFeeds extends SqRootScript
{
    /* Put this on pre-ritual Lady di Rupo and all the Keepers. */

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
            Activate();
        }
    }

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            Activate();
        }
    }

    function Activate()
    {
        Quest.Set("goal_visible_8", 1);
        Quest.Set("goal_state_8", 3);
    }
}

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