#!/usr/bin/env perl
use 5.38.0;
use warnings;

use lib qw(lib);
use experimental 'class';

use Games::ROT;

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

    field @tiles;

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

    ADJUST {
        # draw the floor
        @tiles = map { [map { FLOOR_TILE() } 0..$width] } 0..$height;

        # draw a little wall in the room
        $tiles[22]->@[30..32] = map { WALL_TILE() } 0..2;
    }

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
}

class Entity {
    field $x :param;
    field $y :param;
    field $char: param;
    field $fg :param //= '#fff';
    field $bg :param //= '#000';

    method x { $x }
    method y { $y }
    method char { $char }
    method fg { $fg }
    method bg { $bg }

    method move($dx, $dy) {
        $x += $dx;
        $y += $dy;
    }
}

class Engine {
    field $height :param;
    field $width :param;

    field $player = Entity->new(
       x    => $width / 2,
       y    => $height / 2,
       char => '@',
       fg   => '#fff',
       bg   => '#000',
    );

    field @npcs = (
        Entity->new(
            x => $player->x - 5,
            y => $player->y,
            char => 'N',
            fg => '#0f0',
            bg => '#000',
        ),
    );

    field $app = Games::ROT->new(
        screen_width  => $width,
        screen_height => $height,
    );

    field $map = GameMap->new(
        width   => $width,
        height  => $height,
    );

    ADJUST {
        my sub movement_action($dx, $dy) {
            my ($x, $y) = ($player->x + $dx, $player->y + $dy);
            return unless $map->is_in_bounds($x, $y);
            return unless $map->tile_at($x, $y)->is_walkable;
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

    method render() {
        $app->clear();
        $map->render($app);
        for my $e (@npcs, $player) {
            $app->draw($e->x, $e->y, $e->char, $e->fg, $e->bg);
        }
    }
}

my $engine = Engine->new(width => 80, height => 50);
