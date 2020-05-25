interface CodonModelParent {
    void addCodon(CodonBaseModel codonModel);

    void removeCodon(CodonBaseModel codonModel);


    ArrayList<CodonBaseModel> getCodonList();


    PVector getPosition();


    float getWallHealth();

    void setWallHealth(float health);

    void addWallHealth(float health);

    void subtractWallHealth(float health);


    float getEnergyLevel();

    void setEnergyLevel(float energy);

    void addEnergyLevel(float energy);

    void subtractEnergyLevel(float energy);
}
