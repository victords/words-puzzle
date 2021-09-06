class Utils
  class << self
    def alternating_rate(timer, interval)
      (timer >= interval * 0.5 ? interval - timer : timer).to_f / (interval * 0.5)
    end

    def lighten(color, rate)
      a, r, g, b = components(color)
      r = [(r + (255 - r) * rate).round, 255].min
      g = [(g + (255 - g) * rate).round, 255].min
      b = [(b + (255 - b) * rate).round, 255].min
      compose(a, r, g, b)
    end

    def darken(color, rate)
      a, r, g, b = components(color)
      r = (r * (1 - rate)).round
      g = (g * (1 - rate)).round
      b = (b * (1 - rate)).round
      compose(a, r, g, b)
    end

    def with_alpha(color, alpha)
      (alpha << 24) | (color & 0xffffff)
    end

    private

    def components(color)
      [(color & 0xff000000) >> 24, (color & 0xff0000) >> 16, (color & 0xff00) >> 8, color & 0xff]
    end

    def compose(a, r, g, b)
      (a << 24) | (r << 16) | (g << 8) | b
    end
  end
end
