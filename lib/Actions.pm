use 5.38.0;
use warnings;
use experimental 'class';

use Colors;
use MessageLog;
use Exceptions;

class Action {
    field $entity : param;
    field $log = MessageLog->instance();

    method entity {
        die 'protected method' unless caller()->isa(__PACKAGE__);
        return $entity;
    }

    method perform() { ... }

    method log ( $msg, $color ) {
        die 'protected method' unless caller()->isa(__PACKAGE__);
        $log->add_message( $msg, $color );
    }
}

class MovementAction : isa(Action) {
    field $dx : param = 0;
    field $dy : param = 0;

    field $map : param;

    method perform() {
        my $player = $self->entity();
        my ( $x, $y ) = ( $player->x + $dx, $player->y + $dy );

        die Impossible->new( message => "That way is blocked." )
          unless $map->is_in_bounds( $x, $y );

        die Impossible->new( message => "That way is blocked." )
          unless $map->tile_at( $x, $y )->is_walkable;

        my $e = $map->has_entity_at( $x, $y );
        if ( $e && $e ne $player ) {
            if ( $e isa Mob ) {
                my $combat = MeleeAttackAction->new(
                    map      => $map,
                    entity   => $player,
                    defender => $e,
                );
                return $combat->perform();
            }
            elsif ( $e isa Item ) {
                my $use = ItemAction->new(
                    map    => $map,
                    entity => $player,
                    item   => $e,
                );
                return $use->perform();
            }
            else {
                die Impossible->new( message => 'Cannot attack ' . $e->name );
            }
        }

        $player->move( $dx, $dy );
    }
}

class MeleeAttackAction : isa(Action) {
    use Games::Dice qw(roll);

    field $defender : param;
    field $map : param;

    method perform() {
        my $attacker    = $self->entity;
        my $attack_roll = roll('1d20') + $attacker->stats->strength;
        my $defense     = $defender->stats->armor + 10;

        $self->log(
            sprintf( '%s attacks %s', $attacker->name, $defender->name ),
            Colors::Attack );

        if ( $attack_roll > $defense ) {
            my $damage = $defense - $attack_roll;
            $self->log(
                sprintf( '%s deals %d damage', $attacker->name, abs($damage) ),
                Colors::Attack
            );
            $defender->stats->change_hp($damage);
            return if $defender->stats->hp > 0;    # still alive

            $map->remove_entity($defender);
            if ( $defender->char eq '@' ) {
                die GameOver->new( message => "You died. Game over." );
            }
        }
        else {
            $self->log( sprintf( '%s misses', $attacker->name ),
                Colors::Attack );
        }
        return;
    }
}

class WaitAction : isa(Action) {
    method perform() { }
}

class QuitAction : isa(Action) {
    method perform() { exit }
}

class ItemAction : isa(Action) {
    use experimental 'builtin';
    use builtin qw(blessed);

    field $map : param;
    field $item : param;

    method perform() {
        $item->activate($self);
        $map->remove_entity($item);
    }

    method entity() {
        die 'protected method' unless caller()->isa( blessed $item);
        $self->SUPER::entity();
    }

    method log ( $msg, $color ) {
        die 'protected method' unless caller()->isa( blessed $item);
        $self->SUPER::log( $msg, $color );
    }
}
