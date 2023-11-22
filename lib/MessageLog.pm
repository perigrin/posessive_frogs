use 5.38.0;
use warnings;
use experimental 'class';

use Colors;
use Text::Wrap;

class Message {
    field $text : param;
    field $fg : param;
    field $count = 1;

    method eq ($msg) {
        if ( $msg isa Message ) {
            return $msg->eq($text);
        }
        return "$msg" eq $text;    # pray it stringifies and comp then
    }

    method inc() {
        return $count += 1;
    }

    method color() { $fg }

    method full_text() {
        if ( $count > 1 ) {
            return "$text (x$count)";
        }
        return $text;
    }

}

class MessageLog {

    field @messages = ();

    sub instance($) { state $log = __PACKAGE__->new() }

    method add_message ( $msg, $fg = Colors::White, $stack = !!1 ) {
        if ( $stack && @messages && $messages[-1]->eq($msg) ) {
            $messages[-1]->inc();
        }
        else {
            push @messages, Message->new( text => $msg, fg => $fg );
        }
    }

    my $lines = sub ( $text, $width = 80 ) {
        local $Text::Wrap::columns  = $width;
        local $text::Wrap::unexpand = 0;
        split '\n', Text::Wrap::wrap( '', '', $text );
    };

    method render ( $term, $x, $y, $w, $h ) {
        my $off = $h - 1;
        for my $msg ( reverse @messages ) {
            for my $line ( reverse $lines->( $msg->full_text, $w ) ) {
                $term->puts( $x, $y + $off--, $line, $msg->color );
                return if $off < 0;
            }
        }
    }
}

