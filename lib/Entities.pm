use 5.38.0;
use warnings;
use experimental 'class';

class Entity {
    field $x :param;
    field $y :param;
    field $char: param;
    field $fg :param //= '#fff';
    field $bg :param //= '#000';
    field $name :param //= "<unnamed>";
    field $blocks_movement :param = 0;

    method x { $x }
    method y { $y }
    method char { $char }
    method fg { $fg }
    method bg { $bg }
    method blocks_movement { $blocks_movement }

    method move($dx, $dy) {
        $x += $dx;
        $y += $dy;
    }
}

package Entities {

    sub goblin() {
        Entity->new(
            x => 0,
            y => 0,
            char => 'g',
            name => 'goblin',
            fg   => '#41924B',
            blocks_movement => 1
        )
    }

    sub hobgoblin() {
        Entity->new(
            x => 0,
            y => 0,
            char => 'h',
            name => 'hobgoblin',
            fg => '#ff6f3c',
            blocks_movement => 1
        )
    }

    sub player() {
        Entity->new(
            x    => 0,
            y    => 0,
            char => '@',
            fg   => '#fff',
            name => 'hero',
            blocks_movement => 1,
        );
    }

    sub spawn($entity, $map, $x, $y) {
        $entity->move($x, $y);
        $map->add_entity($entity);
    }
}
