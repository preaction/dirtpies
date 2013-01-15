package {

    import net.flashpunk.Engine;
    import net.flashpunk.FP;
    import net.flashpunk.debug.Console;

    import Mudpies.Level;
    import Mudpies.Player;

    public class Mudpies extends Engine {

        public function Mudpies() {
            super( 960, 600, 24, false );
        }

        override public function init():void {
            var player:Player = new Player();
            FP.world = new Level(player);
        }

        public static function set score(newScore:int) {
            score = newScore;
            // Update scoreboard

        }
    }
}
