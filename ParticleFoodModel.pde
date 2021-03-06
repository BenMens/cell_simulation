class ParticleFoodModel extends ParticleBaseModel {

    ParticleFoodModel(BodyModel bodyModel) {
        super(bodyModel);
    }
    ParticleFoodModel(BodyModel bodyModel, float positionX, float positionY) {
        super(bodyModel, positionX, positionY);
    }
    ParticleFoodModel(BodyModel bodyModel, float positionX, float positionY, float speedX, float speedY) {
        super(bodyModel, positionX, positionY, speedX, speedY);
    }


    String getImageName() {
        return "food";
    }

    String getTypeName() {
        return "food";
    }


    void onCellCollide(CellModel currendTouchedCell, CellModel previousTouchedCell) {
        if (previousTouchedCell != null) {
            previousTouchedCell.handleCollision(this);
        }

        if (currendTouchedCell != null) {
            currendTouchedCell.handleCollision(this);
        }

        setContainingCell(currendTouchedCell);

    }

}
