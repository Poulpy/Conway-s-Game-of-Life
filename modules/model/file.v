module model


pub fn (p1 Point) eql(p2 Point) bool {
    return p1.x == p2.x && p1.y == p2.y
}

// Will be implemented in V
pub fn (p1 []Point) - (p2 []Point) []Point {
    mut res := []Point

    for p in p1 {
        if !(p in p2) {
            res << p
        }
    }

    return res
}

// Will be implemented in V
pub fn (pts mut []Point) uniq() {
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
pub fn (p1 []Point) inter(p2 []Point) []Point {
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
pub fn (p1 []Point) contains(p2 Point) bool {
    for p in p1 {
        if p2.eql(p) {
            return true
        }
    }

    return false
}

// Will be implemented in V
fn (pts []Point) join(sub string) string {
    mut res := ''

    for pt in pts {
        res += pt.str() + sub
    }

    return res
}


pub fn set_of_cells() []Point {
    mut cells := []Point

    cells << Point { x: 9, y: 2 }
    cells << Point { x: 10, y: 2 }
    cells << Point { x: 11, y: 2 }

    out_of_bounds(mut cells)

    return cells
}

pub fn random_set_of_cells(nbr int) []Point {
    mut pts := []Point
    mut pt := Point { x: 0, y: 0 }

    rand.seed(time.now().uni)
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
pub fn read_csv(file_path string) []Point {
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
pub fn out_of_bounds(cells mut []Point) {
    mut c := cells[0]

    for i := 0; i != cells.len; i++ {
        c = cells[i]
        if c.is_out_of_bounds() {
            cells.delete(i)
            i--
        }
    }
}

pub fn surrounding_cells(c Point) []Point {
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

pub fn new_cycle(living_cells []Point) []Point {
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

pub fn all_dead_neighbours(living_cells []Point) []Point {
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


pub fn all_living_neighbours(living_cells []Point, cell Point) []Point {
    return surrounding_cells(cell).inter(living_cells)
}

pub fn (c Point) is_out_of_bounds() bool {
    return !(c.x >= 0 && c.x < MaxWidth && c.y >= 0 && c.y < MaxHeight)
}

