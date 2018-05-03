class AddMapPage extends SqRootScript
{
    /* Add a 'Room > Automap' property to this object with the Page value set to a map
       page 1 lower or higher than map_min_page/map_max_page.

       When it receives a TurnOn, FrobWorldEnd, or FrobInvEnd message, it will
       update the appropriate variable to include that page, then display the map.
    */

    function OnFrobWorldEnd()
    {
        Activate();
    }

    function OnFrobInvEnd()
    {
        Activate();
    }

    function OnTurnOn()
    {
        Activate();
    }

    function Activate()
    {
        if (Property.Possessed(self, "Automap")) {
            local old_min = Quest.Get("map_min_page").tointeger();
            local old_max = Quest.Get("map_max_page").tointeger();
            local new_page = Property.Get(self, "Automap", "Page").tointeger();

            if (new_page < old_min) {
                Quest.Set("map_min_page", new_page);
            } else if (new_page > old_max) {
                Quest.Set("map_max_page", new_page);
            }
            Quest.Set("map_cur_page", new_page);
            Debug.Command("automap");
        }
    }
}

class AddMapPageAndAutomapRoom extends AddMapPage
{
    /* Like 'AddMapPage', but also add 'Route' links from the object to one or
       more concrete rooms, in order.

       When activated, it will set the Automap Page property on those rooms (if
       not already set) to the new map page, and the Location property to the
       index of the link (starting at 0).
    */

    function Activate()
    {
        if (Property.Possessed(self, "Automap")) {
            local page = Property.Get(self, "Automap", "Page").tointeger();
            local location = 0;
            local links = Link.GetAll(linkkind("Route"), self);
            foreach (link in links) {
                local room = LinkDest(link);
                if ((room != 0) && (! Property.Possessed(room, "Automap")))
                {          
                    Property.Set(room, "Automap", "Page", page);
                    Property.Set(room, "Automap", "Location", location);
                }
                location += 1;
            }
        }

        base.Activate();
    }
}