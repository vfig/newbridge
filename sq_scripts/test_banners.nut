class TestSlidingBanner extends SqRootScript {
    function OnFrobWorldEnd() {
        local animS = Property.Get(self, "StTweqModels", "AnimS");
        local isTurnedOn = ((animS & 2) == 0);
        SlideBanner(!isTurnedOn);
    }

    function OnTurnOn() {
        SlideBanner(true);
    }

    function OnTurnOff() {
        SlideBanner(false);
    }

    function SlideBanner(open) {
        // Turn on the models tweq, setting the reverse bit according to "open".
        local animS = Property.Get(self, "StTweqModels", "AnimS");
        animS = (animS | 1); // Set the On bit.
        // Toggle the reverse bit.
        if (open) {
            animS = (animS & ~2)
        } else {
            animS = (animS | 2)
        }
        Property.Set(self, "StTweqModels", "AnimS", animS);

        //local message = (open ? "TurnOn" : "TurnOff");
        //print("Sending message: " + message);
        //Link.BroadcastOnAllLinks(self, message, "ControlDevice");
    }
}
