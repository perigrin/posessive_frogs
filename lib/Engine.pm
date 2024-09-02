use 5.38.0;
use warnings;
use experimental qw(class try);

use Games::ROT;

use Actions;
use Entities;
use MessageLog;
use ProcGen;
use Exceptions;

class Engine {
    field $height : param;
    field $width : param;

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
        height                => $height - 6,
        player                => $player,
    )->generate_dungeon();

    field $log = MessageLog->instance();

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
                    y => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dx     => -1,
                        dy     => -1,
                    ),
                    u => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dx     => 1,
                        dy     => -1,
                    ),
                    b => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dx     => -1,
                        dy     => 1,
                    ),
                    n => MovementAction->new(
                        map    => $map,
                        entity => $player,
                        dx     => 1,
                        dy     => 1,
                    ),
                    '.' => WaitAction->new(
                        entity => $player
                    ),
                    q => QuitAction->new(
                        entity => $player
                    ),
                );

                try {
                    # lets execute the action now
                    $KEY_MAP{ $event->key }->perform();

                    # now everyone else gets a turn
                    $map->update_entities();
                }
                catch ($e) {
                    say STDERR $e->message;
                    $log->add_message( $e->message, $e->color );
                    if ( $e isa GameOver ) {
                        say STDOUT $e->message;
                        exit;
                    }
                }
            }
        );

        $log->add_message( "Welcome adventurer, to yet another dungeon!",
            Colors::WelcomeText );

        $app->run( sub { $self->render() } );
    }

    my sub update_fov ( $map, $player ) {
        state $fov = Games::ROT::FOV->new();

        $map->for_each_tile( sub ( $tile, @ ) { $tile->visible(0) } );

        my @cells = $fov->calc_visible_cells_from( $player->x, $player->y, 8,
            sub ($cell) { $map->tile_at(@$cell)->is_opaque() } );

        for my $cell (@cells) {
            my $tile = $map->tile_at(@$cell);
            $tile->visible(1);
        }
    }

    method render_bar ( $current, $max, $total ) {
        my $width = int( ( $current / $max ) * $total );

        $app->draw_rect( 8, 45, $total, 0, ' ', Colors::BarEmpty,
            Colors::BarEmpty );
        if ($width) {
            $app->draw_rect( 8, 45, $width, 0, ' ', Colors::BarFilled,
                Colors::BarFilled );
        }
        $app->puts( 0, 45, "hp: $current/$max" );
    }

    method render() {
        update_fov( $map, $player );
        $app->clear();
        $map->render($app);
        $self->render_bar( $player->stats->hp, $player->stats->max_hp, 20 );
        $log->render( $app, 40, 45, 40, 5 );
    }
}
