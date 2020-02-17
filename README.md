# Game of life


## Run the game


`
v build game_of_life.v && ./game_of_life
`

### CLI

By default, the game will run in a window. If you provide the -c flag, the game will run in the console:

`
v build game_of_life.v && ./game_of_life -c
`

### Seeding

If you want your game to have a predefined set of cells, you can provide a CSV file:

`
v build game_of_life.v && ./game_of_life -f=cells.csv
`

