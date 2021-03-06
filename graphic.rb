# m = MiniMagick::Image.new('tape2.jpg')
# m.format 'png'
# m.resize '512x512'
# m.ordered_dither 'o3x3'
# m.depth 4
# m.colorspace 'Gray'
# m.scale '10%'
# m.scale '1000%'
# m.write 'images/tape2.png'

module Ruby2D
  class Graphic
    attr_reader :x, :y, :width, :height, :z, :path
    attr_accessor :script, :listener, :tag

    def initialize opts = {}
      @visible = false
      @rendered = false
      @z = opts[:z] || 0
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @width = opts[:width] || 0
      @height = opts[:height] || 0
      @path = opts[:path]
      @script = opts[:script] || ''
    end

    def to_h
      {
        type: 'graphic',
        path: @path,
        x: @x,
        y: @y,
        z: @z,
        width: @width,
        height: @height,
        script: @script
      }
    end

    def visible?
      @visible
    end

    def remove
      @highlight.remove
      @image.remove

      @visible = false

      self
    end

    def add
      if @rendered
        @highlight.add
        @image.add

        proportions!
      else
        render!
      end

      @visible = true

      self
    end

    def contains? x, y
      (@image.x..(@image.x + @image.width)).cover?(x) &&
        (@image.y..(@image.y + @image.height)).cover?(y)
    end

    def z= new_z
      @z = new_z
      @highlight.z = new_z
      @image.z = new_z
    end

    def translate dx, dy
      @x = @x + dx
      @y = @y + dy

      @highlight.translate dx, dy

      @image.x = @image.x + dx
      @image.y = @image.y + dy
    end

    def highlight
      @highlight.show
    end

    def unhighlight
      @highlight.hide
    end

    def editable?
      false
    end

    def landscape?
      @o == :l
    end

    def portrait?
      @o == :p
    end

    def square?
      @o == :s
    end

    def resize dx, dy
      new_height = nil
      new_width = nil

      if !dx.to_i.zero?
        new_width = @width + dx

        new_height = if landscape?
          @width * @r
        elsif portrait?
          @width / @r
        else
          @width
                     end
      else
        new_height = @height + dy

        new_width = if landscape?
          @height / @r
        elsif portrait?
          @height * @r
        else
          @height
        end
      end

      @height = new_height
      @width = new_width

      @image.width = @width
      @image.height = @height

      @highlight.resize_to @width + 10, @height + 10
    end

    def hover_on x, y
    end

    def hover_off x, y
    end

    def mouse_up x, y, button
      @listener.instance_eval @script if @listener && @script
    end

    def mouse_down x, y, button
    end

    private

    def render!
      @highlight = Border.new(
        z: @z,
        x: @x - 5,
        y: @y - 5,
        width: @width + 10,
        height: @height + 10,
        thickness: 5,
        color: 'black')

      @highlight.hide

      @image = Image.new(
        @path,
        x: @x,
        y: @y,
        z: @z
      )

      if @width.zero? # didn't receive a width from opts
        @width = @image.width
        @height = @image.height
      else
        @image.width = @width
        @image.height = @height
      end

      @highlight.width = @width + 10
      @highlight.height = @height + 10

      proportions!

      @rendered = true
    end

    def proportions!
      @o = if @width > @height
             :l
           elsif @width < @height
             :p
           else
             :s
           end

      @r = if landscape?
             @height.to_f / @width
           elsif portrait?
             @width.to_f / @height
           else
             1.0
           end
    end
  end
end
