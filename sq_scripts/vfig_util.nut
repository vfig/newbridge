class DebugQuestVar extends SqRootScript
{
    function OnTurnOn()
    {
        local link = Link.GetOne(linkkind("ScriptParams"), self, self);
        local goal_num = LinkTools.LinkGetData(link, "").tointeger();
        local goal_exists = (Quest.Exists("goal_state_" + goal_num).tointeger() != 0);

        local text = "Goal " + goal_num + ":";

        if (goal_exists) {
            local goal_text = Data.GetString("GOALS", "text_" + goal_num);
            local goal_state = Quest.Get("goal_state_" + goal_num).tointeger();
            local goal_visible = Quest.Get("goal_visible_" + goal_num).tointeger();
            local goal_reverse = Quest.Get("goal_reverse_" + goal_num).tointeger();
            local goal_type = Quest.Get("goal_type_" + goal_num).tointeger();
            local goal_target = Quest.Get("goal_target_" + goal_num).tointeger();
            local goal_target_name = Object.GetName(goal_target);
            local goal_irreversible = Quest.Get("goal_irreversible_" + goal_num).tointeger();
            local goal_final = Quest.Get("goal_final_" + goal_num).tointeger();
            local goal_max_diff = Quest.Get("goal_max_diff_" + goal_num).tointeger();
            local goal_min_diff = Quest.Get("goal_min_diff_" + goal_num).tointeger();
            local goal_loot = Quest.Get("goal_loot_" + goal_num).tointeger();
            local goal_gold = Quest.Get("goal_gold_" + goal_num).tointeger();
            local goal_gems = Quest.Get("goal_gems_" + goal_num).tointeger();
            local goal_goods = Quest.Get("goal_goods_" + goal_num).tointeger();
            local goal_special = Quest.Get("goal_special_" + goal_num).tointeger();
            local difficulty = Quest.Get("difficulty");

            if (goal_state == 0) {
                text += " [ ]   "
            } else if (goal_state == 1) {
                text += " [DONE]"
            } else if (goal_state == 2) {
                text += " [N/A] "
            } else if (goal_state == 3) {
                text += " [FAIL]"
            }

            text += " \"" + goal_text + "\"";

            if (goal_visible == 0) {
                text += " (hidden)"
            }

            if (goal_reverse == 1) {
                text += " don't"
            }

            if (goal_type == 0) {
                text += " (scripted)"
            } else if (goal_type == 1) {
                text += " steal"
            } else if (goal_type == 2) {
                text += " kill"
            } else if (goal_type == 3) {
                text += " loot:"
            } else if (goal_type == 3) {
                text += " go to"
            }

            if (goal_type == 1 || goal_type == 2 || goal_type == 4) {
                text += " " + goal_target_name + " (" + goal_target + ")";
            } else if (goal_type == 3) {
                if (goal_gold != 0) {
                    text += " " + goal_gold + " gold;";
                }
                if (goal_gems != 0) {
                    text += " " + goal_gems + " gems;";
                }
                if (goal_goods != 0) {
                    text += " " + goal_goods + " goods;";
                }
                if (goal_special != 0) {
                    text += " " + goal_special + " special;";
                }
                if (goal_loot != 0) {
                    text += " " + goal_loot + " total;";
                }

            }

            if (goal_irreversible != 0) {
                text += " (irreversible)";
            }

            if (goal_final != 0) {
                text += " (final goal)";
            }

            local diff_names = array(3);
            diff_names[0] = "Normal";
            diff_names[1] = "Hard";
            diff_names[2] = "Expert";

            if (goal_min_diff != 0) {
                if (goal_max_diff != 0) {
                    text += " [" + diff_names[goal_min_diff] + " - " + diff_names[goal_max_diff] + "]";
                } else {
                    text += " [" + diff_names[goal_min_diff] + " - expert]";
                }
            } else if (goal_max_diff != 0) {
                    text += " [normal - " + diff_names[goal_max_diff] + "]";
            }

            if (goal_min_diff != 0 || goal_max_diff != 0) {
                text += "(currently: " + diff_names[difficulty] + ")";
            }

        } else {

            text += " does not exist.";
        }

        DarkUI.TextMessage(text);
        print(text);
    }
}
