alias amiepbUseItem pbUseItem
def pbUseItem(bag, item, bagscene=nil)
  ret = amiepbUseItem(bag, item, bagscene)
  if ret == 1
    isEdible = AmieMetaData::EDIBLEITEMS.include?(item)
    if isEdible
      pkm = $Trainer.party[AmieMetaData.LastChosenPokemon]
      pkm.changeAmieStatsOnItem(item)
    end
  end
  return ret
end

alias amiepbUseItemOnPokemon pbUseItemOnPokemon
def pbUseItemOnPokemon(item, pkmn, scene)
  ret = amiepbUseItemOnPokemon(item, pkmn, scene)
  if ret = 1
    isEdible = AmieMetaData::EDIBLEITEMS.include?(item)
    if isEdible
      pkmn.changeAmieStatsOnItem(item)
    end
  end
  return ret
end
