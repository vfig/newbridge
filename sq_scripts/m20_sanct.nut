class SanctBell extends SqRootScript
{
    function OnSlashStimStimulus()
    {
        # Rung by a sword
        Ring();
    }

    function OnPokeStimStimulus()
    {
        # Rung by an arrow
        Ring();
    }

    function OnBashStimStimulus()
    {
        # Rung by a blackjack
        Ring();
    }

    function Ring()
    {
        local schema = "m20sanctbell";
        Sound.PlaySchemaAtObject(self, schema, self);
    }
}
