# Name: 8queens.rb
# By:   Ibrahim Sardar
# What: 8 queens problem
#       Hw1 for CS487 (A.I.)
#

# note:
#  .dup    :  shallow copy (refs not copied)
#  .clone  :  deep copy (refs are also copied)
#  #eom    :  end of module
#  #eof    :  end of function
#  #eoc    :  end of class



# housekeeping
require 'rubygems'
require 'gosu'


# tracking
$QUEENMOVES = 0


# window
W, H = 600,600



# COMMAND LINE ARGUMENT EXTRACTION:  (Messy!)
# -------------------------------- #

# Parse: extract command line arguments
if ARGV[0] != nil

    # positions of each queen
    QUEENPLACEMENTS = []

    # input type
    if ARGV[0] != "random"
        # format: "x,y...x2,y2..."..."...x7,y7"  ==>  [ [x,y], [x2,y2],...,[x7,y7] ]
        tmp_coords = ARGV[0].split("...")
        tmp_cords = tmp_coords[0..7] # chop off 9th or more element
        for i in 0..(tmp_coords.size-1)
            flag = false
            arr = tmp_coords[i].split(",")
            # remove queens in same column
            for j in QUEENPLACEMENTS
                if j[0] == arr[0].to_i
                    flag = true
                    break
                end
            end
            if flag
                puts "\nAn invalid queen was removed..."
                next
            end
            QUEENPLACEMENTS.push( arr )
            QUEENPLACEMENTS[i][0] = QUEENPLACEMENTS[i][0].to_i
            QUEENPLACEMENTS[i][1] = QUEENPLACEMENTS[i][1].to_i
        end
        for j in QUEENPLACEMENTS
            if j[0] > QUEENPLACEMENTS.size-1 ||
               j[1] > QUEENPLACEMENTS.size-1
               puts "\n1 or more queen(s) are off the board.\nAborting...\n\n"
               ABORT = true
               break
           end
        end
        RANDOMIZED = false
    else
        RANDOMIZED = true
    end

    # number of queens
    if ARGV[1] != nil
        N = ARGV[1].to_i
    elsif QUEENPLACEMENTS.size > 0
        N = QUEENPLACEMENTS.size
    else
        N = 8
    end

    # random seed
    if ARGV[2] != nil
        SEED = ARGV[2].to_i
    else
        SEED = 0
    end

else
    # default settings: (8 queens, random initialization)
    RANDOMIZED = true
    N = 8
    SEED = 0

end
# -------------------------------- #




# all media files
module Media
    Tile = "tile.png"
    Queen = "queen.png"
    Whitespace = "white.png"
    Cursor = "aztec_cursor.png"
end #eom


# order of graphics placement
module UpdateOrder
    BG = 0
    Tile = 1
    Queen = 2
    UI = 3
    Cursor = 4
end #eom


# State: a tile of the board
class Tile

    attr_accessor :x, :y, :occupier, :mapx, :mapy
    attr_reader :w, :h

    def initialize(img_file)
        @image = Gosu::Image.new(img_file, :retro => true)
        @w = @image.width
        @h = @image.height
        @x = -1 * @w
        @y = -1 * @h
        @conflicts = 0
    end #eof

    def update
        # ...
    end #eof

    def draw
        @image.draw(@x, @y, UpdateOrder::Tile)
    end #eof

    def occupy(q)
        @occupier = q
    end #eof

    def leave
        @occupier = nil
    end

    def hit(amt=1)
        @conflicts += amt
    end #eof

    def hits
        return @conflicts
    end #eof

    def clear
        @conflicts = 0
    end #eof

    def valid(queen)
        for t in queen.invalid_moves
            if t == self
                return false
            end
        end
        return true
    end #eof

end #eoc

