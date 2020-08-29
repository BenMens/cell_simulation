package nl.benmens.cellsimulation.cell;

import java.util.ArrayList;

import nl.benmens.cellsimulation.CodonBaseModel;
import nl.benmens.cellsimulation.CodonDetailsView;
import nl.benmens.cellsimulation.ControllerBase;
import nl.benmens.cellsimulation.ViewBase;

import java.awt.geom.Rectangle2D;


public class CellEditorController extends ControllerBase implements CellModelClient, CellEditorViewClient {
  CellModel cellModel;
  public CellEditorView cellEditorView;
  CellController cellController;
  ArrayList<CodonDetailsView> codonDetailsViews = new ArrayList<CodonDetailsView>();

  public CellEditorController(ControllerBase parentController, ViewBase parentView, CellModel cellModel) {
    super(parentController);

    this.cellModel = cellModel;
    cellEditorView = new CellEditorView(parentView, cellModel);

    cellController = new CellController(this, cellEditorView, cellModel);
    cellController.cellView.isDisabled = true;

    cellModel.registerClient(this);
    cellEditorView.registerClient(this);

    rebuildCodonViews();
  }

  public void beforeLayoutChildren() {
    Rectangle2D.Float frameRect = cellEditorView.getFrameRect();

    cellEditorView.setBoundsRect(0, 0, frameRect.width, frameRect.height);
    cellController.cellView.setFrameRect(20, 20, 200, 200);

    float codonHeight = cellEditorView.calculatedCodonsHeight();
    float codonY = cellEditorView.CODONS_Y_POS;
    for (CodonDetailsView codonView : codonDetailsViews) {
      codonView.setFrameRect(40, codonY, frameRect.width - 80, codonHeight);

      codonY += codonHeight + cellEditorView.CODONS_SPACING;
    }
  }

  public void onDestroy() {
    cellEditorView.destroy();
    cellEditorView.unregisterClient(this);
    cellModel.unregisterClient(this);

    destroyCodonViews();
  }

  public void onDestroy(CellModel cellModel) {
    destroy();
  }

  public void destroyCodonViews() {
    for (CodonDetailsView codonView : codonDetailsViews) {
      codonView.destroy();
    }

    codonDetailsViews.clear();
  }

  public void rebuildCodonViews() {
    destroyCodonViews();

    for (CodonBaseModel codonModel : cellModel.codonModels) {
      codonDetailsViews.add(new CodonDetailsView(this.cellEditorView, codonModel));
    }

    updateLayout();
  }

  public void onAddCodon(CodonBaseModel codonModel) {
    rebuildCodonViews();
  }

  public void onRemoveCodon(CodonBaseModel codonModel) {
    rebuildCodonViews();
  }
}