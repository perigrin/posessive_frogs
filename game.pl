#!/usr/bin/env perl
use 5.38.0;

use lib qw(lib);
use experimental  'class';

use Games::ROT;

class Engine {
    my $WIDTH = 80;
    my $HEIGHT = 50;

    field $app = Games::ROT->new(
        screen_width  => $WIDTH,
        screen_height => $HEIGHT,
    );

    ADJUST {
        $app->run( sub { $self->render() } );
    }

    method render() {
        my $x = $WIDTH / 2;
        my $y = $HEIGHT / 2;

        $app->draw($x, $y, 'Hello World', '#fff', '#000');
    }
}

my $engine = Engine->new();
