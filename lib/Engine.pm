use 5.38.0;
use warnings;
use experimental 'class';

use Games::ROT;
use Entities;

use ProcGen qw(generate_dungeon);

class Engine {
    field $height :param;
    field $width :param;

    field $player = Entities::player();

    field $app = Games::ROT->new(
        screen_width  => $width,
        screen_height => $height,
    );

    field $map = SimpleDungeonGenerator->new(
        room_count            => 30,
        min_room_size         => 6,
        max_room_size         => 10,
        max_monsters_per_room => 2,
        width                 => $width,
        height                => $height,
        player                => $player,
    )->generate_dungeon();

    ADJUST {
        my sub movement_action($dx, $dy) {
            my ($x, $y) = ($player->x + $dx, $player->y + $dy);
            return unless $map->is_in_bounds($x, $y);
            return unless $map->tile_at($x, $y)->is_walkable;
            if (my $e = $map->has_entity_at($x, $y)) {
                return if $e->blocks_movement;
            }
            $player->move($dx,$dy);
        }

        $app->add_event_handler(
            'keydown' => sub ($event) {
                my %KEY_MAP = (
                    h => sub { movement_action(-1, 0) },
                    j => sub { movement_action( 0, 1) },
                    k => sub { movement_action( 0,-1) },
                    l => sub { movement_action( 1, 0) },
                    q => sub { exit }
                );
                # lets execute the action now
                $KEY_MAP{$event->key}->();
            }
        );
        $app->run( sub { $self->render() } );
    }

	my sub update_fov($map, $player) {
		state $fov = Games::ROT::FOV->new();

		$map->for_each_tile(sub ($tile, @){ $tile->visible(0) });

		my @cells = $fov->calc_visible_cells_from(
			$player->x,
			$player->y,
			8,
			sub ($cell) { $map->tile_at(@$cell)->is_opaque() }
		);
		for my $cell (@cells) {
			my $tile = $map->tile_at(@$cell);
			$tile->visible(1);
		}
	}

    method render() {
		update_fov($map, $player);
        $app->clear();
        $map->render($app);
    }
}
