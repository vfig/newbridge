class DeliveryDiRupo extends SqRootScript
{
    function OnGrabPayment()
    {
        local link = Link.GetOne("Contains", self);
        LinkTools.LinkSetData(link, "", "Alternate");
    }

    function OnGivePayment()
    {
        local link = Link.GetOne("Contains", self);
        local payment = LinkDest(link);
        Link.Destroy(link);
        // FIXME: so where does the payment end up now?
   }
}