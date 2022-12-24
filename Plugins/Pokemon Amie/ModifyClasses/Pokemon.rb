class Pokemon
  alias AmieInitPokemon initialize
  def initialize(species, level, owner = $Trainer, withMoves = true, recheck_form = true, amieAffection = 0, amieHunger = 0, amieJoy = 0)
    AmieInitPokemon(species, level, owner, withMoves, recheck_form)
    @amieAffection = amieAffection
    @amieHunger = amieHunger
    @amieJoy = amieJoy
  end

  #-------------------------------DATA MANAGEMENT-----------------------
  def ensureAmieData()
    @amieAffection = 0 if @amieAffection == nil
    @amieHunger = 0 if @amieHunger == nil
    @amieJoy = 0 if @amieJoy == nil
  end

  def amieAffection()
    @amieAffection = 0 if @amieAffection == nil
    return @amieAffection
  end

  def amieHunger()
    @amieHunger = 0 if @amieHunger == nil
    return @amieHunger
  end

  def amieJoy()
    @amieJoy = 0 if @amieJoy == nil
    return @amieJoy
  end

  def amieAffection=(newAff)
    if newAff > AmieMetaData::AFFECTIONVALUES[1]
      newAff = AmieMetaData::AFFECTIONVALUES[1]
    elsif newAff < 0
      newAff = 0
    end
    @amieAffection = newAff
  end

  def amieHunger=(newHunger)
    if newHunger > AmieMetaData::HUNGERVALUES[1]
      newHunger = AmieMetaData::HUNGERVALUES[1]
    elsif newHunger < 0
      newHunger = 0
    end
    @amieHunger = newHunger
  end

  def amieJoy=(newEnjoy)
    if newEnjoy > AmieMetaData::JOYVALUES[1]
      newEnjoy = AmieMetaData::JOYVALUES[1]
    elsif newEnjoy < 0
      newEnjoy = 0
    end
    @amieJoy = newEnjoy
  end

  def resetAmieStats()
    @amieAffection = 0
    @amieHunger = 0
    @amieJoy = 0
  end

  #---------------------LEVEL FUNCTIONS------------------------------
  def getAmieLevel(type = :Affection)
    ensureAmieData()
    amieTypes = [
      :Hunger,
      :Joy,
      :Affection
    ]
    return if not amieTypes.include?(type)
    case type
    when :Affection
      return 0 if @amieAffection == 0
      return 5 if @amieAffection == AmieMetaData::AFFECTIONVALUES[1]
      level = (@amieAffection / AmieMetaData::AFFECTIONVALUES[0]).to_i + 1
      return level > 4 ? 4 : level
    when :Hunger
      return 0 if @amieHunger == 0
      return 5 if @amieHunger == AmieMetaData::HUNGERVALUES[1]
      level = (@amieHunger / AmieMetaData::HUNGERVALUES[0]).to_i + 1
      return level > 4 ? 4 : level
    when :Joy
      return 0 if @amieJoy == 0
      return 5 if @amieJoy == AmieMetaData::JOYVALUES[1]
      level = (@amieJoy / AmieMetaData::JOYVALUES[0]).to_i + 1
      return level > 4 ? 4 : level
    end
  end

  def getAffectionLevel()
    return getAmieLevel()
  end

  def getHungerLevel()
    return getAmieLevel(:Hunger)
  end

  def getJoyLevel()
    return getAmieLevel(:Joy)
  end

  #----------------------EXTRA FUNCTIONALITY----------------------------
  def changeAmieStatsOnItem(item)
    return if getHungerLevel() == 5
    isBerry = GameData::Item.get(item).is_berry?()
    berry = isBerry ? GameData::BerryPlant.get(item)[:hours_per_stage] : 3
    self.amieAffection += berry + rand(4)
    self.amieHunger += 90
  end
end
