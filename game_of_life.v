/* Imports */

import time
import os
import gx
//import gl
import gg
import glfw
//import strings
import rand
//import ui

#flag -lncurses
#include "curses.h"
#include "ncurses.h"

fn C.initscr()
fn C.noecho()
fn C.endwin()
fn C.mvprintw(y int, x int, fmt byteptr, ...) int
fn C.refresh()

/* Constants */

const (
    MaxWidth   = 50
    MaxHeight  = 20
    MaxCells   = MaxWidth * MaxHeight

    LivingCell = 'O'
    DeadCell   = ' '
    WindowTitle = 'Game of Life'
    LivingCellColor = gx.Red
    DeadCellColor   = gx.White

    SleepingTime = 1000
    BlockSize = 10

    VerticalBorder   = 0
    HorizontalBorder = 0

    WindowWidth  = MaxWidth * BlockSize + HorizontalBorder * 2
    WindowHeight = MaxHeight * BlockSize + VerticalBorder * 2
)

/* Structs */

struct Point {
    mut:
    x int
    y int
}

/*struct Context
{
    window *ui.Window
    mut:
    grid []array_int
}*/

/* Main */

fn main() {
    mut living_cells := []Point
    mut grid := init_grid()
    file_name := has_file_arg()

    if file_name == '' {
        living_cells = random_set_of_cells(60)// set_of_cells()
    }
    else {
        living_cells = read_csv(file_name)
    }

    grid = add_cells(living_cells)

    if living_cells.len == 0 { return }

    if has_console_arg() {
        cli_game(mut grid, mut living_cells)
    }
    else {
        /*context := &Context {}
        context.window := ui.new_window(ui.WinCfg {
            width: WindowWidth
            height: WindowHeight
            title: WindowTitle
            draw_fn: draw
            ptr: context
        })
        for {
            ui.wait_events()
        }*/
        gui_game(mut grid, mut living_cells)
    }
}
fn has_console_arg() bool {
    return '-c' in os.args
}

// v run game_of_life.v -f=cells.csv
fn has_file_arg() string {
    for arg in os.args {
        if arg.substr(1, 2) == 'f' {
            // Taking out the filename
            return arg.substr(3, arg.len)
        }
    }

    return ''
}

fn gui_game(grid mut []array_int, living_cells mut []Point)
{
    glfw.init_glfw()
    mut game := gg.new_context(gg.Cfg {
        width: WindowWidth
        height: WindowHeight
        use_ortho: true
        create_window: true
        window_title: WindowTitle
        window_user_ptr: game
    })
    game.window.set_user_ptr(game)
    clear_window(mut game, gx.White)

    for i := 0; i != 10; i++
    {
        print_cells(mut game, grid)
        time.sleep_ms(SleepingTime)
        *living_cells = new_cycle(living_cells)
        if living_cells.len == 0 { break }

        *grid = add_cells(living_cells)
    }
    game.window.destroy()
}

