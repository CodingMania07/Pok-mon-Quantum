#===============================================================================
# Field options
#===============================================================================
MenuHandlers.register(:debug_menu, "field_menu", {
  "parent"      => "main",
  "name"        => _INTL("Field options..."),
  "description" => _INTL("Warp to maps, edit switches/variables, use the PC, edit Day Care, etc.")
})

MenuHandlers.register(:debug_menu, "warp", {
  "parent"      => "field_menu",
  "name"        => _INTL("Warp to Map"),
  "description" => _INTL("Instantly warp to another map of your choice."),
  "effect"      => proc { |sprites, viewport|
    map = pbWarpToMap
    if map
      pbFadeOutAndHide(sprites)
      pbDisposeMessageWindow(sprites["textbox"])
      pbDisposeSpriteHash(sprites)
      viewport.dispose
      if $scene.is_a?(Scene_Map)
        $game_temp.player_new_map_id    = map[0]
        $game_temp.player_new_x         = map[1]
        $game_temp.player_new_y         = map[2]
        $game_temp.player_new_direction = 2
        $scene.transfer_player
      else
        pbCancelVehicles
        $map_factory.setup(map[0])
        $game_player.moveto(map[1], map[2])
        $game_player.turn_down
        $game_map.update
        $game_map.autoplay
      end
      $game_map.refresh
      next true   # Closes the debug menu to allow the warp
    end
  }
})

MenuHandlers.register(:debug_menu, "refresh_map", {
  "parent"      => "field_menu",
  "name"        => _INTL("Refresh Map"),
  "description" => _INTL("Make all events on this map, and common events, refresh themselves."),
  "effect"      => proc {
    $game_map.need_refresh = true
    pbMessage(_INTL("The map will refresh."))
  }
})

MenuHandlers.register(:debug_menu, "switches", {
  "parent"      => "field_menu",
  "name"        => _INTL("Switches"),
  "description" => _INTL("Edit all Game Switches (except Script Switches)."),
  "effect"      => proc {
    pbDebugVariables(0)
  }
})

MenuHandlers.register(:debug_menu, "variables", {
  "parent"      => "field_menu",
  "name"        => _INTL("Variables"),
  "description" => _INTL("Edit all Game Variables. Can set them to numbers or text."),
  "effect"      => proc {
    pbDebugVariables(1)
  }
})

MenuHandlers.register(:debug_menu, "use_pc", {
  "parent"      => "field_menu",
  "name"        => _INTL("Use PC"),
  "description" => _INTL("Use a PC to access Pokémon storage and player's PC."),
  "effect"      => proc {
    pbPokeCenterPC
  }
})

MenuHandlers.register(:debug_menu, "toggle_wallpapers", {
  "parent"      => "field_menu",
  "name"        => _INTL("Toggle Storage Wallpapers"),
  "description" => _INTL("Unlock and lock special wallpapers used in Pokémon storage."),
  "effect"      => proc {
    w = $PokemonStorage.allWallpapers
    if w.length <= PokemonStorage::BASICWALLPAPERQTY
      pbMessage(_INTL("There are no special wallpapers defined."))
    else
      paperscmd = 0
      unlockarray = $PokemonStorage.unlockedWallpapers
      loop do
        paperscmds = []
        paperscmds.push(_INTL("Unlock all"))
        paperscmds.push(_INTL("Lock all"))
        (PokemonStorage::BASICWALLPAPERQTY...w.length).each do |i|
          paperscmds.push(_INTL("{1} {2}", unlockarray[i] ? "[Y]" : "[  ]", w[i]))
        end
        paperscmd = pbShowCommands(nil, paperscmds, -1, paperscmd)
        break if paperscmd < 0
        case paperscmd
        when 0   # Unlock all
          (PokemonStorage::BASICWALLPAPERQTY...w.length).each do |i|
            unlockarray[i] = true
          end
        when 1   # Lock all
          (PokemonStorage::BASICWALLPAPERQTY...w.length).each do |i|
            unlockarray[i] = false
          end
        else
          paperindex = paperscmd - 2 + PokemonStorage::BASICWALLPAPERQTY
          unlockarray[paperindex] = !$PokemonStorage.unlockedWallpapers[paperindex]
        end
      end
    end
  }
})

MenuHandlers.register(:debug_menu, "day_care", {
  "parent"      => "field_menu",
  "name"        => _INTL("Day Care"),
  "description" => _INTL("View Pokémon in the Day Care and edit them."),
  "effect"      => proc {
    pbDebugDayCare
  }
})

MenuHandlers.register(:debug_menu, "skip_credits", {
  "parent"      => "field_menu",
  "name"        => _INTL("Skip Credits"),
  "description" => _INTL("Toggle whether credits can be ended early by pressing the Use input."),
  "effect"      => proc {
    $PokemonGlobal.creditsPlayed = !$PokemonGlobal.creditsPlayed
    pbMessage(_INTL("Credits can be skipped when played in future.")) if $PokemonGlobal.creditsPlayed
    pbMessage(_INTL("Credits cannot be skipped when next played.")) if !$PokemonGlobal.creditsPlayed
  }
})

