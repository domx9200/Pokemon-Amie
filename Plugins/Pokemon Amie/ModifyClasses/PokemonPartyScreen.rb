class PokemonPartyScreen
  alias amiepbChoosePokemon pbChoosePokemon
  def pbChoosePokemon()
    ret = amiepbChoosePokemon()
    AmieMetaData.LastChosenPokemon = ret
    return ret
  end
end
