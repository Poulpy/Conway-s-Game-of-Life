
import model

fn test_get_neighbours() {
    mut c := model.Coord{row: 3, col: 2}
    mut n := model.get_neighbours(c)
    assert n.len == 8
    c.row = 0
    c.col = 2
    n = model.get_neighbours(c)
    assert n.len == 5
    c.row = 0
    c.col = 0
    n = model.get_neighbours(c)
    assert n.len == 3
    c.row =model.total_rows - 1
    c.col =model.total_columns - 1
    n = model.get_neighbours(c)
    assert n.len == 3
    c.row = -3
    c.col = -3
    n = model.get_neighbours(c)
    assert n.len == 0
    c.row = 0
    c.col = 3
    n = model.get_neighbours(c)
    assert n.len == 5
}

fn test_get_living_cells() {
    mut g := model.grid_init()

    c := model.Coord{row: 2, col: 3}
    mut l := g.get_living_cells()
    assert l.len == 0
    g.is_born(c)
    l = g.get_living_cells()
    println(l.len)
    assert l.len == 1
}

