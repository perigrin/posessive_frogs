use 5.38.0;
use warnings;
use experimental 'class';

class Entity {
    field $x :param //= 0;
    field $y :param //= 0;
    field $char: param;
    field $fg :param //= '#fff';
    field $bg :param //= '#000';
    field $name :param //= "<unnamed>";
    field $blocks_movement :param //= 1;
    field $abilities :param;

    method x { $x }
    method y { $y }
    method char { $char }
    method fg { $fg }
    method bg { $bg }
    method blocks_movement { $blocks_movement }
    method stats { $abilities }
    method name { $name }

    method position() { [$x, $y] }

    method move($dx, $dy) {
        $x += $dx;
        $y += $dy;
    }
}

class Mob :isa(Entity) {
    use List::Util qw(first);
    use Games::ROT::AStar;
    use Actions;

    # Mob's currently just walk toward the player if visible
    method next_action($map) {
        state $fov = Games::ROT::FOV->new();
        my @visible =
          $fov->calc_visible_cells_from( $self->position->@*,
            $self->stats->vision,
            sub ($cell) { $map->tile_at(@$cell)->is_opaque() },
          );

        my @entities =
          grep { defined } map { $map->has_entity_at(@$_) } @visible;
        my $player = first { $_->char eq '@' } @entities;
        return unless $player;

        my @step = Games::ROT::AStar::get_path( $map, $self->position,
            $player->position );

        return unless @step;

        return MovementAction->new(
            entity => $self,
            map    => $map,
            dx     => $step[1]->[0] - $self->x,
            dy     => $step[1]->[1] - $self->y,
        );
    }
}

package Entities {
    use List::Util  qw(min);
    use Games::Dice qw(roll roll_array);

    sub goblin() {
        state $i = 1;
        Mob->new(
            name      => 'goblin '.$i++,
            char      => 'g',
            fg        => '#41924B',
            abilities => Abilities->new(
                strength => -3,
                armor    => 0,
                hp       => roll('1d8-1'),
            )
        );
    }

    sub hobgoblin() {
        state $i = 1;
        Mob->new(
            name      => 'hobgoblin  '.$i++,
            char      => 'h',
            fg        => '#ff6f3c',
            abilities => Abilities->new(
                strength => -1,
                armor    => 1,
                hp       => roll('1d8+1'),
            ),
        );
    }

    sub player() {
        Entity->new(
            name      => 'hero',
            char      => '@',
            fg        => '#fff',
            abilities => Abilities->new(
                strength => min( roll_array('3d6') ),
                armor    => 1,
                hp       => roll('1d8'),    # TODO add constitution bonus
            ),
        );
    }
}

class Abilities {
    use List::Util qw(min);
    use Games::Dice qw(roll roll_array);

    field $strength :param //= min( roll_array('3d6') );
    field $armor    :param //= 1;
    field $max_hp   :param(hp) //= roll('1d8');
    field $hp = $max_hp;

    method armor()    { $armor }
    method strength() { $strength }
    method hp()       { $hp }

    method vision { 8 }

    method change_hp($delta) { $hp += $delta }
}

