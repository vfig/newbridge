class CaloriesCounter extends SqRootScript
{
    // Put this on a marker and name it "CaloriesCounter".

    function OnIAmFood() {
        local count;
        local food_type = message().data;
        local qvar = ("FoodCount_" + food_type);
        if (Quest.Exists(qvar)) {
            count = Quest.Get(qvar);
        } else {
            count = 0;
        }
        Quest.Set(qvar, (count + 1));

        // Also keep a total
        local qvar = ("FoodCountAll");
        if (Quest.Exists(qvar)) {
            count = Quest.Get(qvar);
        } else {
            count = 0;
        }
        Quest.Set(qvar, (count + 1));
    }

    function OnIAmEaten() {
        local eaten;
        local food_type = message().data;
        local qvar = ("FoodEaten_" + food_type);
        if (Quest.Exists(qvar)) {
            eaten = Quest.Get(qvar);
        } else {
            eaten = 0;
        }
        Quest.Set(qvar, (eaten + 1));

        // Also increment the total
        local qvar = ("FoodEatenAll");
        if (Quest.Exists(qvar)) {
            eaten = Quest.Get(qvar);
        } else {
            eaten = 0;
        }
        Quest.Set(qvar, (eaten + 1));
    }
}

class BaseFood extends SqRootScript
{
    // Override this for each type of food.
    function FoodType() {
        return "Unknown";
    }

    function OnSim() {
        if (message().starting) {
            // Find the calories counter and tell it we're here
            local counter = Object.Named("CaloriesCounter");
            if (counter != 0) {
                SendMessage(counter, "IAmFood", FoodType());
            }
        }
    }

    function OnFrobInvEnd() {
        if (message().Frobber == Object.Named("Player")); {
            local counter = Object.Named("CaloriesCounter");
            if (counter != 0) {
                SendMessage(counter, "IAmEaten", FoodType());
            }
        }
    }
}

class AppleFood extends BaseFood
{
    function FoodType() {
        return "Apple";
    }
}

class CucumberFood extends BaseFood
{
    function FoodType() {
        return "Cucumber";
    }
}

class CarrotFood extends BaseFood
{
    function FoodType() {
        return "Carrot";
    }
}

class CheeseFood extends BaseFood
{
    function FoodType() {
        return "Cheese";
    }
}

class BreadFood extends BaseFood
{
    function FoodType() {
        return "Bread";
    }
}

class DeerLegFood extends BaseFood
{
    function FoodType() {
        return "DeerLeg";
    }
}
