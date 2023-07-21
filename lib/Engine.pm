use 5.38.0;
use warnings;
use experimental 'class';

use Games::ROT;
use Entities;
use Actions;

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
        $app->add_event_handler(
            'keydown' => sub ($event) {
                my %KEY_MAP = (
                    h => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dx     => -1
                    ),
                    j => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dy     => 1
                    ),
                    k => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dy     => -1
                    ),
                    l => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dx     => 1
                    ),
                    q => QuitAction->new(
                        entity => $player
                    ),
                );

                # lets execute the action now
                $KEY_MAP{ $event->key }->perform();
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
