use 5.38.0;
use warnings;
use experimental 'class';

package Colors {
    use constant White => '#fff';
    use constant Black => '#000';

    use constant DefaultEntityFG => White;
    use constant DefaultEntityBG => Black;
    use constant Goblin          => '#41924B';
    use constant Hobgoblin       => '#ff6f3c';
    use constant Hero            => White;

    use constant DefaultLightTileFG => White;
    use constant DefaultLightTileBG => Black;
    use constant DefaultDarkTileFG  => '#666';
    use constant DefaultDarkTileBG  => Black;

    use constant WelcomeText => '#2AF';
    use constant GameOver    => '#F00';
    use constant Attack      => '#C00';

    use constant BarText   => White;
    use constant BarFilled => '#060';
    use constant BarEmpty  => '#411';
}

