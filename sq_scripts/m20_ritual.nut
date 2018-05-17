class RitualPerformer extends SqRootScript
{
    function OnUnpocketHand()
    {
        // Transfer the Hand to the Alt location
        local link = Link.GetOne("Contains", self);
        Link_SetContainType(link, eContainType.kContainTypeAlt);

        // Tell the controller about it
        local controller = LinkDest(Link_GetScriptParams("Controller", self));
        SendMessage(controller, "PerformerWavingStarted");
    }

    function OnPocketHand()
    {
        // Put the Hand back on the belt
        local link = Link.GetOne("Contains", self);
        Link_SetContainType(link, eContainType.kContainTypeBelt);

        // Tell the controller about it
        local controller = LinkDest(Link_GetScriptParams("Controller", self));
        SendMessage(controller, "PerformerWavingFinished");
    }

    function OnPatrolPoint()
    {
        // Tell the controller we've reached another patrol point
        local controller = LinkDest(Link_GetScriptParams("Controller", self));
        SendMessage(controller, "PerformerPatrolPoint", message().patrolObj);
    }

    function OnConversationFinished()
    {
        // Tell the controller we've finished going down
        local controller = LinkDest(Link_GetScriptParams("Controller", self));
        SendMessage(controller, "PerformerConversationFinished");
    }
}

class RitualController extends SqRootScript
{
    // Objects and AIs involved in the ritual
    performer = null;
    rounds = [];
    downs = [];
    extras = [];
    lights = [];

    // Vertices in the order that the performer should visit them.
    stages = [0, 1, 2, 3, 4, 5, 6];

    // Status of the ritual
    // FIXME: the following status stuff needs to be GetData/SetData'd so it saves and loads
    is_running = false;
    current_index = 0;
    current_stage = 0;
    current_trol_target = 0;

    function OnSim()
    {
        if (message().starting) {
            local links = Link.GetAll("ScriptParams", self);
            foreach (link in links) {
                local obj = LinkDest(link);
                local data = LinkTools.LinkGetData(link, "");
                if (data == "Performer") {
                    performer = obj;
                } else if (data == "Round") {
                    rounds.append(obj);
                } else if (data == "Down") {
                    downs.append(obj);
                } else if (data == "Light") {
                    lights.append(obj);
                } else if (data == "Extra") {
                    extras.append(obj);
                }
            }
            // Check everything's okay
            if (performer == null) {
                print("RITUAL DEATH: no performer.");
                Object.Destroy(self);
            }
            if (rounds.len() != stages.len()) {
                print("RITUAL DEATH: incorrect number of rounds.");
                Object.Destroy(self);
            }
            // FIXME:
            /*
            if (downs.len() != stages.len()) {
                print("RITUAL DEATH: incorrect number of downs.");
                Object.Destroy(self);
            }
            if (lights.len() != stages.len()) {
                print("RITUAL DEATH: incorrect number of lights.");
                Object.Destroy(self);
            }
            if (extras.len() != stages.len()) {
                print("RITUAL DEATH: incorrect number of extras.");
                Object.Destroy(self);
            }
            */
            // Add some data links to the performer
            Link_CreateScriptParams("Controller", performer, self);
        }
    }

    function OnTurnOn()
    {
        if (! is_running) {
            is_running = true;
            StartRitual();
        }
    }

    function OnPerformerPatrolPoint()
    {
        local trol = message().data;
        if (trol == current_trol_target) {
            // We've done our little dance. Time to get down tonight.
            local down = downs[current_stage];
            local result = AI.StartConversation(down);
            print("Starting Down: " + Object.GetName(down) + " (" + down + "): " + result);
        }
    }

    function OnPerformerWavingStarted()
    {
        // FIXME: make the extras chant, if they're not busy
    }

    function OnPerformerWavingFinished()
    {
        // FIXME: make the extras stop chanting, if they're not busy

        // Check if we've finished the final stage
        if (current_index == (stages.len() - 1)) {
            FinishRitual();
        }
    }

    function OnPerformerConversationFinished()
    {
        // The ritual is proceeding according to plan.
        SetCurrentIndex(current_index + 1);
    }

    function StartRitual()
    {
        // Begin at the beginning
        SetCurrentIndex(0);
        Link_SetCurrentPatrol(performer, current_trol_target);
        Object.AddMetaProperty(performer, "M-DoesPatrol");
        Object.AddMetaProperty(performer, "M-RitualTrance");

        // FIXME: lights and extras
    }

    function FinishRitual()
    {
        // 

        // FIXME: lights and extras
    }

    function SetCurrentIndex(index)
    {
        // Update the ritual status, and the performer's target
        current_index = index;
        if (current_index >= stages.len()) {
            print("RITUAL DEATH: me am go too far!");
            Object.Destroy(self);
        }
        current_stage = stages[current_index];
        current_trol_target = rounds[current_stage];

        // FIXME: update lights
        // FIXME: update extras
    }
}