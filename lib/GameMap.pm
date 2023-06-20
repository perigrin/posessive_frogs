use 5.38.0;
use warnings;
use experimental 'class';

class Tile {
    field $walkable :param;
    field $transparent :param;
    field $char :param //= '';
    field $fg :param //= '#fff';
    field $bg :param //= '#000';

    method is_walkable() { $walkable }
    method is_transparent { $transparent }
    method char() { $char }
    method fg() { $fg }
    method bg() { $bg }
}

class GameMap {
    field $width   :param;
    field $height  :param;

    method is_in_bounds($x, $y) {
        return 0 <= $x < $width && 0 <= $y < $height;
    }

    my sub FLOOR_TILE() {
        Tile->new(
            walkable    => 1,
            transparent => 1,
            char        => '.',
            fg          => '#333'
        );
    }

    my sub WALL_TILE() {
        Tile->new(
            walkable    => 0,
            transparent => 0,
            char        => '#',
        );
    }

    field @tiles = map { [map { WALL_TILE() } 0..$width] } 0..$height;

    # ADJUST BLOCK WAS HERE

    method render($term) {
        state $i = 0;
        for my $y (0..$height) {
            for my $x (0..$width) {
                my $tile = $self->tile_at($x, $y);
                $term->draw($x, $y, $tile->char, $tile->fg, $tile->bg);
            }
        }
    }

    method tile_at($x, $y) {
        return $tiles[$y][$x];
    }

    method _tiles_to_floor($x_slice, $y_slice) {
        # for every row in the $y_slice
        for (@$y_slice) {
            # convert the $x_slice columns to FLOOR_TILE()s
            $tiles[$_]->@[@$x_slice] = map FLOOR_TILE(), @$x_slice;
        }
    }
}


