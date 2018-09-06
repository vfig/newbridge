class Drawer extends SqRootScript
{
    function OnFrobWorldEnd() {
        local distance = vector(0, -0.5, 0);
        if (! IsDataSet("Searched")) {
            SetData("Searched", true);
            Object.Teleport(self, distance, vector(), self);
        } else {
            ClearData("Searched");
            Object.Teleport(self, -distance, vector(), self);
        }
    }
}