MenuHandlers.register(:debug_menu, "relic_stone", {
  "parent"      => "field_menu",
  "name"        => _INTL("Use Relic Stone"),
  "description" => _INTL("Shadow Pokémon. Choose a Pokémon to show to the Relic Stone for purification."),
  "effect"      => proc {
    pbRelicStone
  }
})

MenuHandlers.register(:debug_menu, "purify_chamber", {
  "parent"      => "field_menu",
  "name"        => _INTL("Use Purify Chamber"),
  "description" => _INTL("Shadow Pokémon. Open the Purify Chamber for purification."),
  "effect"      => proc {
    pbPurifyChamber
  }
})

#===============================================================================
# Battle options
#===============================================================================
MenuHandlers.register(:debug_menu, "battle_menu", {
  "parent"      => "main",
  "name"        => _INTL("Battle options..."),
  "description" => _INTL("Start battles, reset this map's trainers, ready rematches, edit roamers, etc.")
})

MenuHandlers.register(:debug_menu, "test_wild_battle", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Test Wild Battle"),
  "description" => _INTL("Start a single battle against a wild Pokémon. You choose the species/level."),
  "effect"      => proc {
    species = pbChooseSpeciesList
    if species
      params = ChooseNumberParams.new
      params.setRange(1, GameData::GrowthRate.max_level)
      params.setInitialValue(5)
      params.setCancelValue(0)
      level = pbMessageChooseNumber(_INTL("Set the wild {1}'s level.",
                                          GameData::Species.get(species).name), params)
      if level > 0
        $game_temp.encounter_type = nil
        pbWildBattle(species, level)
      end
    end
    next false
  }
})

MenuHandlers.register(:debug_menu, "test_wild_battle_advanced", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Test Wild Battle Advanced"),
  "description" => _INTL("Start a battle against 1 or more wild Pokémon. Battle size is your choice."),
  "effect"      => proc {
    pkmn = []
    size0 = 1
    pkmnCmd = 0
    loop do
      pkmnCmds = []
      pkmn.each { |p| pkmnCmds.push(sprintf("%s Lv.%d", p.name, p.level)) }
      pkmnCmds.push(_INTL("[Add Pokémon]"))
      pkmnCmds.push(_INTL("[Set player side size]"))
      pkmnCmds.push(_INTL("[Start {1}v{2} battle]", size0, pkmn.length))
      pkmnCmd = pbShowCommands(nil, pkmnCmds, -1, pkmnCmd)
      break if pkmnCmd < 0
      if pkmnCmd == pkmnCmds.length - 1      # Start battle
        if pkmn.length == 0
          pbMessage(_INTL("No Pokémon were chosen, cannot start battle."))
          next
        end
        setBattleRule(sprintf("%dv%d", size0, pkmn.length))
        $game_temp.encounter_type = nil
        pbWildBattleCore(*pkmn)
        break
      elsif pkmnCmd == pkmnCmds.length - 2   # Set player side size
        if !pbCanDoubleBattle?
          pbMessage(_INTL("You only have one Pokémon."))
          next
        end
        maxVal = (pbCanTripleBattle?) ? 3 : 2
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size0)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
          _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params
        )
        size0 = newSize if newSize > 0
      elsif pkmnCmd == pkmnCmds.length - 3   # Add Pokémon
        species = pbChooseSpeciesList
        if species
          params = ChooseNumberParams.new
          params.setRange(1, GameData::GrowthRate.max_level)
          params.setInitialValue(5)
          params.setCancelValue(0)
          level = pbMessageChooseNumber(_INTL("Set the wild {1}'s level.",
                                              GameData::Species.get(species).name), params)
          pkmn.push(Pokemon.new(species, level)) if level > 0
        end
      else                                   # Edit a Pokémon
        if pbConfirmMessage(_INTL("Change this Pokémon?"))
          scr = PokemonDebugPartyScreen.new
          scr.pbPokemonDebug(pkmn[pkmnCmd], -1, nil, true)
          scr.pbEndScreen
        elsif pbConfirmMessage(_INTL("Delete this Pokémon?"))
          pkmn.delete_at(pkmnCmd)
        end
      end
    end
    next false
  }
})

MenuHandlers.register(:debug_menu, "test_trainer_battle", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Test Trainer Battle"),
  "description" => _INTL("Start a single battle against a trainer of your choice."),
  "effect"      => proc {
    trainerdata = pbListScreen(_INTL("SINGLE TRAINER"), TrainerBattleLister.new(0, false))
    if trainerdata
      pbTrainerBattle(trainerdata[0], trainerdata[1], nil, false, trainerdata[2], true)
    end
    next false
  }
})

