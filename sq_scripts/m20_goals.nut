class GoalMeetArgaux extends SqRootScript
{
    /* Put this on a PlayerBoundsTrigger with a ControlDevice to self. */
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
        if (Quest.Get("goal_state_1") == 0 && Quest.Get("goal_visible_1") == 1) {
            // Complete 'Find Argauxs Infauxs'
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
            if (Quest.Get("goal_state_2") == 0 && Quest.Get("goal_visible_2") == 1) {
                // Complete 'Kidnap the Anax'
                Quest.Set("goal_state_2", 1);
            }
        }
    }

    function Deactivate()
    {
        // Only possible to affect this goal before 'Deliver the Items' is done.
        if (Quest.Get("goal_state_4") == 0) {
            if (Quest.Get("goal_state_2") == 1) {
                // Reset 'Kidnap the Anax'
                Quest.Set("goal_state_2", 0);
            }
        }
    }
}
