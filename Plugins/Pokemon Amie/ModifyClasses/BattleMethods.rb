# when a battle happens, reduce all party pokemon's fullness and joy by 25
alias amiepbTrainerBattleCore pbTrainerBattleCore
def pbTrainerBattleCore(*args)
  ret = amiepbTrainerBattleCore(*args)
  for pkmn in $Trainer.party
    pkmn.amieHunger -= 25
    pkmn.amieJoy -= 25
  end
  return ret
end

# when a battle happens, reduce all party pokemon's fullness and joy by 25
alias amiepbWildBattleCore pbWildBattleCore
def pbWildBattleCore(*args)
  ret = amiepbWildBattleCore(*args)
  for pkmn in $Trainer.party
    pkmn.amieHunger -= 25
    pkmn.amieJoy -= 25
  end
  return ret
end

class PokeBattle_Battle
  # mixin to handle the end of turn detoxify
  alias amieAttackPhase pbAttackPhase
  def pbAttackPhase()
    amieAttackPhase()
    return if @decision > 0
    for pkmn in @battlers
      next if not pbOwnedByPlayer?(pkmn)
      pkmn.amieRestoreStatus()
    end
  end

  # mixin to add the xp bonus from affection.
  # this bonus is silent because of the way the normal xp function runs
  # I'd have to effectively copy-paste the function to get it to work while showing
  # a different message
  alias amiepbGainExpOne pbGainExpOne
  def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    AmieMetaData.battlePokemon = pbParty(0)[idxParty]
    amiepbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages)
    AmieMetaData.battlePokemon = nil
  end
end

class PokeBattle_Battler
  # extra function for PokeBattle_Battler to check for the status removal
  def amieRestoreStatus()
    return if !@pokemon
    return if @pokemon.getAffectionLevel() < 4
    return if self.status == :NONE
    r = rand(100) / 100.0
    if r <= AmieMetaData::STATUSCHANCE
      @battle.pbDisplay(_INTL("{1} has shaken off it's status!", self.name))
      self.status = :NONE
    end
  end
end

class PokeBattle_Move
  # mixin to modify the accuracy of moves targeting players pokemon to reduce the chance of hitting
  # doesn't have any message relating to the extra dodge chance, related to how the functions interact with each other
  alias amiepbCalcAccuracyModifiers pbCalcAccuracyModifiers
  def pbCalcAccuracyModifiers(user, target, modifiers)
    if target.pbOwnedByPlayer?() and target.pokemon.getAffectionLevel >= 4
      modifiers[:base_accuracy] -= AmieMetaData::ACCREDUCTION
      modifiers[:base_accuracy] = 1 if modifiers[:base_accuracy] == 0
    end
    puts modifiers[:base_accuracy]
    amiepbCalcAccuracyModifiers(user, target, modifiers)
  end
end
