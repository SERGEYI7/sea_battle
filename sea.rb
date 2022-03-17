class SeaBattle

    def initialize(x, y)
        @x = x
        @y = y
        @win = false
        @alphabet = nil
        @matrix = nil
        @wrecked_ships = []
        field_building
        randship
    end

    def field_building
        @alphabet = ('A'..'Z').to_a[0...@x]
        @x_field = @alphabet.map.each_with_index {|letter, index| [letter, index]}.to_h
        @matrix = []
        for i in @y.times
            @matrix.append(['.' * @x])
        end
    end

    def view_all_ships
        clone_matrix = Marshal.load(Marshal.dump(@matrix))
        puts "What a shame…"
        for x_oxis, y_oxis in @list_ships.flatten(1)
            new_string = clone_matrix[y_oxis-1][0].split('')
            new_string[x_oxis-1] = 'S' if new_string[x_oxis-1] == '.'
            new_string = new_string.join('')
            clone_matrix[y_oxis-1][0] = new_string
        end
        draw(clone_matrix)
    end

    def fire(let, num)
        
        for i in @list_ships.flatten(1)
            if i == [@x_field[let.upcase]+1, num+1]
                @matrix[num][0][@x_field[let.upcase]] = 'x'
                @wrecked_ships.append(i)
                break
            end
            @matrix[num][0][@x_field[let.upcase]] = 'o'
        end
        p "@list_ships.flatten(1) = #{@list_ships.flatten(1)}"
        p "@wrecked_ships = #{@wrecked_ships}"
        if @list_ships.flatten(1).sort == @wrecked_ships.sort
            puts "You win!"
            @win = true
        end
    end

    def randship
        @list_ships = []
        rand_count_ships = rand(3..6)
        count_loop = 0
        parameters = [1,1,1,1,2,2,2,3,3,4]
        while @list_ships.length < parameters.length
            count_loop -= 1
            rand_xy = rand(0..1)
            rand_length = parameters[@list_ships.length-1]
            rand_plus_minus = [1, -1].sample
            rand_x = rand((0..@x))
            rand_y = rand((0..@y))
            @list_ships.append([])
            count = 0
            for j in rand_length.times
                if @list_ships[-1] == []
                    coordinate = [rand_x, rand_y]
                else
                    coordinate = @list_ships[-1][-1].clone
                    coordinate[rand_xy] +=  rand_plus_minus
                end
                list_ships_include_coordinate = @list_ships.flatten(1).include?(coordinate)
                x_in_range = coordinate[0].between?(1, @x)
                y_in_range = coordinate[1].between?(0, @y)
                if list_ships_include_coordinate or not x_in_range or not y_in_range
                    count_loop -= 1
                    @list_ships.delete_at(-1)
                    break
                end
                @list_ships[-1].append(coordinate)
                count += 1
            end
            begin
                for i_last_ships in @list_ships[-1]
                    for i_contact in contact_zone(i_last_ships)
                        if @list_ships[0..-2].flatten(1).include?(i_contact)
                            count_loop -= 1
                            @list_ships.delete_at(-1)
                            break 
                        end
                    end
                end
            
            rescue
            end
        end
    end

    def command
        inp = STDIN.gets.chomp
        let, num = inp.scan(/[a-z]/).join(''), inp.scan(/[0-9]/).join('')
        if inp.upcase == "S"
            view_all_ships
        else
            if num.to_i.between?(1, @y)
                num = num.to_i - 1
            else
                raise "Ошибка координаты >#{num}<"
            end
            if not @alphabet.include?(let.upcase)
                raise "Ошибка координаты >#{num}<"
            end
            fire(let, num)
            draw
        end
    end

    def start
        @clone_list_ships = Marshal.load(Marshal.dump(@list_ships))
        #p @list_ships.length
        #p @matrix
        draw
        while true
            begin
                command
            rescue => err
                p err
            end
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
        for i in contact
            if @list_ships.include?(i)
                result = false
                break
            end
        end
        result = true
        contact
    end

end

sea = SeaBattle.new(10, 10)
sea.start