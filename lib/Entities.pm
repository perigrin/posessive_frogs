use 5.38.0;
use warnings;
use experimental 'class';

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
