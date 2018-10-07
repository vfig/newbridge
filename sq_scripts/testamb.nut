class TestAmbient extends SqRootScript
{
    function Schema() {
        return "silenc9s";
    }

    function OnTurnOn() {
        //local success = Sound.PlayEnvSchema(self, string Tags, object SourceObject = 0, object AgentObject = 0, eEnvSoundLoc loc = kEnvSoundOnObj);
        local schema = Schema();
        local success = Sound.PlaySchemaAmbient(self, schema);
        print(">> playing " + schema + ": " + (success ? "ok" : "FAIL"));
    }

    function OnTurnOff() {
        local schema = Schema();
        local success = Sound.HaltSchema(self, schema, self);
        print(">> halting " + schema + ": " + (success ? "ok" : "FAIL"));
    }

    function OnSchemaDone() {
        local schema = message().name;
        local pos = message().coordinates;
        print(">> finished " + schema + " at " + pos);
    }
}

class TestAmbient1 extends TestAmbient
{
    function Schema() {
        return "m20city1loop";
    }
}

class TestAmbient2 extends TestAmbient
{
    function Schema() {
        return "m20city1mood";
    }
}

class TestAmbient3 extends TestAmbient
{
    function Schema() {
        return "m20city1ten";
    }
}

class TestAmbient4 extends TestAmbient
{
    function Schema() {
        return "m20city3ten";
    }
}
