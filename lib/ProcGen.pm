use 5.38.0;
use warnings;
use experimental 'class';


class RectangularRoom {
    field $x1 :param(x);
    field $y1 :param(y); #()()
    field $height :param;
    field $width :param;

    field $x2 = $x1 + $width;
    field $y2 = $y1 + $height;


    method random_point() {
       my $x = int($x1 + rand($width) + 1);
       my $y = int($y1 + rand($height) + 1);
       return [$x, $y]
    }

    method center() {
        my $x = int($x1 + $width / 2);
        my $y = int($y1 + $height / 2);
        return [$x, $y];
    }

    method inner() {
        [$x1 + 1 .. $x2], [$y1 + 1 .. $y2];
    }

    method intersects($other) {
        if ($other isa RectangularRoom) {
            return $other->intersects({
                x1 => $x1,
                y1 => $y1,
                x2 => $x2,
                y2 => $y2,
            });
        }

        if (ref $other eq 'HASH') {
			if (
				$x2 < $other->{x1} ||
				$y2 < $other->{y1} ||
				$other->{x2} < $x1 ||
				$other->{y2} < $y1
				) { return 0 }

			return 1
		}
        die "$other is not a RectangularRoom object";
    }
}

class SimpleDungeonGenerator {
    use List::Util qw(min max any);
    use GameMap;

    field $width    :param;
    field $height   :param;
    field $rooms    :param(room_count);
    field $max_monsters_per_room :param;
    field $min_size :param(min_room_size);
    field $max_size :param(max_room_size);
    field $player   :param;

    my sub place_entities($room, $map, $max) {
        my $num = int rand($max + 1); # need one more than we want cause 0 is a choice
        for my $i (1..$num) {
            my ($x, $y) = $room->random_point()->@*;
            if (! $map->has_entity_at($x, $y)) {
                my $e = rand() < 0.8 ? Entities::goblin() : Entities::hobgoblin();
                $map->spawn($e, $x, $y);
            }
        }
    }

    my sub tunnel_between($map, $start, $end) {
        my ($x1, $y1) = @$start;
        my ($x2, $y2) = @$end;
        if (rand() < 0.5) {
            $map->_tiles_to_floor([min($x1, $x2)..max($x1, $x2)],[$y1]);
            $map->_tiles_to_floor([$x2],[min($y1, $y2)..max($y1, $y2)]);
        } else {
            $map->_tiles_to_floor([min($x1, $x2)..max($x1, $x2)],[$y2]);
            $map->_tiles_to_floor([$x1],[min($y1, $y2)..max($y1, $y2)]);
        }
    }

    method generate_dungeon() {
        my $map = GameMap->new(width  => $width, height => $height, entities => [$player]);

        my @rooms;
        for (0..$rooms) {
            my $room_width = int($min_size + rand($max_size + 1 - $min_size));
            my $room_height = int($min_size + rand($max_size + 1 - $min_size));

            my $room = RectangularRoom->new(
                x => int(0 + rand($width - $room_width)),
                y => int(0 + rand($height - $room_height)),
                width  => $room_width,
                height => $room_height,
            );

            # if the new room intersects with a current room, skip it
            next if any { $_->intersects($room) } @rooms;

            # otherwise, dig out the floor
            $map->_tiles_to_floor($room->inner);

            # tunnel between the previous room and this one
            tunnel_between($map, $rooms[-1]->center, $room->center) if @rooms;

            # add some monsters
            place_entities($room, $map, $max_monsters_per_room);

            # add the room to the list
            push @rooms, $room;
        }

        $player->move($rooms[0]->center->@*);
        return $map;
    }
}


