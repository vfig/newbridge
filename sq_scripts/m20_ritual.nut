class RitualPerformer extends SqRootScript
{
    function OnUnpocketHand()
    {
        // Transfer the Hand to the Alt location
    }

    function OnPocketHand()
    {
        // Put the Hand back on the belt
    }

    function OnPatrolPoint()
    {
        local controller = LinkDest(Link_GetScriptParams("Controller", self));
        SendMessage(controller, "PerformerPatrolPoint", message().patrolObj);
    }

    function OnObjActResult()
    {
        local sResults = ["kActionDone", "kActionFailed", "kActionNotAttempted"];
        local sActions = ["kAINoAction", "kAIGoto", "kAIFrob", "kAIManeuver"];
        print("ObjActResult action: " + sActions[message().action] + ", result: " + sResults[message().result]
            + ", data: " + actdata + ", target: " + Object.GetName(target) + " (" + target  ")");
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

    // Status of the ritual
    stages = [0, 1, 2, 3, 4, 5, 6];

    // FIXME: the following status stuff needs to be GetData/SetData'd so it saves and loads
    is_running = false;
    current_index = 0;

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
            current_index = 0;

            Link_DestroyAll("AICurrentPatrol", performer);
            Link.Create("AICurrentPatrol", performer, rounds[current_index]);
            Object.AddMetaProperty(performer, "M-DoesPatrol");
        }
    }

    function OnPerformerPatrolPoint()
    {
        local trol = message().data;
        local trol_index = rounds.find(trol);
        print("Performer > PatrolPoint: " + Object.GetName(trol) + " (" + trol + "), which is index " + trol_index);
        if (trol_index == null) {
            print("RITUAL DEATH: performer patrol point not part of ritual.");
            Object.Destroy(self);
        }
        local down = downs[trol_index];
        print("Starting Down: " + Object.GetName(down) + " (" + down + ")");
        //Object.RemoveMetaProperty(performer, "M-DoesPatrol");
        //local result = AI.StartConversation(down);
        //print("Start conversation result: " + result);
        SendMessage(down, "TurnOn");
    }
}