fn cli_game(grid mut []array_int, living_cells mut []Point)
{
    C.initscr()
    C.noecho()

    for i := 0; i != 10; i++
    {
        print_grid(grid)
        time.sleep_ms(SleepingTime)
        *living_cells = new_cycle(living_cells)
        if living_cells.len == 0 { break }

        *grid = add_cells(living_cells)
    }

    C.endwin()
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
        if !(p in p2) {
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

/*
fn (p glfw.Pos) x() int {
    return p.x
}
*/


pub fn (p Point) str() string {
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

    cells << Point { x: 9, y: 2 }
    cells << Point { x: 10, y: 2 }
    cells << Point { x: 11, y: 2 }

    out_of_bounds(mut cells)

    return cells
}

fn random_set_of_cells(nbr int) []Point {
    mut pts := []Point
    mut pt := Point { x: 0, y: 0 }

    rand.seed(time.now().unix)
    for pts.len != nbr
    {
        pt.x = rand.next(MaxWidth - 1)
        pt.y = rand.next(MaxHeight - 1)

        if pt in pts || pt.is_out_of_bounds() { continue }
        pts << pt
    }

    return pts
}

// Existing CSV module
fn read_csv(file_path string) []Point {
    mut cells := []Point
    mut x := 0
    mut y := 0

    f := os.read_file(file_path) or {
        panic(err)
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

// TODO: rename the function
fn out_of_bounds(cells mut []Point) {
    mut c := cells[0]

    for i := 0; i != cells.len; i++ {
        c = cells[i]
        if c.is_out_of_bounds() {
            cells.delete(i)
            i--
        }
    }
}

fn (c Point) is_out_of_bounds() bool {
    return !(c.x >= 0 && c.x < MaxWidth && c.y >= 0 && c.y < MaxHeight)
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


/* Grid functions */

fn init_grid() []array_int {
    mut a := []array_int

    for i := 0; i != MaxHeight; i++ {
        a << [0].repeat(MaxWidth)
    }

    return a
}

fn add_cells(living_cells []Point) []array_int {
    mut grid := init_grid()
    mut x := 0
    mut y := 0

    for cell in living_cells {
        x = cell.x
        y = cell.y
        /* x and y needs to be mutable ?! */
        grid[y][x] = 1
    }

    return grid
}



/**************************/
/*                        */
/*          CLI           */
/*                        */
/**************************/

fn print_grid(grid []array_int)
{
    for i := 0; i != MaxWidth + 2; i++
    {
        C.mvprintw(0, i, '*')
        C.mvprintw(MaxHeight + 1, i, '*')
    }

    for y, line in grid
    {
        C.mvprintw(y + 1, 0, '*')

        for x, cell in line
        {
            if cell == 0 { C.mvprintw(y + 1, x + 1, '.') }
            else { C.mvprintw(y + 1, x + 1, 'O') }
        }

        C.mvprintw(y + 1, MaxWidth + 1, '*')
    }

    C.refresh()
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


/*
fn borders(g gg.GG, space int, c gx.Color) {
    upper_left   := Point { x: HorizontalBorder - space, y: VerticalBorder - space }
    upper_right  := Point { x: WindowWidth - HorizontalBorder + space, y: VerticalBorder - space }
    bottom_right := Point { x: WindowWidth - HorizontalBorder + space, y: WindowHeight - VerticalBorder + space }
    bottom_left  := Point { x: HorizontalBorder - space, y: WindowHeight - VerticalBorder + space }

    g.draw_line_c(upper_left.x, upper_left.y, upper_right.x, upper_right.y, c)
    g.draw_line_c(upper_left.x, upper_left.y, bottom_left.x, bottom_left.y, c)
    g.draw_line_c(upper_right.x, upper_right.y, bottom_right.x, bottom_right.y, c)
    g.draw_line_c(bottom_left.x, bottom_left.y, bottom_right.x, bottom_right.y, c)
}
*/


fn print_cells(g mut gg.GG, grid []array_int)
{
    mut x := 0
    mut y := 0
    mut cell_size := 0
    mut cell_color := gx.White

    //borders(g, 2, gx.Black)

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

/*
fn draw(c *Context)
{
    mut x := 0
    mut y := 0
    mut cell_size := 0
    mut cell_color := gx.White

    upper_left   := Point { x: HorizontalBorder - space, y: VerticalBorder - space }
    upper_right  := Point { x: WindowWidth - HorizontalBorder + space, y: VerticalBorder - space }
    bottom_right := Point { x: WindowWidth - HorizontalBorder + space, y: WindowHeight - VerticalBorder + space }
    bottom_left  := Point { x: HorizontalBorder - space, y: WindowHeight - VerticalBorder + space }

    gx.draw_line_c(upper_left.x, upper_left.y, upper_right.x, upper_right.y, c)
    gx.draw_line_c(upper_left.x, upper_left.y, bottom_left.x, bottom_left.y, c)
    gx.draw_line_c(upper_right.x, upper_right.y, bottom_right.x, bottom_right.y, c)
    gx.draw_line_c(bottom_left.x, bottom_left.y, bottom_right.x, bottom_right.y, c)


    for l, line in c.grid
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

            gx.draw_rect(x, y, cell_size, cell_size, cell_color)
        }
    }
}
*/

