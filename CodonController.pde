class CodonController extends ControllerBase implements CodonModelClient, CodonViewClient {
    CodonBaseModel codonModel;
    CodonView codonView;


    CodonController(ControllerBase parentController, ViewBase parentView, CodonBaseModel codonModel) {
        super(parentController);
        
        this.codonModel = codonModel;
        this.codonView = new CodonView(parentView, codonModel);

        this.codonModel.registerClient(this);
        this.codonView.registerClient(this);
    }


    void onDestroy() {
        codonView.destroy();
        codonView.unregisterClient(this);
        codonModel.unregisterClient(this);
    }

    void onDestroy(CodonBaseModel codonModel) {
        destroy();
    }
}
