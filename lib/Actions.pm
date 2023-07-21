use 5.38.0;
use warnings;
use experimental 'class';

class Action {
    field $entity :param;

    method entity {
        die 'protected method' unless caller()->isa(__PACKAGE__);
        return $entity;
    }

    method perform() { ... }
}

class MovementAction :isa(Action) {
    field $dx :param = 0;
    field $dy :param = 0;

    field $map :param;

    method perform() {
        my $player = $self->entity();
        my ( $x, $y ) = ( $player->x + $dx, $player->y + $dy );

        return unless $map->is_in_bounds( $x, $y );
        return unless $map->tile_at( $x, $y )->is_walkable;

        my $e = $map->has_entity_at( $x, $y );
        if ($e && $e ne $player) {
            my $combat = MeleeAttackAction->new(
                map      => $map,
                entity   => $player,
                defender => $e,
            );
            return $combat->perform();
        }

        $player->move( $dx, $dy );
    }
}

class MeleeAttackAction :isa(Action) {
    use Games::Dice qw(roll);

    field $defender :param;
    field $map :param;

    method perform() {
        my $attacker    = $self->entity;
        my $attack_roll = roll('1d20') + $attacker->stats->strength;
        my $defense     = $defender->stats->armor + 10;

        if ( $attack_roll > $defense ) {
            $defender->stats->change_hp( $defense - $attack_roll );

            if ( $defender->stats->hp <= 0 ) {
                $map->remove_entity($defender);
            }
        }
        return;
    }
}

class QuitAction :isa(Action) {
    method perform() { exit }
}
