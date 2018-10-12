class SecretsCounter extends SqRootScript
{
    // Put this on a marker and name it "SecretsCounter".

    function OnIAmHidden() {
        local count;
        if (Quest.Exists("SecretsCount")) {
            count = Quest.Get("SecretsCount");
        } else {
            count = 0;
        }
        Quest.Set("SecretsCount", (count + 1));
    }

    function OnIAmFound() {
        local found;
        if (Quest.Exists("SecretsFound")) {
            found = Quest.Get("SecretsFound");
        } else {
            found = 0;
        }
        Quest.Set("SecretsFound", (found + 1));

        // Show a message and play a sound
        local message = Data.GetString("playhint", "FoundSecret", "Found Secret!");
        DarkUI.TextMessage(message);
        Sound.PlaySchemaAmbient(self, "new_obj");
    }
}

class BaseSecret extends SqRootScript
{
    function OnSim() {
        if (message().starting) {
            // Find the secret counter and tell it we're here
            local counter = Object.Named("SecretsCounter");
            if (counter != 0) {
                SendMessage(counter, "IAmHidden");
            }
        }
    }

    function ActivateSecret() {
        if (! IsDataSet("SecretFound")) {
            SetData("SecretFound", true);
            local counter = Object.Named("SecretsCounter");
            if (counter != 0) {
                SendMessage(counter, "IAmFound");
            }
        }
    }
}

class FrobSecret extends BaseSecret
{
    // Put this on a secret object that counts as found when
    // frobbed in the world. Make sure they have "Script" FrobInfo!

    function OnFrobWorldEnd() {
        ActivateSecret();
    }
}

class TurnOnSecret extends BaseSecret
{
    function OnTurnOn() {
        ActivateSecret();
    }
}
