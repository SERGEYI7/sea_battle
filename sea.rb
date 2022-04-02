# frozen_string_literal: true

class SeaBattle
  COLUMNS = ('a'..'j').to_a.freeze
  ROWS = (0..9).to_a.freeze
  STATUSES = {
    empty: :empty,
    busy: :busy,
    destroyed: :destroyed,
    missed: :missed
  }.freeze
  ASSIGNED_SHIPS = {
    single_ships: { length_ships: 1, number_ships: 4 },
    double_ships: { length_ships: 2, number_ships: 3 },
    triple_ships: { length_ships: 3, number_ships: 2 },
    quarter_ships: { length_ships: 4, number_ships: 1 }
  }.freeze

  attr_reader :list_ships, :free_cell

  def initialize
    @field = []
    @list_ships = []
    @free_cell = []
    generate_free_cell
    building_field
    generate_random_ships
  end

  def building_field
    ROWS.each do |row|
      (0...COLUMNS.length).each do |column|
        @field << { column: column, row: row, status: STATUSES[:empty] }
      end
    end
  end

  def view_all_ships
    clone_field = Marshal.load(Marshal.dump(@field))
    clone_field.each do |cell|
      @list_ships.each do |cell_ships|
        cell[:status] = STATUSES[:busy] if cell_ships[:row] == cell[:row] && cell_ships[:column] == cell[:column]
      end
    end
    clone_field
  end

  def fire(column, row)
    column = COLUMNS.index(column)
    @list_ships.each do |ship_cell|
      next unless ship_cell.fetch(:column) == column && ship_cell.fetch(:row) == row

      @field.find { |cell| cell[:column] == column && cell[:row] == row }[:status] = STATUSES[:destroyed]
      @list_ships.delete(ship_cell)

      return
    end
    @field.find { |cell| (cell[:column] == column) && (cell[:row] == row) }[:status] = STATUSES[:missed]
  end

  def generate_random_ships
    ASSIGNED_SHIPS.reverse_each do |_, value|
      length = value[:length_ships]

      value[:number_ships].times do
        random_direction = %i[column row].sample
        free_zone = free_direction_zone(length)

        if free_zone[random_direction].empty?
          random_direction = random_direction == :row ? :column : :row
        end

        rand_cell = free_zone[random_direction].sample
        rand_column = rand_cell[:column]
        rand_row = rand_cell[:row]
        ships_buffer = []

        length.times do
          if ships_buffer.empty?
            coordinate = { column: rand_column, row: rand_row }
          else
            coordinate = ships_buffer.last.clone
            coordinate[random_direction] += 1
          end

          ships_buffer << coordinate
          @list_ships << coordinate

          delete_not_free_cell(coordinate[:column], coordinate[:row])
        end
      end
    end
  end

  def command
    puts "\nEnter the coordinates of the ship:"

    input = gets.chomp

    if %w[surrender s].any? { |command_view_all| input.downcase == command_view_all }
      puts 'What a shame…'

      draw(field = view_all_ships)

      exit
    else
      column = input[/.*[A-z]/]&.downcase
      row = input[/[0-9].*/] 
      scan_fail = !row.to_i.between?(1, COLUMNS.length) ||
                  !COLUMNS.include?(column) || column.length != 1

      if scan_fail
        puts 'Ошибка координаты!'
      else
        row = row.to_i - 1

        fire(column, row)

        draw
      end
    end
  end

  def start
    draw

    loop do
      command

      if @list_ships.empty?
        puts 'You win!'

        break
      end
    end
  end

  def draw(field = @field)
    puts ' ' * 4 + COLUMNS.join(' ')
    array_row = []

    ROWS.each do |row|
      array_row << (row == 9 ? "#{row + 1}  " : "#{row + 1}   ")

      (0..9).to_a.each do |column|
        cell = field.find { |cell| cell[:row] == row && cell[:column] == column }

        case cell[:status]
        when STATUSES[:empty]
          array_row << '. '
        when STATUSES[:destroyed]
          array_row << 'X '
        when STATUSES[:missed]
          array_row << 'O '
        when STATUSES[:busy]
          array_row << 'S '
        end
      end

      array_row << "\n"
    end

    puts array_row.join('')
  end

  private

  def generate_free_cell

    ROWS.each do |row|

      (0...COLUMNS.length).to_a.each do |column|
        @free_cell << { row: row, column: column }
      end
    end
  end

  def contact_zone(column, row)
    states = [0, 1, -1]
    result = []

    states.each do |state_row|
      states.each do |state_column|
        result << { column: column + state_column, row: row + state_row }
      end
    end
    
    result
  end

  def delete_not_free_cell(column, row)

    contact_zone(column, row).each do |cell|
      @free_cell.delete(cell)
    end
  end

  def free_direction_zone(length)
    directions = {}

    %i[column row].each do |direction|
      directions[direction] = []

      @free_cell.each do |cell|
        row = cell[:row]
        column = cell[:column]
        next_cells = []

        length.times do

          if next_cells.empty?
            next_cells << cell
          else
            next_cell = next_cells.last.clone
            next_cell[direction] += 1
            next_cells << next_cell
          end
          column_in_range = next_cells.last[:column].between?(0, COLUMNS.length - 1)
          row_in_range = next_cells.last[:row].between?(0, ROWS.length - 1)

          contact = contact_zone(next_cells.last[:column], next_cells.last[:row]).any? do |cell|
            @list_ships.include?(cell)
          end

          if !column_in_range || !row_in_range || contact
            cell = nil

            break
          end
        end
        directions[direction] << cell unless cell.nil?
      end
    end

    directions
  end
end

sea = SeaBattle.new
sea.start