MenuHandlers.register(:debug_menu, "test_trainer_battle_advanced", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Test Trainer Battle Advanced"),
  "description" => _INTL("Start a battle against 1 or more trainers with a battle size of your choice."),
  "effect"      => proc {
    trainers = []
    size0 = 1
    size1 = 1
    trainerCmd = 0
    loop do
      trainerCmds = []
      trainers.each { |t| trainerCmds.push(sprintf("%s x%d", t[1].full_name, t[1].party_count)) }
      trainerCmds.push(_INTL("[Add trainer]"))
      trainerCmds.push(_INTL("[Set player side size]"))
      trainerCmds.push(_INTL("[Set opponent side size]"))
      trainerCmds.push(_INTL("[Start {1}v{2} battle]", size0, size1))
      trainerCmd = pbShowCommands(nil, trainerCmds, -1, trainerCmd)
      break if trainerCmd < 0
      if trainerCmd == trainerCmds.length - 1      # Start battle
        if trainers.length == 0
          pbMessage(_INTL("No trainers were chosen, cannot start battle."))
          next
        elsif size1 < trainers.length
          pbMessage(_INTL("Opposing side size is invalid. It should be at least {1}.", trainers.length))
          next
        elsif size1 > trainers.length && trainers[0][1].party_count == 1
          pbMessage(
            _INTL("Opposing side size cannot be {1}, as that requires the first trainer to have 2 or more Pokémon, which they don't.",
                  size1)
          )
          next
        end
        setBattleRule(sprintf("%dv%d", size0, size1))
        battleArgs = []
        trainers.each { |t| battleArgs.push(t[1]) }
        pbTrainerBattleCore(*battleArgs)
        break
      elsif trainerCmd == trainerCmds.length - 2   # Set opponent side size
        if trainers.length == 0 || (trainers.length == 1 && trainers[0][1].party_count == 1)
          pbMessage(_INTL("No trainers were chosen or trainer only has one Pokémon."))
          next
        end
        maxVal = 2
        maxVal = 3 if trainers.length >= 3 ||
                      (trainers.length == 2 && trainers[0][1].party_count >= 2) ||
                      trainers[0][1].party_count >= 3
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size1)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
          _INTL("Choose the number of battlers on the opponent's side (max. {1}).", maxVal), params
        )
        size1 = newSize if newSize > 0
      elsif trainerCmd == trainerCmds.length - 3   # Set player side size
        if !pbCanDoubleBattle?
          pbMessage(_INTL("You only have one Pokémon."))
          next
        end
        maxVal = (pbCanTripleBattle?) ? 3 : 2
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size0)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
          _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params
        )
        size0 = newSize if newSize > 0
      elsif trainerCmd == trainerCmds.length - 4   # Add trainer
        trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"), TrainerBattleLister.new(0, false))
        if trainerdata
          tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
          trainers.push([0, tr])
        end
      else                                         # Edit a trainer
        if pbConfirmMessage(_INTL("Change this trainer?"))
          trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"),
                                     TrainerBattleLister.new(trainers[trainerCmd][0], false))
          if trainerdata
            tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
            trainers[trainerCmd] = [0, tr]
          end
        elsif pbConfirmMessage(_INTL("Delete this trainer?"))
          trainers.delete_at(trainerCmd)
        end
      end
    end
    next false
  }
})

MenuHandlers.register(:debug_menu, "toggle_logging", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Toggle Battle Logging"),
  "description" => _INTL("Record debug logs for battles in Data/debuglog.txt."),
  "effect"      => proc {
    $INTERNAL = !$INTERNAL
    pbMessage(_INTL("Debug logs for battles will be made in the Data folder.")) if $INTERNAL
    pbMessage(_INTL("Debug logs for battles will not be made.")) if !$INTERNAL
  }
})

MenuHandlers.register(:debug_menu, "reset_trainers", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Reset Map's Trainers"),
  "description" => _INTL("Turn off Self Switches A and B for all events with \"Trainer\" in their name."),
  "effect"      => proc {
    if $game_map
      $game_map.events.values.each do |event|
        if event.name[/trainer/i]
          $game_self_switches[[$game_map.map_id, event.id, "A"]] = false
          $game_self_switches[[$game_map.map_id, event.id, "B"]] = false
        end
      end
      $game_map.need_refresh = true
      pbMessage(_INTL("All Trainers on this map were reset."))
    else
      pbMessage(_INTL("This command can't be used here."))
    end
  }
})

MenuHandlers.register(:debug_menu, "ready_rematches", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Ready All Phone Rematches"),
  "description" => _INTL("Make all trainers in the phone ready for rematches."),
  "effect"      => proc {
    if !$PokemonGlobal.phoneNumbers || $PokemonGlobal.phoneNumbers.length == 0
      pbMessage(_INTL("There are no trainers in the Phone."))
    else
      $PokemonGlobal.phoneNumbers.each do |i|
        next if i.length != 8   # Isn't a trainer with an event
        i[4] = 2
        pbSetReadyToBattle(i)
      end
      pbMessage(_INTL("All trainers in the Phone are now ready to rebattle."))
    end
  }
})

MenuHandlers.register(:debug_menu, "roamers", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Roaming Pokémon"),
  "description" => _INTL("Toggle and edit all roaming Pokémon."),
  "effect"      => proc {
    pbDebugRoamers
  }
})

MenuHandlers.register(:debug_menu, "encounter_version", {
  "parent"      => "battle_menu",
  "name"        => _INTL("Set Encounters Version"),
  "description" => _INTL("Choose which version of wild encounters should be used."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, 99)
    params.setInitialValue($PokemonGlobal.encounter_version)
    params.setCancelValue(-1)
    value = pbMessageChooseNumber(_INTL("Set encounters version to which value?"), params)
    if value >= 0
      $PokemonGlobal.encounter_version = value
    end
  }
})

#===============================================================================
# Item options
#===============================================================================
MenuHandlers.register(:debug_menu, "items_menu", {
  "parent"      => "main",
  "name"        => _INTL("Item options..."),
  "description" => _INTL("Give and take items.")
})

