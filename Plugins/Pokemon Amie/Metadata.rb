module AmieMetaData
  EDIBLEITEMS = [
    :LAVACOOKIE,
    :OLDGATEAU,
    :CASTELIACONE,
    :RAGECANDYBAR,
    :SWEETHEART,
    :LUMIOSEGALETTE,
    :BIGMALASADA,
    :SHALOURSABLE,
    :PEWTERCRUNCHIES,
    :RARECANDY,
    :FRESHWATER,
    :SODAPOP,
    :LEMONADE,
    :MOOMOOMILK,
    :ENERGYPOWDER,
    :ENERGYROOT,
    :HEALPOWDER,
    :REVIVALHERB,
    :BERRYJUICE,
    :CHERIBERRY,
    :CHESTOBERRY,
    :PECHABERRY,
    :RAWSTBERRY,
    :ASPEARBERRY,
    :ORANBERRY,
    :PERSIMBERRY,
    :LUMBERRY,
    :SITRUSBERRY,
    :FIGYBERRY,
    :WIKIBERRY,
    :MAGOBERRY,
    :AGUAVBERRY,
    :IAPAPABERRY,
    :RAZZBERRY,
    :BLUKBERRY,
    :NANABBERRY,
    :WEPEARBERRY,
    :PINAPBERRY,
    :POMEGBERRY,
    :KELPSYBERRY,
    :QUALOTBERRY,
    :HONDEWBERRY,
    :GREPABERRY,
    :TAMATOBERRY,
    :CORNNBERRY,
    :MAGOSTBERRY,
    :RABUTABERRY,
    :NOMELBERRY,
    :SPELONBERRY,
    :PAMTREBERRY,
    :WATMELBERRY,
    :DURINBERRY,
    :BELUEBERRY,
    :OCCABERRY,
    :PASSHOBERRY,
    :WACANBERRY,
    :RINDOBERRY,
    :YACHEBERRY,
    :CHOPLEBERRY,
    :KEBIABERRY,
    :SHUCABERRY,
    :COBABERRY,
    :PAYAPABERRY,
    :TANGABERRY,
    :CHARTIBERRY,
    :KASIBBERRY,
    :HABANBERRY,
    :COLBURBERRY,
    :BABIRIBERRY,
    :CHILANBERRY,
    :LIECHIBERRY,
    :GANLONBERRY,
    :SALACBERRY,
    :PETAYABERRY,
    :APICOTBERRY,
    :LANSATBERRY,
    :STARFBERRY,
    :ENIGMABERRY,
    :MICLEBERRY,
    :CUSTAPBERRY,
    :JABOCABERRY,
    :ROWAPBERRY,
    :ROSELIBERRY,
    :KEEBERRY,
    :MARANGABERRY,
    :MOOMOOCHEESE,
    :SMOKEPOKETAIL
  ]

  # the first value represents the scalar used to calculate the level of affection
  # the second value represents the max affection value
  AFFECTIONVALUES = [50, 255]

  # the first value represents the scalar used to calculate the level of hunger
  # the second value represents the max hunger value
  HUNGERVALUES = [50, 255]

  # the first value represents the scalar used to calculate the level of enjoyment
  # the second value represents the max enjoyment value
  JOYVALUES = [50, 255]

  # Represents the chance the Pokemon will shake off a status
  STATUSCHANCE = 0.2

  # Represents the crit chance of a move
  # Note: this is added on top of the normal crit chance, 1 doubles it's chance
  CRITCHANCE = 1

  # Represents the extra XP modifier the pokemon will get post battle
  # Note: this is added on top of the normal xp gained, setting this to 1 will double the xp gained
  XPBONUS = 0.2

  # Represents the modification to the accuracy of moves, by default all moves are 10 acc less
  ACCREDUCTION = 10

  # Represents the chance to survive at 1 hp
  # the rate changes based on level, being, by default,
  # 0.1 at level 3
  # 0.15 at level 4
  # 0.2 at affection total half way from level 4 and 5
  # 0.25 at level 5
  STURDYCHANCE = [0.1, 0.15, 0.2, 0.25]

  @LastChosenPokemon = -1
  @battlePokemon = nil
  @stepsTaken = 0

  def self.LastChosenPokemon=(value)
    @LastChosenPokemon = value
  end

  def self.LastChosenPokemon()
    return @LastChosenPokemon
  end

  def self.battlePokemon=(value)
    @battlePokemon = value
  end

  def self.battlePokemon()
    return @battlePokemon
  end

  def self.stepsTaken=(value)
    @stepsTaken = value
  end

  def self.stepsTaken()
    return @stepsTaken
  end
end

Events.onStepTaken += proc {
  AmieMetaData.stepsTaken += 1
  if AmieMetaData.stepsTaken >= 50
    for pkmn in $Trainer.party
      pkmn.amieHunger -= 1
      pkmn.amieJoy -= 1
    end
    AmieMetaData.stepsTaken = 0
  end
}
