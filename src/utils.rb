class Utils
  class << self
    SINOID_STEP = Math::PI * 0.025
    FULL_CIRCLE = Math::PI * 2

    def alternating_rate(timer, interval)
      (timer >= interval * 0.5 ? interval - timer : timer).to_f / (interval * 0.5)
    end

    def sinoid(x, amplitude = 4)
      x += SINOID_STEP
      x = 0 if x >= FULL_CIRCLE
      [x, amplitude * Math.sin(x)]
    end
  end
end