MenuHandlers.register(:debug_menu, "add_item", {
  "parent"      => "items_menu",
  "name"        => _INTL("Add Item"),
  "description" => _INTL("Choose an item and a quantity of it to add to the Bag."),
  "effect"      => proc {
    pbListScreenBlock(_INTL("ADD ITEM"), ItemLister.new) { |button, item|
      if button == Input::USE && item
        params = ChooseNumberParams.new
        params.setRange(1, Settings::BAG_MAX_PER_SLOT)
        params.setInitialValue(1)
        params.setCancelValue(0)
        qty = pbMessageChooseNumber(_INTL("Add how many {1}?",
                                          GameData::Item.get(item).name_plural), params)
        if qty > 0
          $bag.add(item, qty)
          pbMessage(_INTL("Gave {1}x {2}.", qty, GameData::Item.get(item).name))
        end
      end
    }
  }
})

MenuHandlers.register(:debug_menu, "fill_bag", {
  "parent"      => "items_menu",
  "name"        => _INTL("Fill Bag"),
  "description" => _INTL("Empties the Bag and then fills it with a certain number of every item."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(1, Settings::BAG_MAX_PER_SLOT)
    params.setInitialValue(1)
    params.setCancelValue(0)
    qty = pbMessageChooseNumber(_INTL("Choose the number of items."), params)
    if qty > 0
      $bag.clear
      # NOTE: This doesn't simply use $bag.add for every item in turn, because
      #       that's really slow when done in bulk.
      pocket_sizes = Settings::BAG_MAX_POCKET_SIZE
      bag = $bag.pockets   # Called here so that it only rearranges itself once
      GameData::Item.each do |i|
        next if !pocket_sizes[i.pocket - 1] || pocket_sizes[i.pocket - 1] == 0
        next if pocket_sizes[i.pocket - 1] > 0 && bag[i.pocket].length >= pocket_sizes[i.pocket - 1]
        item_qty = (i.is_important?) ? 1 : qty
        bag[i.pocket].push([i.id, item_qty])
      end
      # NOTE: Auto-sorting pockets don't need to be sorted afterwards, because
      #       items are added in the same order they would be sorted into.
      pbMessage(_INTL("The Bag was filled with {1} of each item.", qty))
    end
  }
})

MenuHandlers.register(:debug_menu, "empty_bag", {
  "parent"      => "items_menu",
  "name"        => _INTL("Empty Bag"),
  "description" => _INTL("Remove all items from the Bag."),
  "effect"      => proc {
    $bag.clear
    pbMessage(_INTL("The Bag was cleared."))
  }
})

#===============================================================================
# Pokémon options
#===============================================================================
MenuHandlers.register(:debug_menu, "pokemon_menu", {
  "parent"      => "main",
  "name"        => _INTL("Pokémon options..."),
  "description" => _INTL("Give Pokémon, heal party, fill/empty PC storage, etc.")
})

MenuHandlers.register(:debug_menu, "add_pokemon", {
  "parent"      => "pokemon_menu",
  "name"        => _INTL("Add Pokémon"),
  "description" => _INTL("Give yourself a Pokémon of a chosen species/level. Goes to PC if party is full."),
  "effect"      => proc {
    species = pbChooseSpeciesList
    if species
      params = ChooseNumberParams.new
      params.setRange(1, GameData::GrowthRate.max_level)
      params.setInitialValue(5)
      params.setCancelValue(0)
      level = pbMessageChooseNumber(_INTL("Set the Pokémon's level."), params)
      pbAddPokemon(species, level) if level > 0
    end
  }
})

MenuHandlers.register(:debug_menu, "give_demo_party", {
  "parent"      => "pokemon_menu",
  "name"        => _INTL("Give Demo Party"),
  "description" => _INTL("Give yourself 6 preset Pokémon. They overwrite the current party."),
  "effect"      => proc {
    party = []
    species = [:PIKACHU, :PIDGEOTTO, :KADABRA, :GYARADOS, :DIGLETT, :CHANSEY]
    species.each do |id|
      party.push(id) if GameData::Species.exists?(id)
    end
    $player.party.clear
    # Generate Pokémon of each species at level 20
    party.each do |species|
      pkmn = Pokemon.new(species, 20)
      $player.party.push(pkmn)
      $player.pokedex.register(pkmn)
      $player.pokedex.set_owned(species)
      case species
      when :PIDGEOTTO
        pkmn.learn_move(:FLY)
      when :KADABRA
        pkmn.learn_move(:FLASH)
        pkmn.learn_move(:TELEPORT)
      when :GYARADOS
        pkmn.learn_move(:SURF)
        pkmn.learn_move(:DIVE)
        pkmn.learn_move(:WATERFALL)
      when :DIGLETT
        pkmn.learn_move(:DIG)
        pkmn.learn_move(:CUT)
        pkmn.learn_move(:HEADBUTT)
        pkmn.learn_move(:ROCKSMASH)
      when :CHANSEY
        pkmn.learn_move(:SOFTBOILED)
        pkmn.learn_move(:STRENGTH)
        pkmn.learn_move(:SWEETSCENT)
      end
      pkmn.record_first_moves
    end
    pbMessage(_INTL("Filled party with demo Pokémon."))
  }
})

