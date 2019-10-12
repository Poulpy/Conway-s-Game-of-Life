module main

/* Imports */

import model
import os
import gx
//import gl
import gg
import glfw
//import strings
//import ui


#flag -lncurses
#include "curses.h"
#include "ncurses.h"


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
        living_cells = model.random_set_of_cells(60)// set_of_cells()
    }
    else {
        living_cells = model.read_csv(file_name)
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
    glfw.init()
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
        *living_cells = model.new_cycle(living_cells)
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
        *living_cells = model.new_cycle(living_cells)
        if living_cells.len == 0 { break }

        *grid = add_cells(living_cells)
    }

    C.endwin()
}
/* Debug functions */

/*
fn (p glfw.Pos) x() int {
    return p.x
}
*/




/* Functions related to the Game of Life */


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


fn borders(g mut gg.GG, space int, c gx.Color) {
    upper_left   := Point { x: HorizontalBorder - space, y: VerticalBorder - space }
    upper_right  := Point { x: WindowWidth - HorizontalBorder + space, y: VerticalBorder - space }
    bottom_right := Point { x: WindowWidth - HorizontalBorder + space, y: WindowHeight - VerticalBorder + space }
    bottom_left  := Point { x: HorizontalBorder - space, y: WindowHeight - VerticalBorder + space }

    g.draw_line_c(upper_left.x, upper_left.y, upper_right.x, upper_right.y, c)
    g.draw_line_c(upper_left.x, upper_left.y, bottom_left.x, bottom_left.y, c)
    g.draw_line_c(upper_right.x, upper_right.y, bottom_right.x, bottom_right.y, c)
    g.draw_line_c(bottom_left.x, bottom_left.y, bottom_right.x, bottom_right.y, c)
}


fn print_cells(g mut gg.GG, grid []array_int)
{
    mut x := 0
    mut y := 0
    mut cell_size := 0
    mut cell_color := gx.White

    borders(mut g, 2, gx.Black)

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

