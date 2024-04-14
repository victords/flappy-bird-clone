require 'minigl'

class Bird < MiniGL::GameObject
  attr_reader :score

  def initialize
    super(50, 200, 20, 20, :bird, MiniGL::Vector.new(-3, -3), 1, 1, 1, true)
    @ceiling = MiniGL::Block.new(0, -1, 400, 1)
    @score = 0
  end

  def update(pipes)
    forces = MiniGL::Vector.new
    if MiniGL::KB.key_pressed?(Gosu::KB_UP)
      @speed.y = 0
      forces.y -= 7
    end
    move(forces, [@ceiling], [])

    if (pipe = pipes.find { |p| p.flipped && !p.scored && @x > p.x + p.w })
      pipe.scored = true
      @score += 1
    end
    @y >= 400 || pipes.any? { |p| p.bounds.intersect?(bounds) }
  end
end

class Pipe < MiniGL::GameObject
  attr_reader :flipped
  attr_accessor :scored

  def initialize(y, h, flipped = false)
    super(400, y, 40, h, :pipe, nil, 1, 2, 1, true)
    @flipped = flipped
  end

  def draw
    if @flipped
      @img[0].draw(@x, @h - 20, 1, 2, 2)
      (0...(@h - 20)).step(20).each { |y| @img[1].draw(@x, y, 0, 2, 2) }
    else
      @img[0].draw(@x, @y, 1, 2, 2)
      ((@y + 20)...(@y + @h)).step(20).each { |y| @img[1].draw(@x, y, 0, 2, 2) }
    end
  end
end

class Window < MiniGL::GameWindow
  def initialize
    super(400, 400, false, MiniGL::Vector.new(0, 0.6))
    @font = Gosu::Font.new(24, name: 'DejaVu Sans')
    @bg = MiniGL::Res.img(:bg, false, false, '.png', true)
    restart
  end

  def restart
    @bird = Bird.new
    @pipes = generate_pipes
    @timer = 0
    @dead = false
  end

  def generate_pipes
    y = rand(110..300)
    [Pipe.new(y, 400 - y), Pipe.new(0, y - 90, true)]
  end

  def update
    MiniGL::KB.update
    if @dead
      restart if MiniGL::KB.key_pressed?(Gosu::KB_R)
      return
    end

    @timer += 1
    if @timer >= 90
      @pipes += generate_pipes
      @timer = 0
    end
    @pipes.reverse_each do |pipe|
      pipe.x -= 3
      @pipes.delete(pipe) if pipe.x + pipe.w < 0
    end
    @dead = @bird.update(@pipes)
  end

  def draw
    @bg.draw(0, 0, 0, 2, 2)
    @bird.draw(nil, 2, 2, 255, 0xffffff, 5 * @bird.speed.y)
    @pipes.each(&:draw)
    @font.draw_text("Score: #{@bird.score}", 150, 5, 10, 1, 1, 0xffff0000)
    @font.draw_text('Press R to restart', 100, 180, 10, 1, 1, 0xffff0000) if @dead
  end
end

Window.new.show