MenuHandlers.register(:debug_menu, "heal_party", {
  "parent"      => "pokemon_menu",
  "name"        => _INTL("Heal Party"),
  "description" => _INTL("Fully heal the HP/status/PP of all Pokémon in the party."),
  "effect"      => proc {
    $player.party.each { |pkmn| pkmn.heal }
    pbMessage(_INTL("Your Pokémon were fully healed."))
  }
})

MenuHandlers.register(:debug_menu, "quick_hatch_party_eggs", {
  "parent"      => "pokemon_menu",
  "name"        => _INTL("Quick Hatch"),
  "description" => _INTL("Make all eggs in the party require just one more step to hatch."),
  "effect"      => proc {
    $player.party.each { |pkmn| pkmn.steps_to_hatch = 1 if pkmn.egg? }
    pbMessage(_INTL("All eggs in your party now require one step to hatch."))
  }
})

MenuHandlers.register(:debug_menu, "fill_boxes", {
  "parent"      => "pokemon_menu",
  "name"        => _INTL("Fill Storage Boxes"),
  "description" => _INTL("Add one Pokémon of each species (at Level 50) to storage."),
  "effect"      => proc {
    added = 0
    box_qty = $PokemonStorage.maxPokemon(0)
    completed = true
    GameData::Species.each do |species_data|
      sp = species_data.species
      f = species_data.form
      # Record each form of each species as seen and owned
      if f == 0
        if species_data.single_gendered?
          g = (species_data.gender_ratio == :AlwaysFemale) ? 1 : 0
          $player.pokedex.register(sp, g, f, 0, false)
          $player.pokedex.register(sp, g, f, 1, false)
        else   # Both male and female
          $player.pokedex.register(sp, 0, f, 0, false)
          $player.pokedex.register(sp, 0, f, 1, false)
          $player.pokedex.register(sp, 1, f, 0, false)
          $player.pokedex.register(sp, 1, f, 1, false)
        end
        $player.pokedex.set_owned(sp, false)
      elsif species_data.real_form_name && !species_data.real_form_name.empty?
        g = (species_data.gender_ratio == :AlwaysFemale) ? 1 : 0
        $player.pokedex.register(sp, g, f, 0, false)
        $player.pokedex.register(sp, g, f, 1, false)
      end
      # Add Pokémon (if form 0, i.e. one of each species)
      next if f != 0
      if added >= Settings::NUM_STORAGE_BOXES * box_qty
        completed = false
        next
      end
      added += 1
      $PokemonStorage[(added - 1) / box_qty, (added - 1) % box_qty] = Pokemon.new(sp, 50)
    end
    $player.pokedex.refresh_accessible_dexes
    pbMessage(_INTL("Storage boxes were filled with one Pokémon of each species."))
    if !completed
      pbMessage(_INTL("Note: The number of storage spaces ({1} boxes of {2}) is less than the number of species.",
                      Settings::NUM_STORAGE_BOXES, box_qty))
    end
  }
})

MenuHandlers.register(:debug_menu, "clear_boxes", {
  "parent"      => "pokemon_menu",
  "name"        => _INTL("Clear Storage Boxes"),
  "description" => _INTL("Remove all Pokémon in storage."),
  "effect"      => proc {
    $PokemonStorage.maxBoxes.times do |i|
      $PokemonStorage.maxPokemon(i).times do |j|
        $PokemonStorage[i, j] = nil
      end
    end
    pbMessage(_INTL("The storage boxes were cleared."))
  }
})

MenuHandlers.register(:debug_menu, "open_storage", {
  "parent"      => "pokemon_menu",
  "name"        => _INTL("Access Pokémon Storage"),
  "description" => _INTL("Opens the Pokémon storage boxes in Organize Boxes mode."),
  "effect"      => proc {
    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0)
    }
  }
})

#===============================================================================
# Player options
#===============================================================================
MenuHandlers.register(:debug_menu, "player_menu", {
  "parent"      => "main",
  "name"        => _INTL("Player options..."),
  "description" => _INTL("Set money, badges, Pokédexes, player's appearance and name, etc.")
})

MenuHandlers.register(:debug_menu, "set_badges", {
  "parent"      => "player_menu",
  "name"        => _INTL("Set Badges"),
  "description" => _INTL("Toggle possession of each Gym Badge."),
  "effect"      => proc {
    badgecmd = 0
    loop do
      badgecmds = []
      badgecmds.push(_INTL("Give all"))
      badgecmds.push(_INTL("Remove all"))
      24.times do |i|
        badgecmds.push(_INTL("{1} Badge {2}", $player.badges[i] ? "[Y]" : "[  ]", i + 1))
      end
      badgecmd = pbShowCommands(nil, badgecmds, -1, badgecmd)
      break if badgecmd < 0
      case badgecmd
      when 0   # Give all
        24.times { |i| $player.badges[i] = true }
      when 1   # Remove all
        24.times { |i| $player.badges[i] = false }
      else
        $player.badges[badgecmd - 2] = !$player.badges[badgecmd - 2]
      end
    end
  }
})

