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
        if ( my $e = $map->has_entity_at( $x, $y ) ) {
            return if $e->blocks_movement;
        }
        $player->move( $dx, $dy );
    }
}

class QuitAction :isa(Action) {
    method perform() { exit }
}