# Environment: the graph which represents the chess board
class Board

    # w: tiles left to right
    # h: tiles top to bottom
    attr_accessor :w, :h

    # initialize board
    def initialize(xp,yp,w,h,tile)

        # init accessors
        @w = w-1
        @h = h-1

        # matrix holding board information
        @map = []

        # indicates if 8queens is solved on this board
        @final_state = false

        # seed random for reproducibility
        srand SEED

        # create the matrix
        (0..@w).each do |x|
            sub_map = []
            @map.push(sub_map)
            (0..@h).each do |y|
                newt = tile.dup
                newt.x = x * (tile.w-3) + xp
                newt.y = y * (tile.h-3) + yp
                newt.mapx = x
                newt.mapy = y
                sub_map.push( newt )
            end
        end
    end #eof

    # ==========================================================================
    # --------------------------------------------------------------------------
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    #
    #   HW #1 INITIALIZE FUNCTION:
    #
    #       initialize N random queen placements using min-conflict strategy
    #
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    # --------------------------------------------------------------------------
    # ==========================================================================
    def initialize_random(queen_list, amt)

        # init the board
        curr_queen = nil
        tmp_min_tiles = []
        tmp_min_hits = 0
        for col in (0..@map.size-1)

            # update conflicts throughout board from this queen
            if col != 0
                curr_queen.update_conflicts()
            end

            # create queen
            curr_queen = Queen.new( Media::Queen )
            queen_list.push( curr_queen )

            # find min-conflict row in current column
            tmp_min_tiles = []
            tmp_min_hits = 99999999
            for row in (0..@map[col].size-1)
                curr_tile = @map[col][row]
                if tmp_min_hits > curr_tile.hits
                    tmp_min_hits = curr_tile.hits
                    tmp_min_tiles = [] #clear it!
                    tmp_min_tiles.push(curr_tile)
                elsif tmp_min_hits == curr_tile.hits
                    tmp_min_tiles.push(curr_tile)
                end
            end

            # place queen at random tile from set of
            #  min-conflicted tiles in current column
            rnd_index = rand(tmp_min_tiles.size)
            choice = tmp_min_tiles[rnd_index]
            self.place( curr_queen, choice )

            # make the queen understand its environment
            curr_queen.learn(self)
        end

        # update hits by last queen selected
        #  (since it wasn't needed in the placement)
        curr_queen.update_conflicts()

    end #eof

    def update
        # ...
    end #eof

    # render all tiles
    def draw
        (0..@w).each do |x|
            (0..@h).each do |y|
                @map[x][y].draw
            end
        end
    end #eof

    # print board hits
    def print_hits
        puts " ~ Hit Map: ~ \n"
        (0..h).each do |y|
            (0..w).each do |x|
                print @map[x][y].hits.to_s + " "
            end
            print "\n"
        end
    end #eof

    # clear all conflicts
    def clear_hits
        (0..h).each do |y|
            (0..w).each do |x|
                @map[x][y].clear()
            end
        end
    end #eof

    # updates all of a queen's conflicts
    def update_hits(queens)
        for q in queens
            q.update_conflicts()
        end
    end #eof

    # ==========================================================================
    # --------------------------------------------------------------------------
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    #
    #   HW #1 SEARCH FUNCTION:
    #
    #       find random queen that is in conflict
    #
    #
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    # --------------------------------------------------------------------------
    # ==========================================================================
    def search_next_and_move(index, queen_list)

        last_queen = queen_list[index]
        next_index = -1
        while true
            next_index = rand(queen_list.size)
            if queen_list[next_index] != last_queen &&
               queen_list[next_index].tile.hits > 0
                break
            end
        end

        # if conflict found,
        #  move queen randomly to lowest
        #   conflict tile which is
        #    not the current tile in this column.
        if next_index != -1

            # find set of min-conflict row in current column
            #  (excluding current queen's tile)
            curr_queen = queen_list[next_index]
            curr_tile = curr_queen.tile
            curr_col = curr_queen.mapx
            tmp_min_hits = 9999999
            tmp_min_tiles = []
            for i in 0..@map[curr_col].size-1
                if @map[curr_col][i] != curr_tile
                    curr_hits = @map[curr_col][i].hits
                    if tmp_min_hits > curr_hits
                        tmp_min_hits = curr_hits
                        tmp_min_tiles = [] # clear it!
                        tmp_min_tiles.push(@map[curr_col][i])
                    elsif tmp_min_hits == curr_hits
                        tmp_min_tiles.push(@map[curr_col][i])
                    end
                end
            end

            # place queen at random tile from set of
            #  min-conflicted tiles in current column
            # re-calculate hits (Optimized)
            rnd_index = rand(tmp_min_tiles.size)
            choice = tmp_min_tiles[rnd_index]
            curr_queen.revert_conflicts()
            self.place( curr_queen, choice )
            curr_queen.update_conflicts()

            # return index of this queen
            #  (in the queen's list)
            return curr_col

        else
            # else, return first queen in list
            return 0

        end
    end #eof

    def at(x, y)
        return @map[x][y]
    end #eof

    # Action: add queen to board
    def place_pos(queen, x, y)
        @map[x][y].leave()
        queen.goto( @map[x][y], @map[x][y] )
    end #eof

    # Alias: same as above
    def place(queen, tile)
        tile.leave()
        queen.goto( tile, tile )
    end #eof

    # ==========================================================================
    # --------------------------------------------------------------------------
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    #
    #   HW #1 IS_FINAL_STATE FUNCTION:
    #
    #       are all queens free of any conflict?
    #
    #
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    # --------------------------------------------------------------------------
    # ==========================================================================
    def determine_final_state(queen_list)

        for q in queen_list
            if q.tile.hits > 0
                @final_state = false
                return false
            end
        end

        @final_state = true
        return true
    end #eof

    def is_final_state
        return @final_state
    end #eof

    # Action: force final state to be true
    #  (only use for failures)
    def force_final_state
        @final_state = true
    end #eof