MenuHandlers.register(:debug_menu, "set_money", {
  "parent"      => "player_menu",
  "name"        => _INTL("Set Money"),
  "description" => _INTL("Edit how much money you have."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, Settings::MAX_MONEY)
    params.setDefaultValue($player.money)
    $player.money = pbMessageChooseNumber(_INTL("Set the player's money."), params)
    pbMessage(_INTL("You now have ${1}.", $player.money.to_s_formatted))
  }
})

MenuHandlers.register(:debug_menu, "set_coins", {
  "parent"      => "player_menu",
  "name"        => _INTL("Set Coins"),
  "description" => _INTL("Edit how many Game Corner Coins you have."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, Settings::MAX_COINS)
    params.setDefaultValue($player.coins)
    $player.coins = pbMessageChooseNumber(_INTL("Set the player's Coin amount."), params)
    pbMessage(_INTL("You now have {1} Coins.", $player.coins.to_s_formatted))
  }
})

MenuHandlers.register(:debug_menu, "set_bp", {
  "parent"      => "player_menu",
  "name"        => _INTL("Set Battle Points"),
  "description" => _INTL("Edit how many Battle Points you have."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, Settings::MAX_BATTLE_POINTS)
    params.setDefaultValue($player.battle_points)
    $player.battle_points = pbMessageChooseNumber(_INTL("Set the player's BP amount."), params)
    pbMessage(_INTL("You now have {1} BP.", $player.battle_points.to_s_formatted))
  }
})

MenuHandlers.register(:debug_menu, "toggle_running_shoes", {
  "parent"      => "player_menu",
  "name"        => _INTL("Toggle Running Shoes"),
  "description" => _INTL("Toggle possession of running shoes."),
  "effect"      => proc {
    $player.has_running_shoes = !$player.has_running_shoes
    pbMessage(_INTL("Gave Running Shoes.")) if $player.has_running_shoes
    pbMessage(_INTL("Lost Running Shoes.")) if !$player.has_running_shoes
  }
})

MenuHandlers.register(:debug_menu, "toggle_pokegear", {
  "parent"      => "player_menu",
  "name"        => _INTL("Toggle Pokégear"),
  "description" => _INTL("Toggle possession of the Pokégear."),
  "effect"      => proc {
    $player.has_pokegear = !$player.has_pokegear
    pbMessage(_INTL("Gave Pokégear.")) if $player.has_pokegear
    pbMessage(_INTL("Lost Pokégear.")) if !$player.has_pokegear
  }
})

MenuHandlers.register(:debug_menu, "toggle_pokedex", {
  "parent"      => "player_menu",
  "name"        => _INTL("Toggle Pokédex and Dexes"),
  "description" => _INTL("Toggle possession of the Pokédex, and edit Regional Dex accessibility."),
  "effect"      => proc {
    dexescmd = 0
    loop do
      dexescmds = []
      dexescmds.push(_INTL("Have Pokédex: {1}", $player.has_pokedex ? "[YES]" : "[NO]"))
      dex_names = Settings.pokedex_names
      dex_names.length.times do |i|
        name = (dex_names[i].is_a?(Array)) ? dex_names[i][0] : dex_names[i]
        unlocked = $player.pokedex.unlocked?(i)
        dexescmds.push(_INTL("{1} {2}", unlocked ? "[Y]" : "[  ]", name))
      end
      dexescmd = pbShowCommands(nil, dexescmds, -1, dexescmd)
      break if dexescmd < 0
      dexindex = dexescmd - 1
      if dexindex < 0   # Toggle Pokédex ownership
        $player.has_pokedex = !$player.has_pokedex
      elsif $player.pokedex.unlocked?(dexindex)   # Toggle Regional Dex accessibility
        $player.pokedex.lock(dexindex)
      else
        $player.pokedex.unlock(dexindex)
      end
    end
  }
})

MenuHandlers.register(:debug_menu, "set_player_character", {
  "parent"      => "player_menu",
  "name"        => _INTL("Set Player Character"),
  "description" => _INTL("Edit the player's character, as defined in \"metadata.txt\"."),
  "effect"      => proc {
    index = 0
    cmds = []
    ids = []
    GameData::PlayerMetadata.each do |player|
      index = cmds.length if player.id == $player.character_ID
      cmds.push(player.id.to_s)
      ids.push(player.id)
    end
    if cmds.length == 1
      pbMessage(_INTL("There is only one player character defined."))
      break
    end
    cmd = pbShowCommands(nil, cmds, -1, index)
    if cmd >= 0 && cmd != index
      pbChangePlayer(ids[cmd])
      pbMessage(_INTL("The player character was changed."))
    end
  }
})

MenuHandlers.register(:debug_menu, "change_outfit", {
  "parent"      => "player_menu",
  "name"        => _INTL("Set Player Outfit"),
  "description" => _INTL("Edit the player's outfit number."),
  "effect"      => proc {
    oldoutfit = $player.outfit
    params = ChooseNumberParams.new
    params.setRange(0, 99)
    params.setDefaultValue(oldoutfit)
    $player.outfit = pbMessageChooseNumber(_INTL("Set the player's outfit."), params)
    pbMessage(_INTL("Player's outfit was changed.")) if $player.outfit != oldoutfit
  }
})

