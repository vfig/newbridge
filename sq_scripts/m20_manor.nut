class AlasPoorBurrick extends SqRootScript
{
    function OnTurnOn() {
        local player = Object.Named("Player");
        Sound.PlayVoiceOver(player, "alaspoorburrick");
    }
}
