/* Imports */

import time
import os

/* Constants */

const (
    MaxLength  = 30
    MaxHeight  = 30
    LivingCell = 'O'
    Empty   = ' '
    SleepingTime = 100
)

/* Structs */

struct Point {
mut:
    x u8
    y u8
}

/* Main */

fn main() {
    mut living_cells := set_of_cells()
    mut grid := init_grid()
    
    print_grid(grid)
    time.sleep_ms(100)
    os.clear()

    for i:= 0; i!=100; i++ {
        living_cells = new_cycle(living_cells)
        
        /* CLI */
        add_cells(mut grid, living_cells)
        print_grid(grid)
        os.clear()
        time.sleep_ms(SleepingTime)
        /*if os.get_line() != 'No' {
            break
        }*/
    }
}

/**********************/
/*                    */
/*       Point        */
/*                    */
/**********************/

/* Point basic operations */

fn (p1 Point) eql(p2 Point) bool {
    return p1.x == p2.x && p1.y == p2.y
}

fn (p1 []Point) - (p2 []Point) []Point {
    mut res := []Point

    for p in p1 {
        if !p2.contains(p) {
            res << p
        }
    }

    return res
}

fn (pts mut []Point) uniq() {
    for i, pt in *pts {
        for j := i + 1; j < pts.len; j++ {
            if pt.eql(pts[j]) {
                pts.delete(j)
                j--
            } 
        }
    } 
}

fn (p1 []Point) inter(p2 []Point) []Point {
    mut pts1 := p1
    mut pts2 := p2
    mut res := []Point

    pts1.uniq()
    pts2.uniq()

    for pt1 in pts1 {
        for pt2 in pts2 {
            if pt1.eql(pt2) {
                res << pt1
                break
            }
        }
    }

    return res
}

fn (p1 []Point) contains(p2 Point) bool {
    for p in p1 {
        if p2.eql(p) {
            return true
        }
    }

    return false
}

/* Debug functions */

fn (pts []Point) str() string {
    mut res := ''

    for p in pts {
        res += p.str()
    }

    return res
}

fn (p Point) str() string {
    return 'x : ' + p.x.str() + '; y : ' + p.y.str() + ';'
}

fn (pts []Point) join(sub string) string {
    mut res := ''

    for pt in pts {
        res += pt.str() + sub
    }

    return res
}


/* Functions related to the Game of Life */

fn set_of_cells() []Point {
    mut cells := []Point
    cells << Point { x: u8(9), y: u8(20) }
    cells << Point { x: u8(10), y: u8(20) }
    cells << Point { x: u8(11), y: u8(20) }
    return cells
}

fn out_of_bounds(cells mut []Point) {
    mut c := cells[0]
    for i := 0; i != cells.len; i++ {
        c = cells[i]
        if !(c.x >= u8(0) && c.x < u8(MaxLength) && c.y >= u8(0) && c.y < u8(MaxHeight)) {
            cells.delete(i)
            i--
        }
    }
}



fn surrounding_cells(c Point) []Point {
    mut neighbours := []Point
    
    neighbours << Point { x: u8(c.x - u8(1)), y: u8(c.y - u8(1)) }
    neighbours << Point { x: u8(c.x - u8(1)), y: u8(c.y) }
    neighbours << Point { x: u8(c.x - u8(1)), y: u8(c.y + u8(1)) }
    neighbours << Point { x: u8(c.x), y: u8(c.y - u8(1)) }
    neighbours << Point { x: u8(c.x), y: u8(c.y + u8(1)) }
    neighbours << Point { x: u8(c.x + u8(1)), y: u8(c.y - u8(1)) }
    neighbours << Point { x: u8(c.x + u8(1)), y: u8(c.y) }
    neighbours << Point { x: u8(c.x + u8(1)), y: u8(c.y + u8(1)) }

    return neighbours
}

fn new_cycle(living_cells []Point) []Point {
    mut new_cells := []Point
    mut count := u8(0)
    
    for i := 0; i != living_cells.len; i++ {
        count = u8(all_living_neighbours(living_cells, living_cells[i]).len)

        if count == u8(2) || count == u8(3) {
            new_cells << living_cells[i]
        }
    }

    for dead_cell in all_dead_neighbours(living_cells) {
        if u8(all_living_neighbours(living_cells, dead_cell).len) == u8(3) {
            new_cells << dead_cell
        }
    }

    return new_cells
}

fn all_dead_neighbours(living_cells []Point) []Point {
    mut neighbours := []Point

    for cell in living_cells {
        neighbours << surrounding_cells(cell)
        neighbours.uniq()
    }

    /* Check the neighbours are not out of the grid bounds
    if so, they are removed */
    out_of_bounds(mut neighbours)

    return neighbours - living_cells
}


fn all_living_neighbours(living_cells []Point, p Point) []Point {
    neighbours := surrounding_cells(p)
    return neighbours.inter(living_cells)
}


/**************************/
/*                        */
/*          GRID          */
/*                        */
/**************************/

fn init_grid() []array_int {
    mut a := []array_int
    for i := 0; i != MaxHeight; i++ {
        a << [0; MaxLength]
    }
    return a
}

fn add_cells(grid mut []array_int, living_cells []Point) {
    *grid = init_grid()
    mut x := u8(0)
    mut y := u8(0)

    for cell in living_cells {
        x = cell.x
        y = cell.y
        grid[int(y)][int(x)] = 1
    }
}

/* CLI */

fn print_grid(grid []array_int) {
    for line in grid {
        for cell in line {
            if cell == 0 { print(Empty) }
            else { print(LivingCell) }
        }
        println('')
    }
}

