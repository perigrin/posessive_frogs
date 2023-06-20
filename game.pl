#!/usr/bin/env perl
use 5.38.0;

use lib qw(lib);
use experimental 'class';

use Games::ROT;

class QuitAction { }

class MovementAction {
    field $dx :param //= 0;
    field $dy :param //= 0;

    method dx { $dx }
    method dy { $dy }
}

class Engine {
    my $WIDTH = 80;
    my $HEIGHT = 50;

    field $player_x = $WIDTH / 2;
    field $player_y = $WIDTH / 2;

    field $app = Games::ROT->new(
        screen_width  => $WIDTH,
        screen_height => $HEIGHT,
    );

    ADJUST {
        $app->add_event_handler(
            'keydown' => sub ($event) {
                my %KEY_MAP = (
                    h => sub { $player_x -= 1 },
                    j => sub { $player_y += 1 },
                    k => sub { $player_y -= 1 },
                    l => sub { $player_x += 1 },
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
        $app->draw($player_x, $player_y, '@', '#fff', '#000');
    }
}

my $engine = Engine->new();
