module Animation
  def set_animation(index)
    @img_index = index
    @index_index = @anim_counter = @animate_once_control = 0
  end

  def animate_once(indices, interval)
    if @animate_once_control == 2
      return if indices == @animate_once_indices && interval == @animate_once_interval
      @animate_once_control = 0
    end

    unless @animate_once_control == 1
      @anim_counter = 0
      @img_index = indices[0]
      @index_index = 0
      @animate_once_indices = indices
      @animate_once_interval = interval
      @animate_once_control = 1
      return
    end

    @anim_counter += 1
    return unless @anim_counter >= interval

    if @index_index == indices.length - 1
      @animate_once_control = 2
      yield if block_given?
    else
      @index_index += 1
      @img_index = indices[@index_index]
      @anim_counter = 0
    end
  end
end
