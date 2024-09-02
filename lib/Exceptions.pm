use 5.38.0;
use warnings;
use experimental 'class';

use Colors;

class Exception {
    method color()   { ... }
    method message() { ... }
}

class Impossible : isa(Exception) {
    field $message : param;
    field $color = Colors::Impossible;

    method color()   { $color }
    method message() { $message }
}

class GameOver : isa(Exception) {
    field $message : param;
    field $color = Colors::GameOver;

    method color()   { $color }
    method message() { $message }
}
