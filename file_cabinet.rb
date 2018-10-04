module Ruby2D
  class FileCabinet
    attr_reader :z

    def initialize opts = {}
      @visible = false
      @path = Dir.pwd
      @rendered = false
      @intent = opts[:intent]
      @action = opts[:action].to_sym
      @listener = opts[:listener]
      @background_width = opts[:background_width]
      @background_height = opts[:background_height]
      @x = 0
      @y = 0
      @width = @background_width
      @height = @background_height
      @z = 4000
    end

    def objectify
      [self] + @list.objectify
    end

    def visible?
      @visible
    end

    def remove
      @background.remove
      @list.remove

      @visible = false

      self
    end

    def add
      if @rendered
        @background.add
        @list.add
      else
        render!
      end

      @visible = true

      self
    end

    def choose item
      if item.end_with? '/'
        item = item.split('/').first

        @path = File.expand_path(File.join(@path, item))

        if Dir.exist? @path
          old = @list.rendered_items.dup

          @list.items = entries

          new = @list.rendered_items

          @listener.send :replace_objects, old, new
        else
          raise 'dir'
        end
      else
        FileMagic.mime { |fm|
          path = File.expand_path(File.join(@path, item))
          res = fm.file(path).match /^#{Regexp.quote(@intent.to_s)}/

          @listener.send @action, path if @listener && @action
        }
      end
    end

    def translate x, y
    end

    def resize x, y
    end

    def contains? x, y
      (@x..(@x + @width)).cover?(x) &&
        (@y..(@y + @height)).cover?(y)
    end

    def hover_on x, y
    end

    def hover_off x, y
    end

    def mouse_down x, y, button
    end

    def mouse_up x, y, button
    end

    private

    def render!
      @background = Rectangle.new(
        z: @z,
        x: 0,
        y: 0,
        width: @background_width,
        height: @background_height,
        color: 'white'
      )

      @background.opacity = 0.5

      @list = List.new(
        listener: self,
        z: 4000,
        x: (@background_width / 2) - (@background_width / 4),
        y: (@background_height / 2) - (@background_height / 4),
        width: @background_width / 2,
        height: @background_height / 2 + 2,
        items: entries
      )

      @list.add

      @rendered = true
    end
  end

  def entries
    Dir.entries(@path).reject do |e|
      ['.', '.DS_Store'].include?(e)
    end.map do |e|
      Dir.exist?("#{@path}/#{e}") ? "#{e}/" : e
    end
  end
end