MenuHandlers.register(:debug_menu, "rename_player", {
  "parent"      => "player_menu",
  "name"        => _INTL("Set Player Name"),
  "description" => _INTL("Rename the player."),
  "effect"      => proc {
    trname = pbEnterPlayerName("Your name?", 0, Settings::MAX_PLAYER_NAME_SIZE, $player.name)
    if nil_or_empty?(trname) && pbConfirmMessage(_INTL("Give yourself a default name?"))
      trainertype = $player.trainer_type
      gender      = pbGetTrainerTypeGender(trainertype)
      trname      = pbSuggestTrainerName(gender)
    end
    if nil_or_empty?(trname)
      pbMessage(_INTL("The player's name remained {1}.", $player.name))
    else
      $player.name = trname
      pbMessage(_INTL("The player's name was changed to {1}.", $player.name))
    end
  }
})

MenuHandlers.register(:debug_menu, "random_id", {
  "parent"      => "player_menu",
  "name"        => _INTL("Randomize Player ID"),
  "description" => _INTL("Generate a random new ID for the player."),
  "effect"      => proc {
    $player.id = rand(2**16) | (rand(2**16) << 16)
    pbMessage(_INTL("The player's ID was changed to {1} (full ID: {2}).", $player.public_ID, $player.id))
  }
})

#===============================================================================
# Information editors
#===============================================================================
MenuHandlers.register(:debug_menu, "editors_menu", {
  "parent"      => "main",
  "name"        => _INTL("Information editors..."),
  "description" => _INTL("Edit information in the PBS files, terrain tags, battle animations, etc."),
  "always_show" => true
})

MenuHandlers.register(:debug_menu, "set_metadata", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Metadata"),
  "description" => _INTL("Edit global metadata and player character metadata."),
  "always_show" => true,
  "effect"      => proc {
    pbMetadataScreen
  }
})

MenuHandlers.register(:debug_menu, "set_map_metadata", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Map Metadata"),
  "description" => _INTL("Edit map metadata."),
  "always_show" => true,
  "effect"      => proc {
    pbMapMetadataScreen(pbDefaultMap)
  }
})

MenuHandlers.register(:debug_menu, "set_map_connections", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Map Connections"),
  "description" => _INTL("Connect maps using a visual interface. Can also edit map encounters/metadata."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbConnectionsEditor }
  }
})

MenuHandlers.register(:debug_menu, "set_terrain_tags", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Terrain Tags"),
  "description" => _INTL("Edit the terrain tags of tiles in tilesets. Required for tags 8+."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbTilesetScreen }
  }
})

MenuHandlers.register(:debug_menu, "set_encounters", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Wild Encounters"),
  "description" => _INTL("Edit the wild Pokémon that can be found on maps, and how they are encountered."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbEncountersEditor }
  }
})

MenuHandlers.register(:debug_menu, "set_trainer_types", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Trainer Types"),
  "description" => _INTL("Edit the properties of trainer types."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbTrainerTypeEditor }
  }
})

MenuHandlers.register(:debug_menu, "set_trainers", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Individual Trainers"),
  "description" => _INTL("Edit individual trainers, their Pokémon and items."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbTrainerBattleEditor }
  }
})

MenuHandlers.register(:debug_menu, "set_items", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Items"),
  "description" => _INTL("Edit item data."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbItemEditor }
  }
})

MenuHandlers.register(:debug_menu, "set_species", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Pokémon"),
  "description" => _INTL("Edit Pokémon species data."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbPokemonEditor }
  }
})

MenuHandlers.register(:debug_menu, "set_pokedex_lists", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Regional Dexes"),
  "description" => _INTL("Create, rearrange and delete Regional Pokédex lists."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbRegionalDexEditorMain }
  }
})

MenuHandlers.register(:debug_menu, "position_sprites", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Edit Pokémon Sprite Positions"),
  "description" => _INTL("Reposition Pokémon sprites in battle."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn {
      sp = SpritePositioner.new
      sps = SpritePositionerScreen.new(sp)
      sps.pbStart
    }
  }
})

MenuHandlers.register(:debug_menu, "auto_position_sprites", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Auto-Position All Sprites"),
  "description" => _INTL("Automatically reposition all Pokémon sprites in battle. Don't use lightly."),
  "always_show" => true,
  "effect"      => proc {
    if pbConfirmMessage(_INTL("Are you sure you want to reposition all sprites?"))
      msgwindow = pbCreateMessageWindow
      pbMessageDisplay(msgwindow, _INTL("Repositioning all sprites. Please wait."), false)
      Graphics.update
      pbAutoPositionAll
      pbDisposeMessageWindow(msgwindow)
    end
  }
})

MenuHandlers.register(:debug_menu, "animation_editor", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Battle Animation Editor"),
  "description" => _INTL("Edit the battle animations."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbAnimationEditor }
  }
})

MenuHandlers.register(:debug_menu, "animation_organiser", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Battle Animation Organiser"),
  "description" => _INTL("Rearrange/add/delete battle animations."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbAnimationsOrganiser }
  }
})

MenuHandlers.register(:debug_menu, "import_animations", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Import All Battle Animations"),
  "description" => _INTL("Import all battle animations from the \"Animations\" folder."),
  "always_show" => true,
  "effect"      => proc {
    pbImportAllAnimations
  }
})

