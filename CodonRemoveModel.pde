class CodonRemoveModel extends CodonBaseModel {
    int removeCodonsFirstPoint = floor(random(5) - 2);
    int removeCodonsSecondPoint = floor(random(5) - 2);


    CodonRemoveModel(CodonModelParent parentModel) {
        super(parentModel);

        mainColor = color(255, 190, 35);
        possibleCodonParameters.add("none");
        possibleCodonParameters.add("wall");
        possibleCodonParameters.add("energy");
        possibleCodonParameters.add("codons");
    }


    float getEnergyCost() {
        switch (codonParameter) {
            case "wall" :
                if (parentModel.getIsExecuteHandPointingOutward()) {
                    return baseEnergyCost;
                } else {
                    return 0;
                }
            case "energy" :
                if (parentModel.getIsExecuteHandPointingOutward()) {
                    return 0;
                } else {
                    return baseEnergyCost;
                }
            case "codons" :
                if (parentModel.getIsExecuteHandPointingOutward()) {
                    return 0;
                } else {
                    ArrayList<CodonBaseModel> codonList = parentModel.getCodonList();
                    return baseEnergyCost + baseEnergyCost * min(abs(removeCodonsFirstPoint - removeCodonsSecondPoint), codonList.size());
                }
        }

        return 0;
    }


    void executeCodon() {
        switch (codonParameter) {
            case "wall":
                if (parentModel.getIsExecuteHandPointingOutward()) {
                    parentModel.setWallHealth(0);
                }
                break;
            case "energy":
                if (!parentModel.getIsExecuteHandPointingOutward()) {
                    parentModel.setEnergyLevel(0);
                }
                break;
            case "codons":
                if (!parentModel.getIsExecuteHandPointingOutward()) {
                    ArrayList<CodonBaseModel> codonList = parentModel.getCodonList();
                    int index = parentModel.getExecuteHandPosition();
                    for (int i = index + min(removeCodonsFirstPoint, removeCodonsSecondPoint); i <= index + max(removeCodonsFirstPoint, removeCodonsSecondPoint); i++) {
                        codonList.get(abs(i % codonList.size())).isDead = true;
                    }
                }
                break;
        }
        parentModel.subtractEnergyLevel(getEnergyCost());
    }


    String getDisplayName() {
        return "remove";
    };
}