end #eoc

# Agent: a queen piece
class Queen

    attr_reader :w, :h, :x, :y, :tile, :mapx, :mapy

    def initialize(img_file)
        @image = Gosu::Image.new(img_file, :retro => true)
        @w = @image.width
        @h = @image.height
        @x = -1 * @w
        @y = -1 * @h
        @board = nil
    end #eof

    def update
        # ...
    end #eof

    def draw
        @image.draw(@x, @y, UpdateOrder::Queen)
    end #eof

    # make this queen learn a new environment & forget the old one
    def learn(board)
        @board = board
    end #eof

    # move to some rect object
    # optional: queen will occupy the tile
    def goto(obj, tile=nil)
        @x = obj.x
        @y = obj.y
        @mapx = tile.mapx
        @mapy = tile.mapy
        @tile = tile
        if @tile != nil
            @tile.occupy(self)
        end
    end #eof

    # get queen's pos on screen
    def pos
        { x: @tile.x,
          y: @tile.y }
    end #eof

    # get queen's pos on board
    def loc
        { x: @mapx,
          y: @mapy }
    end #eof

    # ==========================================================================
    # --------------------------------------------------------------------------
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    #
    #   HW #1 CONFLICT_COUNTING FUNCTION:
    #
    #       ignore hit at current tile
    #       hit all in current row & column
    #       hit all in current positive and negative diagonals
    #
    #
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    # --------------------------------------------------------------------------
    # ==========================================================================
    def update_conflicts(amt=1)

        # for ease
        pos = [@mapx, @mapy]

        # left to right
        i = 0
        j = @mapy
        loop do
            # stop if border reached
            if i == @board.w+1
                break
            end
            if i != @mapx
                @board.at(i,j).hit(amt)
            end
            i += 1
        end

        # top to bottom
        i = @mapx
        j = 0
        loop do
            # stop if border reached
            if j == @board.h+1
                break
            end
            if j != @mapy
                @board.at(i,j).hit(amt)
            end
            j += 1
        end

        # negative diagonal
        #  (start from topleft)
        max = pos.max
        min = pos.min
        dif = max - min

        if @mapx == max
            dx = dif
            dy = 0
        else
            dx = 0
            dy = dif
        end

        # top -> bottom
        # left -> right
        i = dx
        j = dy
        loop do
            # stop if border reached
            if i == @board.w+1 || j == @board.h+1
                break
            end
            if i != @mapx && j != @mapy
                @board.at(i,j).hit(amt)
            end
            i += 1
            j += 1
        end

        # positive diagonal
        #  (start from bottomleft)
        ht = @board.h
        y = ht - @mapy
        x = @mapx
        max = [x,y].max
        min = [x,y].min
        dif = max - min

        if x == max
            dx = dif
            dy = ht
        else
            dx = 0
            dy = ht - dif
        end

        # bottom -> top
        # left -> right
        i = dx
        j = dy
        loop do
            # stop if border reached
            if i == @board.w+1 || j < 0
                break
            end
            if i != @mapx && j != @mapy
                @board.at(i,j).hit(amt)
            end
            i += 1
            j -= 1
        end

    end #eof

    # decrements all conflicting tiles
    def revert_conflicts
        self.update_conflicts(-1)
        #@tile.hit()
    end #eof

