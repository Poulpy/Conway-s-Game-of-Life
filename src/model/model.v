module model

pub struct Coord {
    pub mut:
        row int
        col int
}

pub struct Grid {
    mut:
    grid [][]bool
}

pub const (
    total_columns = 30
    total_rows = 30
)

//g := model.Grid{grid: [[false].repeat(model.total_columns)].repeat(model.total_rows)}
// TODO repeat doesn't work
pub fn grid_init() Grid {
    /*
    mut bb := []array_bool
    mut b := []bool
    for j := 0; j != total_columns; j++ {
        b << false
    }
    for i := 0; i != total_rows; i++ {
        bb << b
    }
    */
    mut g := Grid{}
    bb := [[false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns),
           [false].repeat(total_columns)]
    g.grid = bb
    return g
}



// Get the surrounding cells of c (8 in total)
// raise : out of boundaries
pub fn get_neighbours(c Coord) []Coord {
    mut neighbours := []Coord{}

    if !c.within_boundaries() {
        return neighbours
    }

    if c.row - 1 >= 0 {
        neighbours << Coord{c.row - 1, c.col}
        if c.col - 1 >= 0 {
            neighbours << Coord{c.row - 1, c.col - 1}
        }
        if c.col + 1 < total_columns {
            neighbours << Coord{c.row - 1, c.col + 1}
        }
    }
    if c.col - 1 >= 0 {
        neighbours << Coord{c.row, c.col - 1}
    }
    if c.col + 1 < total_columns {
        neighbours << Coord{c.row, c.col + 1}
    }
    if c.row + 1 < total_rows {
        neighbours << Coord{c.row + 1, c.col}
        if c.col - 1 >= 0 {
            neighbours << Coord{c.row + 1, c.col - 1}
        }
        if c.col + 1 < total_columns {
            neighbours << Coord{c.row + 1, c.col + 1}
        }
    }

    return neighbours
}

// Checks if the cell is within the boundaries
pub fn (c Coord) within_boundaries() bool {
    return c.col >= 0 && c.row >= 0
           && c.col < total_columns && c.row < total_rows
}

// Get all living cells (true)
pub fn (g Grid) get_living_cells() []Coord {
    mut living_cells := []Coord{}

    for i := 0; i != total_rows; i++ {
        for j := 0; j != total_columns; j++ {
            if g.grid[i][j] {
                println("i,j $i $j")
                living_cells << Coord{row: i, col: j}
            }
        }
    }

    return living_cells
}

pub fn (g Grid) get_dead_neighbours(c Coord) []Coord {
    mut cells := get_neighbours(c)

    for i := 0; i != cells.len; i++ {
        if g.lives(cells[i]) {
            cells.delete(i)
            i--
        }
    }

    return cells
}


pub fn (g Grid) get_living_neighbours(c Coord) []Coord {
    cells := get_neighbours(c)

    for i := 0; i != cells.len; i++ {
        if !g.lives(cells[i]) {
            cells.delete(i)
            i--
        }
    }

    return cells
}

pub fn (g Grid) lives(c Coord) bool {
    return g.grid[c.row][c.col] == true
}

// raise : out of boundaries, cell already dead
pub fn (g mut Grid) kill(c Coord) bool {
    if !c.within_boundaries() {
        eprintln('Coordinates are out of bounds : (row, col) = ($c.row, $c.col)')
        return false
    } else {
        if g.grid[c.row][c.col] == false {
            eprintln('Cell is already dead')
        } else {
            g.grid[c.row][c.col] = false
        }
        return true
    }
}

// raise : out of boundaries, cell already alive
pub fn (g mut Grid) is_born(c Coord) bool {
    if !c.within_boundaries() {
        eprintln('Coordinates are out of bounds : (row, col) = ($c.row, $c.col)')
        return false
    } else {
        if g.grid[c.row][c.col] == true {
            eprintln('Cell is already alive')
        } else {
            g.grid[c.row][c.col] = true
        }
        return true
    }
}

