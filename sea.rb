# frozen_string_literal: true

class SeaBattle

  # добавь сюда константы
  COLUMNS = ('a'..'z').to_a.freeze
  ROWS = (1..10).to_a.freeze
  attr_accessor :win

  def initialize(x=10, y=10)
    @x = x
    @y = y
    @win = false
    @alphabet = nil
    @matrix = nil
    @list_ships = []
    @wrecked_ships = []
    building_field
    randship
  end

  def building_field
    @alphabet = COLUMNS[0...@x]
    @x_field = @alphabet.map.each_with_index {|letter, index| [letter, index]}.to_h
    @matrix = []
    for i in @y.times
      @matrix.append(['.' * @x])
    end

  end

  def view_all_ships
    clone_matrix = Marshal.load(Marshal.dump(@matrix))
    for x_oxis, y_oxis in @list_ships.flatten(1)
      new_string = clone_matrix[y_oxis][0].split('')
      new_string[x_oxis-1] = 'S' if new_string[x_oxis-1] == '.'
      new_string = new_string.join('')
      clone_matrix[y_oxis][0] = new_string
    end
    clone_matrix
  end

  def fire(let, num)
    for i in @list_ships.flatten(1)
      if i == [@x_field[let]+1, num]
      # if i == [@x_field[let.upcase], num]
        @matrix[num][0][@x_field[let]] = 'X'
        @wrecked_ships.append(i)

        break
      end

      @matrix[num][0][@x_field[let]] = 'O'
    end  
    
    # этот код нужно переместить в другое место, функция fire должна только бить а не обьявлять победу
    if @list_ships.flatten(1).sort == @wrecked_ships.sort
      # puts "You win!"
      @win = true
    end

  end

  def randship
    # rand_count_ships = rand(3..6)
    parameters = [1, 1, 1, 1, 2, 2, 2, 3, 3, 4]
    while @list_ships.length < parameters.length
      rand_xy = rand(0..1)
      rand_length = parameters[@list_ships.length-1]
      rand_plus_minus = [1, -1].sample
      rand_x = rand((1..@x))
      # rand_y = rand((0...@y))
      rand_y = rand((1..@y))
      @list_ships.append([])
      rand_length.times.each do
        if @list_ships[-1].empty?
          coordinate = [rand_x, rand_y]
        else
          coordinate = @list_ships[-1][-1].clone
          coordinate[rand_xy] +=  rand_plus_minus
        end
        list_ships_include_coordinate = @list_ships.flatten(1).include?(coordinate)
        x_in_range = coordinate[0].between?(1, @x)
        y_in_range = coordinate[1].between?(0, @y-1)
        if list_ships_include_coordinate || ! x_in_range || ! y_in_range
          @list_ships.delete_at(-1)
          break
        end
        @list_ships[-1].append(coordinate)
      end
      if !@list_ships.empty?
        for i_last_ships in @list_ships[-1]
          for i_contact in contact_zone(i_last_ships)
            if @list_ships[0..-2].flatten(1).include?(i_contact)
              @list_ships.delete_at(-1)
              break 
            end
          end
        end
      end
    end
  end

  def command
    puts "\nEnter the coordinates of the ship:"
    inp = gets.chomp
    if inp.downcase == "surrender"
      puts "What a shame…"
      draw(view_all_ships)
    else
      let, num = inp.scan(/[a-z]/).join(''), inp.scan(/[0-9]/).join('')
      p num
      if not num.to_i.between?(1, @y)
        raise "Ошибка координаты >#{inp}<"
      elsif not @alphabet.include?(let.downcase)
        raise "Ошибка координаты >#{let}<"
      else
        num = num.to_i - 1
      end

      fire(let, num)
      draw
    end
  end

  def start
    @clone_list_ships = Marshal.load(Marshal.dump(@list_ships))
    draw
    while true
      # begin
        command
      # rescue => err
        # p err
      # end
      if @win
        break
      end
    end
  end

  private

  def draw(mx=@matrix)
    size_last_i = mx.length.to_s.length+2
    puts ' ' * size_last_i + @alphabet.join(' ')
    for a, i in mx.each_with_index
      i += 1
      a = a[0].split('').join(' ')
      puts (i).to_s+' '*(size_last_i - i.to_s.length)+a
    end
  end

  def contact_zone(xy)
    x, y = xy
    contact = [[x-1, y], [x+1, y], [x, y-1], [x, y+1], [x-1, y+1], [x-1, y-1], [x+1, y+1], [x+1, y-1]]
  end

end

# sea = SeaBattle.new
# sea.start

def tests(cls)
  a = []
  alphabet = ('a'..'z').to_a[0..9]
  for arr, i_view_all_ships in cls.view_all_ships.each_with_index
      arr_m = arr[0].split('')
      if arr_m.include?('S')
          # a.append([i_view_all_ships])
          for value, i_in_field in arr_m.each_with_index
              if value == "S"
                  # a.append([i_in_field+1, i_view_all_ships+1])
                  a.append([alphabet[i_in_field], i_view_all_ships+1])
              end
          end
      end
  end
  a
end
# # p alphabet

# 10000.times.each {a.each {|let, num| sea.fire(let, num-1)}}
100.times.each do |let, num|
  test_sea = SeaBattle.new
  a = tests(test_sea)
  a.each {|let, num| test_sea.fire(let, num-1)}
  if !test_sea.win
    p "Ошибка"
    break
  end
end