end #eoc

# Main: controls the program
class Main < Gosu::Window

    # initialize all components
    def initialize

        # check for an abort flag
        if defined? ABORT
            abort
        end

        # window
        super W,H
        self.caption =  N.to_s + " Queens Vizualization (via Min-Conflict)"
        @bg = Gosu::Image.new(Media::Whitespace, :retro => true)
        @font = Gosu::Font.new( 16 )
        @cursor = Gosu::Image.new(Media::Cursor, :retro => true)

        # board
        @cell = Tile.new( Media::Tile )
        @board = Board.new( 32,116,N,N,@cell )

        # make all the queens
        @queens = []
        if !RANDOMIZED
            # manual input of queens init:
            for i in 0..QUEENPLACEMENTS.size-1
                q = Queen.new( Media::Queen )
                q.learn( @board )
                @board.place_pos( q, QUEENPLACEMENTS[i][0], QUEENPLACEMENTS[i][1] )
                @queens.push( q )
            end
            @board.update_hits(@queens)
        else
            # random init of queens:
            @board.initialize_random(@queens, N)
        end
        @curr_queen = @queens[0]
        @curr_index = 0

        # limits number of unsuccesful iters
        @limit = 333
        @limiter = 0

    end #eof

    # update all object data
    def update

        # check for an abort flag
        if defined? ABORT
            close
        end

        # has final state already been determined?
        if !@board.is_final_state()

            # determine final state
            if !@board.determine_final_state(@queens)

                # Action: limit number of queen moves
                @limiter += 1
                if @limiter >= @limit
                    puts "Solution Not Found or Queen Moves Exceded Limit of "+@limiter.to_s+"."
                    @board.force_final_state()
                end

                # select a new queen, rearrange it towards solving 8queens problem
                @curr_index = @board.search_next_and_move(@curr_index,@queens)

                @board.clear_hits()
                @board.update_hits(@queens)


            else
                puts "\nSolution Found!\n"
                self.print_queens()
                puts "\n"
            end
        end
    end #eof

    # render all graphics
    def draw
        @bg.draw_as_quad(0,0,Gosu::Color::WHITE,
                         W,0,Gosu::Color::WHITE,
                         W,H,Gosu::Color::WHITE,
                         0,H,Gosu::Color::WHITE,
                         UpdateOrder::BG)
        @cursor.draw(self.mouse_x,self.mouse_y,UpdateOrder::Cursor)
        @board.draw
        for i in 0..@queens.size-1 do
            @queens[i].draw
        end
        @font.draw(N.to_s+" Queens (min-conflict)",32,20,UpdateOrder::UI,1,1,Gosu::Color::BLACK)
        @font.draw("Queens Placed:",32,52,UpdateOrder::UI,1,1,Gosu::Color::BLACK)
        @font.draw(N.to_s,148,52,UpdateOrder::UI,1,1,Gosu::Color::BLUE)
        @font.draw("Queens Moved:",32,84,UpdateOrder::UI,1,1,Gosu::Color::BLACK)
        @font.draw(@limiter.to_s,148,84,UpdateOrder::UI,1,1,Gosu::Color::RED)
    end #eof

    # check quit-program by esc button
    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end #eof

    # print positions of each queen
    def print_queens
        puts " ~ Queen Positions: ~ \n"
        for q in @queens
            print "[" + q.loc[:x].to_s + "," + q.loc[:y].to_s + "] "
        end
    end #eof

end #eoc

# Is this the main we want to run?
Main.new.show if __FILE__ == $0
