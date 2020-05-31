class CellModel implements CodonModelParent {
    ArrayList<CellModelClient> clients = new ArrayList<CellModelClient>();
    BodyModel bodyModel;

    ArrayList<CodonBaseModel> codonModels = new ArrayList<CodonBaseModel>();

    float ticksPerCodonTick = 50;
    float ticksSinceLastCodonTick;

    boolean isDead = false;

    private PVector position;
    private float wallHealth = 1;
    private float energyLevel = 1;
    float energyCostPerTick = 0.01;

    int codonHandPosition = 0;
    int executeHandPosition = 0;
    boolean isExecuteHandPointingOutward = false;
    int previousExecuteHandPosition = 0;
    boolean previousIsExecuteHandPointingOutward = false;

    boolean edited = false;


    CellModel(BodyModel bodyModel, PVector position) {
        this.bodyModel = bodyModel;
        bodyModel.addCell(this);

        this.position = position;

        CodonBaseModel codon = new CodonMoveExecuteHandModel(this);
        codon.setCodonParameter("outward");

        codon = new CodonRepairModel(this);
        codon.setCodonParameter("wall");

        codon = new CodonMoveExecuteHandModel(this);
        codon.setCodonParameter("inward");

        codon = new CodonMoveExecuteHandModel(this);
        codon.setCodonParameter("weakest codon");

        codon = new CodonRepairModel(this);
        codon.setCodonParameter("codon");
    }


    void registerClient(CellModelClient client) {
        if(!clients.contains(client)) {
            clients.add(client);

            for (CodonBaseModel codonModel: codonModels) {
                client.onAddCodon(codonModel);
            }
        }
    }

    void unregisterClient(CellModelClient client) {
        clients.remove(client);
    }


    void addCodon(CodonBaseModel newCodonModel) {
        codonModels.add(newCodonModel);

        for(CellModelClient client : new ArrayList<CellModelClient>(clients)) {
            client.onAddCodon(newCodonModel);
        }

        for (CodonBaseModel codonModel : codonModels) {
            codonModel.updatePosition();
        }
    }

    void removeCodon(CodonBaseModel oldCodonModel) {
        codonModels.remove(oldCodonModel);

        if (codonHandPosition >= codonModels.indexOf(oldCodonModel)) {
            codonHandPosition--;
        }

        for(CellModelClient client: clients) {
            client.onRemoveCodon(oldCodonModel);
        }

        for (CodonBaseModel codonModel : codonModels) {
            codonModel.updatePosition();
        }

        if (previousExecuteHandPosition >= codonModels.size()) {
            previousExecuteHandPosition = codonModels.size() - 1;
        }
        if (executeHandPosition >= codonModels.size()) {
            executeHandPosition = codonModels.size() - 1;
        }
    }


    void handleCollision(ParticleBaseModel particle) {
        wallHealth -= particle.cellWallHarmfulness;
    }


    void replaceCodon(CodonBaseModel oldCodon, CodonBaseModel newCodon) {
        oldCodon.isDead = true;
        codonModels.remove(newCodon);
        codonModels.add(codonModels.indexOf(oldCodon), newCodon);
    }


    PVector getPosition() {
        return position;
    }


    ArrayList<CodonBaseModel> getCodonList() {
        return codonModels;
    }


    // ################################################################################################################################################
    // tick
    // ################################################################################################################################################
    void tick() {
        if (energyLevel > energyCostPerTick) {
            while (ticksSinceLastCodonTick >= ticksPerCodonTick) {
                codonTick();
                ticksSinceLastCodonTick -= ticksPerCodonTick;
            }
            ticksSinceLastCodonTick++;
        }

        ArrayList<CodonBaseModel> codonModelsCopy = (ArrayList<CodonBaseModel>)codonModels.clone();
        for(CodonBaseModel codonModel : codonModelsCopy) {
            codonModel.tick();
        }

        if (wallHealth <= 0) {
            isDead = true;
        }
    }

    // ################################################################################################################################################
    // codon tick
    // ################################################################################################################################################
    void codonTick() {
        previousExecuteHandPosition = executeHandPosition;
        previousIsExecuteHandPointingOutward = isExecuteHandPointingOutward;

        if (codonModels.size() != 0 ) {
            energyLevel = max(energyLevel - energyCostPerTick, 0);
            codonHandPosition = (codonHandPosition + 1) % codonModels.size();

            if (energyLevel > codonModels.get(codonHandPosition).getEnergyCost()) {
                codonModels.get(codonHandPosition).executeCodon();
            }
        }
    }


    // ################################################################################################################################################
    // clean up tick
    // ################################################################################################################################################
    void cleanUpTick() {
        for (int i = codonModels.size() - 1; i >= 0; i--) {
            codonModels.get(i).cleanUpTick();
        }

        if (isDead) {
            for (int i = codonModels.size() - 1; i >= 0; i--) {
                CodonBaseModel codonModel = codonModels.get(i);

                new ParticleWasteModel(bodyModel, codonModel.getPosition().x, codonModel.getPosition().y);

                codonModel.isDead = true;
                codonModel.cleanUpTick();
            }

            for(CellModelClient client : new ArrayList<CellModelClient>(clients)) {
                client.onDestroy(this);
            }

            bodyModel.removeCell(this);
        }
    }


    // ################################################################################################################################################
    // codon hand getters and setters
    // ################################################################################################################################################
    int getCodonHandPosition() {
        return codonHandPosition;
    }

    void setCodonHandPosition(int codonHandPosition) {
        this.codonHandPosition = (codonHandPosition % codonModels.size() + codonModels.size()) % codonModels.size();
    }


    // ################################################################################################################################################
    // execute hand getters and setters
    // ################################################################################################################################################
    int getExecuteHandPosition() {
        return executeHandPosition;
    }

    boolean getIsExecuteHandPointingOutward() {
        return isExecuteHandPointingOutward;
    }

    void setExecuteHandPosition(int executeHandPosition) {
        this.executeHandPosition = (executeHandPosition % codonModels.size() + codonModels.size()) % codonModels.size();
    }

    void setIsExecuteHandPointingOutward(boolean isExecuteHandPointingOutward) {
        this.isExecuteHandPointingOutward = isExecuteHandPointingOutward;
    }


    // ################################################################################################################################################
    // wall health getters and setters
    // ################################################################################################################################################
    float getWallHealth() {
        return wallHealth;
    }

    void setWallHealth(float health) {
        wallHealth = constrain(health, 0, 1);
    }

    void addWallHealth(float health) {
        wallHealth = constrain(wallHealth + health, 0, 1);
    }

    void subtractWallHealth(float health) {
        wallHealth = constrain(wallHealth - health, 0, 1);
    }


    // ################################################################################################################################################
    // energy level getters and setters
    // ################################################################################################################################################
    float getEnergyLevel() {
        return energyLevel;
    }

    void setEnergyLevel(float energy) {
        energyLevel = constrain(energy, 0, 1);
    }

    void addEnergyLevel(float energy) {
        energyLevel = constrain(energyLevel + energy, 0, 1);
    }

    void subtractEnergyLevel(float energy) {
        energyLevel = constrain(energyLevel - energy, 0, 1);
    }


    // ################################################################################################################################################
    // functions for the cell selection
    // ################################################################################################################################################
    boolean isSelected() {
        return bodyModel.getSelectedCell() == this;
    }

    CellModel getSelected() {
        return bodyModel.getSelectedCell();
    }

    void selectCell() {
        bodyModel.selectCell(this);
    }

    void unSelectCell() {
        bodyModel.unSelectCell(this);
    }
}
