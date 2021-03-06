module Ruby2D
  class Checklist
    attr_reader :z, :x, :y, :width, :height, :items
    attr_accessor :tag

    def initialize opts = {}
      @tag = opts[:tag]
      @rendered = false
      @visible = false
      @z = opts[:z]
      @x = opts[:x]
      @y = opts[:y]
      @width = opts[:width] || 0
      @height = opts[:height] || 0
      @suggested_width = opts[:suggested_width]
      @items = opts[:items]
    end

    def selected
      item = @rendered_items.find { |item| item.respond_to?(:checked?) && item.checked? }
      item.tag if item
    end

    def checked
      selected
    end

    def checked= tag
      c = @rendered_items.find { |item| item.respond_to?(:check) && item.tag == tag }

      c.check
    end

    def add
      if @rendered
        @border.add
        @content.add
        @rendered_items.each { |r| r.add }
      else
        render!
      end

      @visible = true

      self
    end

    def remove
      @border.remove
      @content.remove
      @rendered_items.each { |r| r.remove }

      @visible = false

      self
    end

    def mouse_up x, y, button
      elem = @rendered_items.find { |item| item.visible? && item.contains?(x, y) }

      if elem
        @rendered_items.each { |item| item.uncheck if item.respond_to? :uncheck }

        if elem.respond_to? :check
          elem.check
        else
          c = @rendered_items.find { |item| item.respond_to?(:check) && item.tag == elem.tag }

          c.check
        end
      end
    end

    def mouse_down x, y, button; end
    def hover_on x, y; end
    def hover_off x, y; end

    def contains? x, y
      (@x..(@x + @width)).cover?(x) &&
        (@y..(@y + @height)).cover?(y)
    end

    def visible?
      @visible
    end

    private

    def items!
      x_offset = 0
      y_offset = 0
      largest_width = 0

      @rendered_items = []

      @items.each do |item|
        if @suggested_width && x_offset + 50 > @suggested_width
          x_offset = 0
          y_offset += @height + 4
        end

        c = Checkbox.new(
          tag: item,
          z: @z,
          x: @x + x_offset,
          y: @y + y_offset
        ).add

        l = Label.new(
          tag: item,
          text: item,
          z: @z,
          x: c.x + c.width + 5,
          y: @y + y_offset + 1
        ).add

        @rendered_items += [c, l]

        w = c.width + l.width + 10

        x_offset += w

        largest_width = x_offset if x_offset > largest_width

        resize! largest_width, y_offset + l.height + (@border.thickness * 2)
      end
    end

    def resize! w, h
      @width = w + (@border.thickness * 2)
      @height = h + (@border.thickness * 2)

      @content.width = w
      @content.height = h

      @border.resize_to @width, @height
    end

    def render!
      @border = Border.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height,
        color: 'black'
      )

      @border.hide

      @content = Rectangle.new(
        z: @z,
        x: @x + @border.thickness,
        y: @y + @border.thickness,
        width: @width - (@border.thickness * 2),
        height: @height - (@border.thickness * 2)
      )

      items!

      @rendered = true
    end
  end
end
