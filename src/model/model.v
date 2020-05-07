module model

pub struct Coord {
    pub mut:
        row int
        col int
}

struct Grid {
    grid [][]bool
}

pub const (
    total_columns = 30
    total_rows = 30
)


// Get the surrounding cells of c (8 in total)
pub fn get_neighbours(c Coord) []Coord {
    mut neighbours := []Coord{}

    if !within_boundaries(c) {
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
pub fn within_boundaries(c Coord) bool {
    return c.col >= 0 && c.row >= 0
           && c.col < total_columns && c.row < total_rows
}


