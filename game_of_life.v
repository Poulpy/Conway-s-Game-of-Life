/* Imports */

import time
import os
import gx
import gl
import gg
import glfw
import strings


/* Constants */

const (
    MaxWidth  = 50
    MaxHeight  = 20
    LivingCell = 'O'
    DeadCell   = ' '
    SleepingTime = 1000
    Living = gx.rgb(0, 110, 194)
    BlockSize = 10
    LivingCellColor = gx.Red
    DeadCellColor   = gx.White
    VerticalBorder = 50
    HorizontalBorder = 50
    WindowWidth = MaxWidth * BlockSize + HorizontalBorder * 2
    WindowHeight = MaxHeight * BlockSize + VerticalBorder * 2
)

/* Structs */

struct Point {
mut:
    x int
    y int
}

/* Main */

fn main() {
    //mut living_cells := set_of_cells()
    mut living_cells := read_csv('cells.csv')
    mut grid := init_grid()
    add_cells(mut grid, living_cells)


    // GUI
    glfw.init()
    mut game := gg.new_context(gg.Cfg {
        width: WindowWidth
        height: WindowHeight
        use_ortho: true
        create_window: true
        window_title: 'Game of Life'
        window_user_ptr: game
    })
    game.window.set_user_ptr(game)
    clear_window(mut game, gx.White)

    for i := 0; i != 10; i++ {
        print_cells(mut game, grid)
        time.sleep_ms(SleepingTime)
        living_cells = new_cycle(living_cells)
        if living_cells.len == 0 { break }

        add_cells(mut grid, living_cells)
    }
    game.window.destroy()


    // CLI
    /*
    for i:= 0; i != 10; i++ {
        os.clear()
        print_grid(grid)
        time.sleep_ms(SleepingTime)
        living_cells = new_cycle(living_cells)
        if living_cells.len == 0 { break }

        add_cells(mut grid, living_cells)
    }*/
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

// Will be implemented in V
fn (p1 []Point) - (p2 []Point) []Point {
    mut res := []Point

    for p in p1 {
        if !p2.contains(p) {
            res << p
        }
    }

    return res
}

// Will be implemented in V
fn (pts mut []Point) uniq() {
    for i, pt in *pts {
        /* Since we're deleting, this for loop is necessary, because
        The index i doesn't fallback on other for syntaxes */
        for j := i + 1; j < pts.len; j++ {
            if pt.eql(pts[j]) {
                pts.delete(j)
                j--
            }
        }
    }
}

// Will be implemented in V
fn (p1 []Point) inter(p2 []Point) []Point {
    mut pts1 := p1
    mut pts2 := p2
    mut res := []Point

    /* We can't call uniq() on the loops, because
    the loops use then the return value (and uniq()
    returns void) */
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

// Will be implemented in V
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

// Will be implemented in V
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

    cells << Point { x: 9, y: 20 }
    cells << Point { x: 10, y: 20 }
    cells << Point { x: 11, y: 20 }

    return cells
}

// Existing CSV module
fn read_csv(file_path string) []Point {
    mut cells := []Point
    mut x := 0
    mut y := 0

    f := os.read_file(file_path) or {
        panic(err)
        return []Point
    }

    points := f.split('\n')

    for p in points {
        // p[0] returns the ASCII CODE, and not the char
        x = p.substr(0, 1).int()// char 0
        y = p.substr(2, 3).int()// char 2
        cells << Point { x: x, y: y }
    }

    out_of_bounds(mut cells)

    return cells
}

fn out_of_bounds(cells mut []Point) {
    mut c := cells[0]

    for i := 0; i != cells.len; i++ {
        c = cells[i]
        if !(c.x >= 0 && c.x < MaxWidth && c.y >= 0 && c.y < MaxHeight) {
            cells.delete(i)
            i--
        }
    }
}



fn surrounding_cells(c Point) []Point {
    mut neighbours := []Point

    neighbours << Point { x: c.x - 1, y: c.y - 1 }
    neighbours << Point { x: c.x - 1, y: c.y }
    neighbours << Point { x: c.x - 1, y: c.y + 1 }
    neighbours << Point { x: c.x, y: c.y - 1 }
    neighbours << Point { x: c.x, y: c.y + 1 }
    neighbours << Point { x: c.x + 1, y: c.y - 1 }
    neighbours << Point { x: c.x + 1, y: c.y }
    neighbours << Point { x: c.x + 1, y: c.y + 1 }

    return neighbours
}

fn new_cycle(living_cells []Point) []Point {
    mut new_cells := []Point
    mut count := 0

    for cell in living_cells {
        count = all_living_neighbours(living_cells, cell).len

        if count == 2 || count == 3 {
            new_cells << cell
        }
    }

    for dead_cell in all_dead_neighbours(living_cells) {
        if all_living_neighbours(living_cells, dead_cell).len == 3 {
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

    /* Check the neighbours are NOT out of the grid bounds
    if so, they are removed */
    out_of_bounds(mut neighbours)

    return neighbours - living_cells
}


fn all_living_neighbours(living_cells []Point, cell Point) []Point {
    return surrounding_cells(cell).inter(living_cells)
}


/**************************/
/*                        */
/*          GRID          */
/*                        */
/**************************/

fn init_grid() []array_int {
    mut a := []array_int

    for i := 0; i != MaxHeight; i++ {
        a << [0; MaxWidth]
    }

    return a
}

fn add_cells(grid mut []array_int, living_cells []Point) {
    /* mut is a pointer, so we need a * to deref it */
    *grid = init_grid()
    mut x := 0
    mut y := 0

    for cell in living_cells {
        x = cell.x
        y = cell.y
        /* x and y needs to be mutable ?! */
        grid[y][x] = 1
    }
}

/* CLI */

fn print_grid(grid []array_int) {
    // Top border
    println(strings.repeat(byte(42), MaxWidth + 2))

    for line in grid {
        print('*')
        for cell in line {
            if cell == 0 { print(DeadCell) }
            else { print(LivingCell) }
        }
        println('*')
    }

    // Bottom border
    println(strings.repeat(byte(42), MaxWidth + 2))
}


/**************************/
/*                        */
/*          GUI           */
/*                        */
/**************************/

// clear is not working, moreover color value is useless in
// function call (see source code)
fn clear_window(g mut gg.GG, c gx.Color) {
    g.draw_rect(0, 0, WindowWidth, WindowHeight, c)
    g.render()
}


fn print_cells(g mut gg.GG, grid []array_int)
{
    mut x := 0
    mut y := 0
    mut cell_size := 0
    mut cell_color := gx.White

    for l, line in grid
    {
        for c, cell in line
        {
            x = c * BlockSize + HorizontalBorder
            y = l * BlockSize + HorizontalBorder

            if cell == 0
            {
                x--
                y--
                cell_size = BlockSize + 1
                cell_color = DeadCellColor
            }
            else
            {
                x++
                y++
                cell_size = BlockSize - 1
                cell_color = LivingCellColor
            }

            g.draw_rect(x, y, cell_size, cell_size, cell_color)
        }
    }
    g.render()
}

