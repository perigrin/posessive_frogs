use 5.38.0;
use warnings;
use experimental 'class';

class Tile {
    field $walkable :param;
    field $opaque :param;
    field $char :param //= ' ';
    field $light_fg :param //= '#fff';
    field $light_bg :param //= '#000';
    field $dark_fg  :param //= '#666';
    field $dark_bg  :param //= '#000';

    field $seen    = 0;
    field $visible = 0;

    method is_walkable() { $walkable }
    method is_opaque { $opaque }
    method char() { $char }

    method fg() { $visible ? $light_fg : $dark_fg }
    method bg() { $visible ? $light_bg : $dark_bg }

    method seen($set=undef) {
        if (defined $set) { $seen ||= $set } # you can't unsee a tile
        return $seen;
    }

    method visible($set=undef) {
        if (defined $set) {
			$self->seen($set);
			$visible = $set;
		}
        return $visible;
    }
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
            opaque 		=> 0,
            char        => '.',
        );
    }

    my sub WALL_TILE() {
        Tile->new(
            walkable    => 0,
            opaque 		=> 1,
            char        => '#',
        );
    }

    field @tiles = map { [map { WALL_TILE() } 0..$width] } 0..$height;

    # ADJUST BLOCK WAS HERE

 	method render($term) {
		$self->for_each_tile(sub ($tile, $x, $y) {
            $term->draw($x, $y, $tile->char, $tile->fg, $tile->bg) if $tile->seen;
        });
    }

    method tile_at($x, $y) { $tiles[$y][$x] }

	method for_each_tile($action) {
		for my $y (0..$height) {
            for my $x (0..$width) {
                my $tile = $self->tile_at($x, $y);
                $action->($tile, $x, $y);
            }
        }
	}

    method _tiles_to_floor($x_slice, $y_slice) {
        # for every row in the $y_slice
        for (@$y_slice) {
            # convert the $x_slice columns to FLOOR_TILE()s
            $tiles[$_]->@[@$x_slice] = map FLOOR_TILE(), @$x_slice;
        }
    }

}

