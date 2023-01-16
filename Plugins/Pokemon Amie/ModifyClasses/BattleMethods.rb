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

  def amieSurvive()
    return nil if !@pokemon
    return nil if @pokemon.getAffectionLevel() < 3
    val = AmieMetaData.calcSturdyChance(@pokemon.amieAffection)
    return nil if val == 0
    return val
  end

  alias amiepbConfusionDamage pbConfusionDamage
  def pbConfusionDamage(msg)
    amiepbConfusionDamage(msg)
    puts("huh?")
  end

  # alias amiepbFaint pbFaint
  # def pbFaint(showMessage=true)
  #   sturdyChance = amieSurvive()
  #   r = rand(100) / 100.0
  #   if sturdyChance != nil and r <= sturdyChance
  #     puts("is able to survive!")
  #     pbRecoverHP(1)
  #     @battle.pbDisplay(_INTL("{1} toughed it out so you wouldn't feel sad!", self.name))
  #   else
  #     amiepbFaint(showMessage)
  #   end
  # end
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
    amiepbCalcAccuracyModifiers(user, target, modifiers)
  end

  # The normal function for handling the sturdy effect
  alias amiepbInflictHPDamage pbInflictHPDamage
  def pbInflictHPDamage(target)
    amiepbInflictHPDamage(target)
    return if target.hp != 0
    sturdyChance = target.amieSurvive()
    r = rand(100) / 100.0
    if sturdyChance != nil and r <= sturdyChance
      @battle.pbDisplay(_INTL("{1} toughed it out so you wouldn't feel sad!", self.name))
      target.hp = 1
      target.damageState.hpLost -= 1
    end
  end

  # the function override for confusion damage, because for some reason it
  # doesn't use the same thing even though it's basically calc'd the same
  alias amiepbAnimateHitAndHPLost pbAnimateHitAndHPLost
  def pbAnimateHitAndHPLost(user, targets)
    if user == targets[0] and targets[0].hp == 0
      sturdyChance = targets[0].amieSurvive()
      r = rand(100) / 100.0
      if sturdyChance != nil and r <= sturdyChance
        @battle.pbDisplay(_INTL("{1} toughed it out so you wouldn't feel sad!", targets[0].name))
        targets[0].hp = 1
        targets[0].damageState.hpLost -= 1
      end
    end
    amiepbAnimateHitAndHPLost(user, targets)
  end

  # Returns whether the move will be a critical hit.
  # might try and change this into a mixin to prevent compatability issues
  # for now this works
  def pbIsCritical?(user,target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
    # Set up the critical hit ratios
    ratios = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? [24,8,2,1] : [16,8,4,3,2]
    if user.pokemon.getAffectionLevel() == 5
      for i in 0...ratios.length
        ratios[i] = ratios[i] * AmieMetaData::CRITCHANCE
      end
    end
    c = 0
    # Ability effects that alter critical hit rate
    if c>=0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
    end
    if c>=0 && target.abilityActive? && !@battle.moldBreaker
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
    end
    # Item effects that alter critical hit rate
    if c>=0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
    end
    if c>=0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
    end
    return false if c<0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user,target)
    when 1  then return true
    when -1 then return false
    end
    # Other effects
    return true if c>50   # Merciless
    return true if user.effects[PBEffects::LaserFocus]>0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    c = ratios.length-1 if c>=ratios.length
    # Calculation
    return @battle.pbRandom(ratios[c])==0
  end
end