MenuHandlers.register(:debug_menu, "export_animations", {
  "parent"      => "editors_menu",
  "name"        => _INTL("Export All Battle Animations"),
  "description" => _INTL("Export all battle animations individually to the \"Animations\" folder."),
  "always_show" => true,
  "effect"      => proc {
    pbExportAllAnimations
  }
})

#===============================================================================
# Other options
#===============================================================================
MenuHandlers.register(:debug_menu, "other_menu", {
  "parent"      => "main",
  "name"        => _INTL("Other options..."),
  "description" => _INTL("Mystery Gifts, translations, compile data, etc."),
  "always_show" => true
})

MenuHandlers.register(:debug_menu, "mystery_gift", {
  "parent"      => "other_menu",
  "name"        => _INTL("Manage Mystery Gifts"),
  "description" => _INTL("Edit and enable/disable Mystery Gifts."),
  "always_show" => true,
  "effect"      => proc {
    pbManageMysteryGifts
  }
})

MenuHandlers.register(:debug_menu, "extract_text", {
  "parent"      => "other_menu",
  "name"        => _INTL("Extract Text"),
  "description" => _INTL("Extract all text in the game to a single file for translating."),
  "always_show" => true,
  "effect"      => proc {
    pbExtractText
  }
})

MenuHandlers.register(:debug_menu, "compile_text", {
  "parent"      => "other_menu",
  "name"        => _INTL("Compile Text"),
  "description" => _INTL("Import text and converts it into a language file."),
  "always_show" => true,
  "effect"      => proc {
    pbCompileTextUI
  }
})

MenuHandlers.register(:debug_menu, "compile_data", {
  "parent"      => "other_menu",
  "name"        => _INTL("Compile Data"),
  "description" => _INTL("Fully compile all data."),
  "always_show" => true,
  "effect"      => proc {
    msgwindow = pbCreateMessageWindow
    Compiler.compile_all(true)
    pbMessageDisplay(msgwindow, _INTL("All game data was compiled."))
    pbDisposeMessageWindow(msgwindow)
  }
})

MenuHandlers.register(:debug_menu, "create_pbs_files", {
  "parent"      => "other_menu",
  "name"        => _INTL("Create PBS File(s)"),
  "description" => _INTL("Choose one or all PBS files and create it."),
  "always_show" => true,
  "effect"      => proc {
    cmd = 0
    cmds = [
      _INTL("[Create all]"),
      "abilities.txt",
      "battle_facility_lists.txt",
      "berry_plants.txt",
      "encounters.txt",
      "items.txt",
      "map_connections.txt",
      "map_metadata.txt",
      "metadata.txt",
      "moves.txt",
      "phone.txt",
      "pokemon.txt",
      "pokemon_forms.txt",
      "pokemon_metrics.txt",
      "regional_dexes.txt",
      "ribbons.txt",
      "shadow_pokemon.txt",
      "town_map.txt",
      "trainer_types.txt",
      "trainers.txt",
      "types.txt"
    ]
    loop do
      cmd = pbShowCommands(nil, cmds, -1, cmd)
      case cmd
      when 0  then Compiler.write_all
      when 1  then Compiler.write_abilities
      when 2  then Compiler.write_trainer_lists
      when 3  then Compiler.write_berry_plants
      when 4  then Compiler.write_encounters
      when 5  then Compiler.write_items
      when 6  then Compiler.write_connections
      when 7  then Compiler.write_map_metadata
      when 8  then Compiler.write_metadata
      when 9  then Compiler.write_moves
      when 10 then Compiler.write_phone
      when 11 then Compiler.write_pokemon
      when 12 then Compiler.write_pokemon_forms
      when 13 then Compiler.write_pokemon_metrics
      when 14 then Compiler.write_regional_dexes
      when 15 then Compiler.write_ribbons
      when 16 then Compiler.write_shadow_pokemon
      when 17 then Compiler.write_town_map
      when 18 then Compiler.write_trainer_types
      when 19 then Compiler.write_trainers
      when 20 then Compiler.write_types
      else break
      end
      pbMessage(_INTL("File written."))
    end
  }
})

MenuHandlers.register(:debug_menu, "fix_invalid_tiles", {
  "parent"      => "other_menu",
  "name"        => _INTL("Fix Invalid Tiles"),
  "description" => _INTL("Scans all maps and erases non-existent tiles."),
  "always_show" => true,
  "effect"      => proc {
    pbDebugFixInvalidTiles
  }
})

MenuHandlers.register(:debug_menu, "rename_files", {
  "parent"      => "other_menu",
  "name"        => _INTL("Rename Outdated Files"),
  "description" => _INTL("Check for files with outdated names and rename/move them. Can alter map data."),
  "always_show" => true,
  "effect"      => proc {
    if pbConfirmMessage(_INTL("Are you sure you want to automatically rename outdated files?"))
      FilenameUpdater.rename_files
      pbMessage(_INTL("Done."))
    end
  }
})

MenuHandlers.register(:debug_menu, "reload_system_cache", {
  "parent"      => "other_menu",
  "name"        => _INTL("Reload System Cache"),
  "description" => _INTL("Refreshes the system's file cache. Use if you change a file while playing."),
  "always_show" => true,
  "effect"      => proc {
    System.reload_cache
    pbMessage(_INTL("Done."))
  }
})
