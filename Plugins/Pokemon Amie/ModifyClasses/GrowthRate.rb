module GameData
  class GrowthRate
    alias amieAddExp add_exp
    def add_exp(pkmnExp, addExp)
      pkmn = AmieMetaData.battlePokemon
      bonus = (pkmn != nil and pkmn.getAffectionLevel >= 2) ? 1 + AmieMetaData::XPBONUS : 1.0
      newXPAdd = (addExp * bonus).floor
      return amieAddExp(pkmnExp, newXPAdd)
    end
  end
end
