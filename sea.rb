# frozen_string_literal: true

class SeaBattle

  COLUMNS = ('a'..'z').to_a[0..9].freeze
  ROWS = (0..9).to_a.freeze
  attr_accessor :win, :list_ships, :wrecked_ships, :free_cell

  def initialize()
    @matrix = []
    @list_ships = []
    @wrecked_ships = []
    @free_cell = []
    generate_free_cell
    building_field
    generate_random_ships
  end

  def building_field
    @x_field = COLUMNS.map.each_with_index {|letter, index| [letter, index]}.to_h
    ROWS.length.times.each {@matrix.append(['.'] * COLUMNS.length)} 
  end

  def view_all_ships
    clone_matrix = Marshal.load(Marshal.dump(@matrix))
    @list_ships.flatten(1).each do |x_oxis, y_oxis|
      new_string = clone_matrix[y_oxis]
      new_string[x_oxis] = 'S' if new_string[x_oxis] == '.'
      clone_matrix[y_oxis] = new_string
    end

    clone_matrix
  end

  def fire(let, num)
    @list_ships.flatten(1).each do |coordinate_cell|
      if coordinate_cell == [@x_field[let], num]
        @matrix[num][@x_field[let]] = 'X'
        @wrecked_ships.append(coordinate_cell)

        break
      end

      @matrix[num][@x_field[let]] = 'O'
    end  

  end

  def generate_random_ships
    assigned_ships = {single_ships: {length_ship: 1, number_ships: 4}, double_ships: {length_ship: 2, number_ships: 3},
    triple_ships: {length_ship: 3, number_ships: 2}, quarter_ships: {length_ship: 4, number_ships: 1}}
    # number_ships = assigned_ships.each_value.map {|value| value[:number_ships]}.sum
    length_ships = assigned_ships.each_value.map {|value| [value[:length_ship]] * value[:number_ships]}.flatten
    length_ships.reverse.each do |length|
      random_direction = rand(0..1)
      free_zone = free_direction_zone(length)
      if free_zone[random_direction].empty?
        random_direction = random_direction == 0 ? 1 : 0
      end
      
      rand_x, rand_y = free_zone[random_direction].sample
      if [rand_x, rand_y] == [nil, nil]
        p "Нет больше клеток в этом направлениии!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        next 
      end

      @list_ships.append([])
      length.times.each do
        if @list_ships[-1].empty?
          coordinate = [rand_x, rand_y]
        else
          coordinate = @list_ships[-1][-1].clone
          coordinate[random_direction] +=  1
        end

        @list_ships[-1].append(coordinate)
        delete_not_free_cell(coordinate)
      end

    end
    
  end

  def command
    puts "\nEnter the coordinates of the ship:"
    inp = gets.chomp
    if ["surrender", "s"].any? {|letter| inp.downcase == letter}
      puts "What a shame…"
      draw(view_all_ships)
    else
      let, num = inp.scan(/[a-z]/).join(''), inp.scan(/[0-9]/).join('')
      p num
      if not num.to_i.between?(1, COLUMNS.length)
        raise "Ошибка координаты >#{inp}<"
      elsif not COLUMNS.include?(let.downcase)
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
      begin
        command
      rescue => err
        p err
      end

      if @list_ships.flatten(1).sort == @wrecked_ships.sort
        puts "You win!"
        break
      end

    end

  end

  def draw(mx=@matrix)
    size_last_i = mx.length.to_s.length+2
    puts ' ' * size_last_i + COLUMNS.join(' ')
    mx.each_with_index do |rows, index|
      index += 1
      puts (index).to_s+' '*(size_last_i - index.to_s.length)+rows.join(' ')
    end

  end

  private

  def generate_free_cell
    COLUMNS.length.times.each do|num1|
        ROWS.length.times.each {|num2| @free_cell.append([num1, num2])}
    end

  end

  def contact_zone(xy)
    x, y = xy
    contact = [[x, y], [x-1, y], [x+1, y], [x, y-1], [x, y+1], [x-1, y+1], [x-1, y-1], [x+1, y+1], [x+1, y-1]]
  end


  def delete_not_free_cell(xy)
    contact_zone(xy).each do |arr|
      @free_cell.delete_at(@free_cell.index(arr)) if @free_cell.index(arr) != nil
    end

  end
  
  def free_direction_zone(length)
    directions = {}
    2.times.each do |direction|
      directions[direction] = []
      @free_cell.each do |cell|
        next_cells = []
        length.times.each do      
          if next_cells.empty?
            next_cells.append(cell)
          else
            next_cell = next_cells[-1].clone
            next_cell[direction] += 1
            next_cells.append(next_cell)
          end
          
          x_in_range = next_cells[-1][0].between?(0, COLUMNS.length-1)
          y_in_range = next_cells[-1][1].between?(0, ROWS.length-1)
          contact = contact_zone(next_cells[-1]).any? {|element| @list_ships.flatten(1).include?(element)}
          list_ships_include_coordinate = @list_ships.flatten(1).include?(next_cells[-1])
          if contact || !x_in_range || !y_in_range
            cell = nil
            break

          end

        end

        if cell != nil
          directions[direction].append(cell)
        end

      end

    end

    directions
  end

end
  
sea = SeaBattle.new
sea.start

def tests(cls)
  a = []
  alphabet = ('a'..'z').to_a[0..9]
  cls.view_all_ships.each_with_index.each do |arr, i_view_all_ships|
    arr_m = arr
    if arr_m.include?('S')
      arr_m.each_with_index.each do |value, i_in_field|
        if value == "S"
          a.append([alphabet[i_in_field], i_view_all_ships+1])
        end

      end

    end

  end

  a
end

count = 100
count.times.each_with_index do |index|
  test_sea = SeaBattle.new
  a = tests(test_sea)
  # p "list_ships <==> #{test_sea.list_ships} <==>"
  # p "free_cell <==> #{test_sea.free_cell} <==>"
  # test_sea.draw(test_sea.view_all_ships)
  a.each {|let, num| test_sea.fire(let, num-1)}
  if !(test_sea.list_ships.flatten(1)-test_sea.wrecked_ships).empty?
    p "Ошибка"
    break
  end

  if index == count-1
    puts "Ошибок Нет!!!)))"
  end

end