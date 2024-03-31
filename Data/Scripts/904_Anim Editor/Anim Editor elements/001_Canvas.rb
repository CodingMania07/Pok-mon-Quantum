#===============================================================================
# NOTE: z values:
#       -200 = backdrop.
#       -199 = side bases
#       -198 = battler shadows.
#       0 +/-50 = background focus, foe side background.
#       900, 800, 700... +/-50 = foe battlers.
#       1000 +/-50 = foe side foreground, player side background.
#       1100, 1200, 1300... +/-50 = player battlers.
#       2000 +/-50 = player side foreground, foreground focus.
#       9999+ = UI
#===============================================================================
class AnimationEditor::Canvas < Sprite
  attr_reader :values

  def initialize(viewport, anim, settings)
    super(viewport)
    @anim              = anim
    @settings          = settings
    @keyframe          = 0
    @selected_particle = -2
    @captured          = nil
    @user_coords       = []
    @target_coords     = []
    @playing           = false   # TODO: What should this affect? Is it needed?
    initialize_background
    initialize_battlers
    initialize_particle_sprites
    initialize_particle_frames
    refresh
  end

  def initialize_background
    self.z = -200
    # NOTE: The background graphic is self.bitmap.
    # TODO: Add second (flipped) background graphic, for screen shake commands.
    player_base_pos = Battle::Scene.pbBattlerPosition(0)
    @player_base = IconSprite.new(*player_base_pos, viewport)
    @player_base.z = -199
    foe_base_pos = Battle::Scene.pbBattlerPosition(1)
    @foe_base = IconSprite.new(*foe_base_pos, viewport)
    @foe_base.z = -199
    @message_bar_sprite = Sprite.new(viewport)
    @message_bar_sprite.z = 9999
  end

  def initialize_battlers
    @battler_sprites = []
  end

  def initialize_particle_sprites
    @particle_sprites = []
  end

  def initialize_particle_frames
    # Frame for selected particle
    @sel_frame_bitmap = Bitmap.new(64, 64)
    @sel_frame_bitmap.outline_rect(0, 0, @sel_frame_bitmap.width, @sel_frame_bitmap.height, Color.new(0, 0, 0, 64))
    @sel_frame_bitmap.outline_rect(2, 2, @sel_frame_bitmap.width - 4, @sel_frame_bitmap.height - 4, Color.new(0, 0, 0, 64))
    @sel_frame_sprite = Sprite.new(viewport)
    @sel_frame_sprite.bitmap = @sel_frame_bitmap
    @sel_frame_sprite.z = 99999
    @sel_frame_sprite.ox = @sel_frame_bitmap.width / 2
    @sel_frame_sprite.oy = @sel_frame_bitmap.height / 2
    # Frame for other particles
    @frame_bitmap = Bitmap.new(64, 64)
    @frame_bitmap.outline_rect(1, 1, @frame_bitmap.width - 2, @frame_bitmap.height - 2, Color.new(0, 0, 0, 64))
    @frame_sprites = []
  end

  def dispose
    @user_bitmap_front&.dispose
    @user_bitmap_back&.dispose
    @target_bitmap_front&.dispose
    @target_bitmap_back&.dispose
    @sel_frame_bitmap&.dispose
    @frame_bitmap&.dispose
    @player_base.dispose
    @foe_base.dispose
    @message_bar_sprite.dispose
    @battler_sprites.each { |s| s.dispose if s && !s.disposed? }
    @battler_sprites.clear
    @particle_sprites.each do |s|
      if s.is_a?(Array)
        s.each { |s2| s2.dispose if s2 && !s2.disposed? }
      else
        s.dispose if s && !s.disposed?
      end
    end
    @particle_sprites.clear
    @frame_sprites.each do |s|
      if s.is_a?(Array)
        s.each { |s2| s2.dispose if s2 && !s2.disposed? }
      else
        s.dispose if s && !s.disposed?
      end
    end
    @frame_sprites.clear
    @sel_frame_sprite&.dispose
    super
  end

  #-----------------------------------------------------------------------------

  # Returns whether the user is on the foe's (non-player's) side.
  def sides_swapped?
    return @settings[:user_opposes] || [:opp_move, :opp_common].include?(@anim[:type])
  end

  # index is a battler index (even for player's side, odd for foe's side)
  def side_size(index)
    side = index % 2
    side = (side + 1) % 2 if sides_swapped?
    return @settings[:side_sizes][side]
  end

  def user_index
    ret = @settings[:user_index]
    ret += 1 if sides_swapped?
    return ret
  end

  def target_indices
    ret = @settings[:target_indices].clone
    if sides_swapped?
      ret.length.times do |i|
        ret[i] += (ret[i].even?) ? 1 : -1
      end
    end
    return ret
  end

  def first_target_index
    return target_indices.compact[0]
  end

  def position_empty?(index)
    return false if !@anim[:no_user] && user_index == index
    return false if !@anim[:no_target] && target_indices.include?(index)
    return true
  end

  def selected_particle=(val)
    return if @selected_particle == val
    @selected_particle = val
    refresh_particle_frame
  end

  def keyframe=(val)
    return if @keyframe == val || val < 0
    @keyframe = val
    refresh
  end

  def mouse_pos
    mouse_coords = Mouse.getMousePos
    return nil, nil if !mouse_coords
    ret_x = mouse_coords[0] - self.viewport.rect.x - self.x
    ret_y = mouse_coords[1] - self.viewport.rect.y - self.y
    return nil, nil if ret_x < 0 || ret_x >= self.viewport.rect.width ||
                       ret_y < 0 || ret_y >= self.viewport.rect.height
    return ret_x, ret_y
  end

  #-----------------------------------------------------------------------------

  def busy?
    return !@captured.nil?
  end

  def changed?
    return !@values.nil?
  end

  def clear_changed
    @values = nil
  end

  #-----------------------------------------------------------------------------

  def prepare_to_play_animation
    # TODO: Hide particle sprites, set battler sprites to starting positions so
    #       that the animation can play properly. Also need a way to end this
    #       override after the animation finishes playing. This method does not
    #       literally play the animation; the main editor screen or playback
    #       control does that.
    @playing = true
  end

  def end_playing_animation
    @playing = false
    refresh
  end

  #-----------------------------------------------------------------------------

  def refresh_bg_graphics
    return if @bg_name && @bg_name == @settings[:canvas_bg]
    @bg_name = @settings[:canvas_bg]
    # TODO: Make the choice of background graphics match the in-battle one in
    #       def pbCreateBackdropSprites. Ideally make that method a class method
    #       so the canvas can use it rather than duplicate it.
    self.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_bg")
    @player_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base0")
    @player_base.ox = @player_base.bitmap.width / 2
    @player_base.oy = @player_base.bitmap.height
    @foe_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base1")
    @foe_base.ox = @foe_base.bitmap.width / 2
    @foe_base.oy = @foe_base.bitmap.height / 2
    @message_bar_sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_message")
    @message_bar_sprite.y = Settings::SCREEN_HEIGHT - @message_bar_sprite.height
  end

  def create_frame_sprite(index, sub_index = -1)
    if sub_index >= 0
      return if @frame_sprites[index] && @frame_sprites[index][sub_index] && !@frame_sprites[index][sub_index].disposed?
    else
      return if @frame_sprites[index] && !@frame_sprites[index].disposed?
    end
    sprite = Sprite.new(viewport)
    sprite.bitmap = @frame_bitmap
    sprite.z = 99998
    sprite.ox = @frame_bitmap.width / 2
    sprite.oy = @frame_bitmap.height / 2
    if sub_index >= 0
      @frame_sprites[index] ||= []
      @frame_sprites[index][sub_index] = sprite
    else
      @frame_sprites[index] = sprite
    end
  end

  # TODO: Create shadow sprites?
  def ensure_battler_sprites
    if !@side_size0 || @side_size0 != side_size(0)
      @battler_sprites.each_with_index { |s, i| s.dispose if i.even? && s && !s.disposed? }
      idx_user = @anim[:particles].index { |particle| particle[:name] == "User" }
      @side_size0 = side_size(0)
      @side_size0.times do |i|
        next if position_empty?(i * 2)
        @battler_sprites[i * 2] = Sprite.new(self.viewport)
        create_frame_sprite(idx_user)
      end
    end
    if !@side_size1 || @side_size1 != side_size(1)
      @battler_sprites.each_with_index { |s, i| s.dispose if i.odd? && s && !s.disposed? }
      idx_target = @anim[:particles].index { |particle| particle[:name] == "Target" }
      @side_size1 = side_size(1)
      @side_size1.times do |i|
        next if position_empty?((i * 2) + 1)
        @battler_sprites[(i * 2) + 1] = Sprite.new(self.viewport)
        create_frame_sprite(idx_target, (i * 2) + 1)
      end
    end
  end

  def refresh_battler_graphics
    if !@user_sprite_name || !@user_sprite_name || @user_sprite_name != @settings[:user_sprite_name]
      @user_sprite_name = @settings[:user_sprite_name]
      @user_bitmap_front&.dispose
      @user_bitmap_back&.dispose
      @user_bitmap_front = RPG::Cache.load_bitmap("Graphics/Pokemon/Front/", @user_sprite_name)
      @user_bitmap_back = RPG::Cache.load_bitmap("Graphics/Pokemon/Back/", @user_sprite_name)
    end
    if !@target_bitmap_front || !@target_sprite_name || @target_sprite_name != @settings[:target_sprite_name]
      @target_sprite_name = @settings[:target_sprite_name]
      @target_bitmap_front&.dispose
      @target_bitmap_back&.dispose
      @target_bitmap_front = RPG::Cache.load_bitmap("Graphics/Pokemon/Front/", @target_sprite_name)
      @target_bitmap_back = RPG::Cache.load_bitmap("Graphics/Pokemon/Back/", @target_sprite_name)
    end
  end

  def refresh_battler_positions
    user_idx = user_index
    @user_coords = recalculate_battler_position(
      user_idx, side_size(user_idx), @user_sprite_name,
      (user_idx.even?) ? @user_bitmap_back : @user_bitmap_front
    )
    target_indices.each do |target_idx|
      @target_coords[target_idx] = recalculate_battler_position(
        target_idx, side_size(target_idx), @target_sprite_name,
        (target_idx.even?) ? @target_bitmap_back : @target_bitmap_front
      )
    end
  end

  def recalculate_battler_position(index, size, sprite_name, btmp)
    spr = Sprite.new(self.viewport)
    spr.x, spr.y = Battle::Scene.pbBattlerPosition(index, size)
    data = GameData::Species.get_species_form(sprite_name, 0)   # Form 0
    data.apply_metrics_to_sprite(spr, index) if data
    return [spr.x, spr.y - (btmp.height / 2)]
  end

  def create_particle_sprite(index, target_idx = -1)
    if target_idx >= 0
      if @particle_sprites[index].is_a?(Array)
        return if @particle_sprites[index][target_idx] && !@particle_sprites[index][target_idx].disposed?
      else
        @particle_sprites[index].dispose if @particle_sprites[index] && !@particle_sprites[index].disposed?
        @particle_sprites[index] = []
        @frame_sprites[index].dispose if @frame_sprites[index] && !@frame_sprites[index].disposed?
        @frame_sprites[index] = []
      end
      @particle_sprites[index][target_idx] = Sprite.new(self.viewport)
      create_frame_sprite(index, target_idx)
    else
      if @particle_sprites[index].is_a?(Array)
        @particle_sprites[index].each { |s| s.dispose if s && !s.disposed? }
        @particle_sprites[index] = nil
        @frame_sprites[index].each { |s| s.dispose if s && !s.disposed? }
        @frame_sprites[index] = nil
      else
        return if @particle_sprites[index] && !@particle_sprites[index].disposed?
      end
      @particle_sprites[index] = Sprite.new(self.viewport)
      create_frame_sprite(index)
    end
  end

  def get_sprite_and_frame(index, target_idx = -1)
    spr = nil
    frame = nil
    particle = @anim[:particles][index]
    case particle[:name]
    when "SE"
      return
    when "User"
      spr = @battler_sprites[user_index]
      raise _INTL("Sprite for particle {1} not found somehow (battler index {2}).",
                  particle[:name], user_index) if !spr
      idx_user = @anim[:particles].index { |particle| particle[:name] == "User" }
      frame = @frame_sprites[idx_user]
    when "Target"
      spr = @battler_sprites[target_idx]
      raise _INTL("Sprite for particle {1} not found somehow (battler index {2}).",
                  particle[:name], target_idx) if !spr
      idx_target = @anim[:particles].index { |particle| particle[:name] == "Target" }
      frame = @frame_sprites[idx_target][target_idx]
    else
      create_particle_sprite(index, target_idx)
      if target_idx >= 0
        spr = @particle_sprites[index][target_idx]
        frame = @frame_sprites[index][target_idx]
      else
        spr = @particle_sprites[index]
        frame = @frame_sprites[index]
      end
    end
    return spr, frame
  end

  def refresh_sprite(index, target_idx = -1)
    particle = @anim[:particles][index]
    return if !particle || particle[:name] == "SE"
    # Get sprite
    spr, frame = get_sprite_and_frame(index, target_idx)
    # Calculate all values of particle at the current keyframe
    values = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(particle, @keyframe)
    values.each_pair do |property, val|
      values[property] = val[0]
    end
    # Set visibility
    spr.visible = values[:visible]
    frame.visible = spr.visible
    return if !spr.visible
    # Set opacity
    spr.opacity = values[:opacity]
    # Set coordinates
    spr.x = values[:x]
    spr.y = values[:y]
    case particle[:focus]
    when :foreground, :midground, :background
    when :user
      spr.x += @user_coords[0]
      spr.y += @user_coords[1]
    when :target
      spr.x += @target_coords[target_idx][0]
      spr.y += @target_coords[target_idx][1]
    when :user_and_target
      user_pos = @user_coords
      target_pos = @target_coords[target_idx]
      distance = GameData::Animation::USER_AND_TARGET_SEPARATION
      spr.x = user_pos[0] + ((values[:x].to_f / distance[0]) * (target_pos[0] - user_pos[0])).to_i
      spr.y = user_pos[1] + ((values[:y].to_f / distance[1]) * (target_pos[1] - user_pos[1])).to_i
    when :user_side_foreground, :user_side_background
      base_coords = Battle::Scene.pbBattlerPosition(user_index)
      spr.x += base_coords[0]
      spr.y += base_coords[1]
    when :target_side_foreground, :target_side_background
      base_coords = Battle::Scene.pbBattlerPosition(target_idx)
      spr.x += base_coords[0]
      spr.y += base_coords[1]
    end
    # Set graphic and ox/oy (may also alter y coordinate)
    case particle[:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      case particle[:graphic]
      when "USER"
        spr.bitmap = (user_index.even?) ? @user_bitmap_back : @user_bitmap_front
      when "USER_OPP"
        spr.bitmap = (user_index.even?) ? @user_bitmap_front : @user_bitmap_back
      when "USER_FRONT"
        spr.bitmap = @user_bitmap_front
      when "USER_BACK"
        spr.bitmap = @user_bitmap_back
      when "TARGET"
        if target_idx < 0
          raise _INTL("Particle \"{1}\" was given a graphic of \"TARGET\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = (target_idx.even?) ? @target_bitmap_back : @target_bitmap_front
      when "TARGET_OPP"
        if target_idx < 0
          raise _INTL("Particle \"{1}\" was given a graphic of \"TARGET_OPP\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = (target_idx.even?) ? @target_bitmap_front : @target_bitmap_back
      when "TARGET_FRONT"
        if target_idx < 0
          raise _INTL("Particle \"{1}\" was given a graphic of \"TARGET_FRONT\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = @target_bitmap_front
      when "TARGET_BACK"
        if target_idx < 0
          raise _INTL("Particle \"{1}\" was given a graphic of \"TARGET_BACK\" but its focus doesn't include a target.",
                      particle[:name])
        end
        spr.bitmap = @target_bitmap_back
      end
      spr.ox = spr.bitmap.width / 2
      spr.oy = spr.bitmap.height
      spr.y += spr.bitmap.height / 2
    else
      spr.bitmap = RPG::Cache.load_bitmap("Graphics/Battle animations/", particle[:graphic])
      if [:foreground, :midground, :background].include?(particle[:focus]) &&
         spr.bitmap.width == AnimationEditor::CANVAS_WIDTH &&
         spr.bitmap.height >= AnimationEditor::CANVAS_HEIGHT - @message_bar_sprite.y
        spr.ox = 0
        spr.oy = 0
      elsif spr.bitmap.width > spr.bitmap.height * 2
        spr.src_rect.set(values[:frame] * spr.bitmap.height, 0, spr.bitmap.height, spr.bitmap.height)
        spr.ox = spr.bitmap.height / 2
        spr.oy = spr.bitmap.height / 2
      else
        spr.src_rect.set(0, 0, spr.bitmap.width, spr.bitmap.height)
        spr.ox = spr.bitmap.width / 2
        spr.oy = spr.bitmap.height / 2
      end
      if particle[:graphic][/\[\s*bottom\s*\]\s*$/i]   # [bottom] at end of filename
        spr.oy = spr.bitmap.height
      end
    end
    # Set z (priority)
    spr.z = values[:z]
    case particle[:focus]
    when :foreground
      spr.z += 2000
    when :midground
      spr.z += 1000
    when :background
      # NOTE: No change.
    when :user
      spr.z += 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
    when :target
      spr.z += 1000 + ((100 * ((target_idx / 2) + 1)) * (target_idx.even? ? 1 : -1))
    when :user_and_target
      user_pos = 1000 + ((100 * ((user_index / 2) + 1)) * (user_index.even? ? 1 : -1))
      target_pos = 1000 + ((100 * ((target_idx / 2) + 1)) * (target_idx.even? ? 1 : -1))
      distance = GameData::Animation::USER_AND_TARGET_SEPARATION[2]
      if values[:z] >= 0
        spr.z += user_pos
      elsif values[:z] <= distance
        spr.z += target_pos
      else
        spr.z = user_pos + ((values[:z].to_f / distance) * (target_pos - user_pos)).to_i
      end
    when :user_side_foreground, :target_side_foreground
      this_idx = (particle[:focus] == :user_side_foreground) ? user_index : target_idx
      spr.z += 1000
      spr.z += 1000 if this_idx.even?   # On player's side
    when :user_side_background, :target_side_background
      this_idx = (particle[:focus] == :user_side_background) ? user_index : target_idx
      spr.z += 1000 if this_idx.even?   # On player's side
    end
    # Set various other properties
    spr.zoom_x = values[:zoom_x] / 100.0
    spr.zoom_y = values[:zoom_y] / 100.0
    spr.angle = values[:angle]
    spr.mirror = values[:flip]
    spr.blend_type = values[:blending]
    # Set color and tone
    spr.color.set(values[:color_red], values[:color_green], values[:color_blue], values[:color_alpha])
    spr.tone.set(values[:tone_red], values[:tone_green], values[:tone_blue], values[:tone_gray])
    # Position frame over spr
    frame.x = spr.x
    frame.y = spr.y
    case @anim[:particles][index][:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      frame.y -= spr.bitmap.height / 2
    end
  end

  def refresh_particle(index)
    one_per_side = [:target_side_foreground, :target_side_background].include?(@anim[:particles][index][:focus])
    sides_covered = []
    target_indices.each do |target_idx|
      next if one_per_side && sides_covered.include?(target_idx % 2)
      refresh_sprite(index, target_idx)
      sides_covered.push(target_idx % 2)
    end
  end

  def refresh_particle_frame
    return if @selected_particle < 0 || @selected_particle >= @anim[:particles].length - 1
    focus = @anim[:particles][@selected_particle][:focus]
    frame_color = AnimationEditor::ParticleList::CONTROL_BG_COLORS[focus] || Color.magenta
    @sel_frame_bitmap.outline_rect(1, 1, @sel_frame_bitmap.width - 2, @sel_frame_bitmap.height - 2, frame_color)
    update_selected_particle_frame
  end

  def refresh
    refresh_bg_graphics
    ensure_battler_sprites
    refresh_battler_graphics
    refresh_battler_positions
    @battler_sprites.each { |s| s.visible = false if s && !s.disposed? }
    @particle_sprites.each do |s|
      if s.is_a?(Array)
        s.each { |s2| s2.visible = false if s2 && !s2.disposed? }
      else
        s.visible = false if s && !s.disposed?
      end
    end
    @anim[:particles].each_with_index do |particle, i|
      if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
        refresh_particle(i)   # Because there can be multiple targets
      else
        refresh_sprite(i) if particle[:name] != "SE"
      end
    end
    refresh_particle_frame   # Intentionally after refreshing particles
  end

  #-----------------------------------------------------------------------------

  def mouse_in_sprite?(sprite, mouse_x, mouse_y)
    return false if mouse_x < sprite.x - sprite.ox
    return false if mouse_x >= sprite.x - sprite.ox + sprite.width
    return false if mouse_y < sprite.y - sprite.oy
    return false if mouse_y >= sprite.y - sprite.oy + sprite.height
    return true
  end

  def on_mouse_press
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    # Check if mouse is over particle frame
    if @sel_frame_sprite.visible &&
       mouse_x >= @sel_frame_sprite.x - @sel_frame_sprite.ox &&
       mouse_x < @sel_frame_sprite.x - @sel_frame_sprite.ox + @sel_frame_sprite.width &&
       mouse_y >= @sel_frame_sprite.y - @sel_frame_sprite.oy &&
       mouse_y < @sel_frame_sprite.y - @sel_frame_sprite.oy + @sel_frame_sprite.height
      @captured = [@sel_frame_sprite.x, @sel_frame_sprite.y,
                   @sel_frame_sprite.x - mouse_x, @sel_frame_sprite.y - mouse_y]
      return
    end
    # Find closest particle to mouse
    nearest_index = -1
    nearest_distance = -1
    @frame_sprites.each_with_index do |sprite, index|
      sprites = (sprite.is_a?(Array)) ? sprite : [sprite]
      sprites.each do |spr|
        next if !spr || !spr.visible
        next if !mouse_in_sprite?(spr, mouse_x, mouse_y)
        dist = (spr.x - mouse_x) ** 2 + (spr.y - mouse_y) ** 2
        next if nearest_distance >= 0 && nearest_distance < dist
        nearest_index = index
        nearest_distance = dist
      end
    end
    return if nearest_index < 0
    @values = { :particle_index => nearest_index }
  end

  def on_mouse_release
    @captured = nil
  end

  def update_input
    if Input.trigger?(Input::MOUSELEFT)
      on_mouse_press
    elsif busy? && Input.release?(Input::MOUSELEFT)
      on_mouse_release
    end
  end

  def update_particle_moved
    return if !busy?
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    new_canvas_x = mouse_x + @captured[2]
    new_canvas_y = mouse_y + @captured[3]
    return if @captured[0] == new_canvas_x && @captured[1] == new_canvas_y
    particle = @anim[:particles][@selected_particle]
    if GameData::Animation::FOCUS_TYPES_WITH_TARGET.include?(particle[:focus])
      sprite, frame = get_sprite_and_frame(@selected_particle, first_target_index)
    else
      sprite, frame = get_sprite_and_frame(@selected_particle)
    end
    # Check if moved horizontally
    if @captured[0] != new_canvas_x
      new_canvas_pos = mouse_x + @captured[2]
      new_pos = new_canvas_x
      case particle[:focus]
      when :foreground, :midground, :background
      when :user
        new_pos -= @user_coords[0]
      when :target
        new_pos -= @target_coords[first_target_index][0]
      when :user_and_target
        user_pos = @user_coords
        target_pos = @target_coords[first_target_index]
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        new_pos -= user_pos[0]
        new_pos *= distance[0]
        new_pos /= target_pos[0] - user_pos[0]
      when :user_side_foreground, :user_side_background
        base_coords = Battle::Scene.pbBattlerPosition(user_index)
        new_pos -= base_coords[0]
      when :target_side_foreground, :target_side_background
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index)
        new_pos -= base_coords[0]
      end
      @values ||= {}
      @values[:x] = new_pos
      @captured[0] = new_canvas_x
      sprite.x = new_canvas_x
    end
    # Check if moved vertically
    if @captured[1] != new_canvas_y
      new_pos = new_canvas_y
      case particle[:focus]
      when :foreground, :midground, :background
      when :user
        new_pos -= @user_coords[1]
      when :target
        new_pos -= @target_coords[first_target_index][1]
      when :user_and_target
        user_pos = @user_coords
        target_pos = @target_coords[first_target_index]
        distance = GameData::Animation::USER_AND_TARGET_SEPARATION
        new_pos -= user_pos[1]
        new_pos *= distance[1]
        new_pos /= target_pos[1] - user_pos[1]
      when :user_side_foreground, :user_side_background
        base_coords = Battle::Scene.pbBattlerPosition(user_index)
        new_pos -= base_coords[1]
      when :target_side_foreground, :target_side_background
        base_coords = Battle::Scene.pbBattlerPosition(first_target_index)
        new_pos -= base_coords[1]
      end
      @values ||= {}
      @values[:y] = new_pos
      @captured[1] = new_canvas_y
      sprite.y = new_canvas_y
    end
  end

  def update_selected_particle_frame
    if @selected_particle < 0 || @selected_particle >= @anim[:particles].length - 1
      @sel_frame_sprite.visible = false
      return
    end
    case @anim[:particles][@selected_particle][:name]
    when "User"
      target = @battler_sprites[user_index]
      raise _INTL("Sprite for particle \"{1}\" not found somehow.",
                  @anim[:particles][@selected_particle][:name]) if !target
    when "Target"
      target = @battler_sprites[target_indices[0]]
      raise _INTL("Sprite for particle \"{1}\" not found somehow.",
                  @anim[:particles][@selected_particle][:name]) if !target
    else
      target = @particle_sprites[@selected_particle]
      target = target[target_indices[0]] if target&.is_a?(Array)
    end
    if !target || !target.visible
      @sel_frame_sprite.visible = false
      return
    end
    @sel_frame_sprite.visible = true
    @sel_frame_sprite.x = target.x
    @sel_frame_sprite.y = target.y
    case @anim[:particles][@selected_particle][:graphic]
    when "USER", "USER_OPP", "USER_FRONT", "USER_BACK",
         "TARGET", "TARGET_OPP", "TARGET_FRONT", "TARGET_BACK"
      @sel_frame_sprite.y -= target.bitmap.height / 2
    end
  end

  def update
    update_input
    update_particle_moved
    update_selected_particle_frame
  end
end
