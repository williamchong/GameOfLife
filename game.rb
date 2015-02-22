#forked from https://github.com/spaghetticode/game-of-life-ruby
module ChatDemo
  class Game
    LIVE = [2,3]
    BORN = [3]

    attr_accessor :grid, :cols, :rows

    def initialize(cols, rows)
      @cols, @rows = cols, rows
      @grid = build_grid
    end

    def load(y,x,r,g,b)
      x=Integer(x)
      y=Integer(y)
      r=Integer(r)
      g=Integer(g)
      b=Integer(b)
      if y>=0 && x>=0 && y<=rows && x<=cols
        grid[x][y]=[1,r,g,b]
       end
    end

    def to_s
      cordList=[]
      grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
            if cell[0]==1
              cord = {:x=>x,:y=>y,:r=>cell[1],:g=>cell[2],:b=>cell[3]}
              cordList << cord
            end
        end
      end
      json={:list=>cordList}
      json=JSON.generate(json)
    end

    def live_neighbors_count(y,x)
      neighbors(y,x).select {|cell| cell[0] == 1}.size
    end

    def tick
      new_grid = build_grid
      grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          count = live_neighbors_count(y,x)
          new_grid[y][x][0] = begin
            if cell[0].zero?
              if BORN.include?(count)
                cells=neighbors(y,x).select {|cell| cell[0] == 1}
                r=0
                g=0
                b=0
                cells.each do |cell|
                  r+=cell[1]
                  g+=cell[2]
                  b+=cell[3]                 
                end
                r/=count
                g/=count
                b/=count
                new_grid[y][x]=[1,r,g,b]
                1
              else
                0
              end
            else
              if LIVE.include?(count) 
                new_grid[y][x]=grid[y][x]
                1
              else
                0
              end
            end
          end
        end
      end
      @grid = new_grid
    end

    private

    def build_grid
      Array.new(rows) { Array.new(cols){ Array.new(4, 0) } }
    end

    def neighbors(y, x)
      (-1..1).inject [] do |values, py|
        (-1..1).each do |px|
          unless py == 0 and px == 0
            i = y + py
            j = x + px
            i = 0 unless i < rows
            j = 0 unless j < cols
            values << grid[i][j]
          end
        end
        values
      end
    end
  end

end
