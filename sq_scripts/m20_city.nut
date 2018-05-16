class DeliveryDiRupo extends SqRootScript
{
    function OnGivePayment()
    {
        // Trigger the loot goals to update for this payment.
        // Got to do this before transferring containment, otherwise that'll
        // set off quest var state changes.
        local link = Link.GetOne("Contains", self);
        local payment = LinkDest(link);
        SendMessage(payment, "UpdateLootGoals");

        // Give the player everything di Rupo is carrying
        local player = Object.Named("Player");
        local result = Container.MoveAllContents(self, player);
   }
}