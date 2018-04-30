class GoalMeetArgaux extends SqRootScript
{
    /* Put this on a concrete room with TrigRoomPlayer script, with a ControlDevice to self. */
    function OnTurnOn()
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
            Quest.Set("goal_state_1", 1);
            Quest.Set("goal_visible_1", 1);
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
