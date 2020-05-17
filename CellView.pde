class CellView extends ViewBase {
    ArrayList<CellViewClient> clients = new ArrayList<CellViewClient>();
    CellModel cellModel;

    final float wallSizeOnMaxHealth = 10;
    final float energySymbolSizeOnMaxEnergy = 8;


    CellView(CellModel cellModel) {
        this.cellModel = cellModel;
    }


    void registerClient(CellViewClient client) {
        if(!clients.contains(client)) {
            clients.add(client);
        }
    }

    void unregisterClient(CellViewClient client) {
        clients.remove(client);
    }


    void beforeDrawChildren() {
        noStroke();

        fill(250, 90, 70);
        rect(0, 0, 100, 100);

        if (cellModel.edited == true) {
            fill(115, 230, 155);

        } else if (cellModel.isSelected()) {
            fill(35, 225, 230);

        } else {
            fill(255, 165, 135);
        }
        float wallSize = cellModel.wallHealth * wallSizeOnMaxHealth;
        rect(wallSize, wallSize, 100 - 2 * wallSize, 100 - 2 * wallSize);
        
        fill(0);
        noStroke();
        ellipse(50, 50, 2 * energySymbolSizeOnMaxEnergy, 2 * energySymbolSizeOnMaxEnergy);

        float energySymbolSize = cellModel.energyLevel * energySymbolSizeOnMaxEnergy;
        fill(245, 245, 115);
        beginShape();
        vertex(50 - 0.00 * energySymbolSize, 50 - 1.00 * energySymbolSize);
        vertex(50 - 0.48 * energySymbolSize, 50 + 0.12 * energySymbolSize);
        vertex(50 + 0.15 * energySymbolSize, 50 + 0.15 * energySymbolSize);
        vertex(50 - 0.00 * energySymbolSize, 50 + 1.00 * energySymbolSize);
        vertex(50 + 0.48 * energySymbolSize, 50 - 0.12 * energySymbolSize);
        vertex(50 - 0.15 * energySymbolSize, 50 - 0.15 * energySymbolSize);
        endShape(CLOSE);
    }


    boolean afterMousePressedChildren(float viewMouseX, float viewMouseY) {
        if (viewMouseX > 0 && viewMouseX < 100 && viewMouseY > 0 && viewMouseY < 100) {
            if (cellModel.isSelected()) {
                cellModel.unSelectCell();
            } else {
                cellModel.selectCell();
            }
            return true;
        } else {
            cellModel.unSelectCell();
            return false;
        }    
    }
}
