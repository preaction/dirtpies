package dirtpies {

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Spritemap;
    import net.flashpunk.tweens.motion.Motion;
    import net.flashpunk.FP;

    import dirtpies.Level;
    import dirtpies.Player;

    public class Medic extends Entity {

        [Embed( source = "/assets/medic.gif" )]
        private const MEDIC_SPRITE:Class;
        public static const FRAME_HEIGHT:int = 32;
        public static const FRAME_WIDTH:int = 80;
        public static const PIXELS_PER_FRAME:int = 8;
        public static const FRAMES_PER_SECOND:int = 24;

        public var anim:Spritemap;
        public var motion:Motion; // We can only follow the motions
        public var carryingPlayer:Boolean = false;
        public var direction:String;

        public function Medic( x:int=0, y:int=0 ) {
            this.x = x;
            this.y = y;
            this.type = "medic";
            height = FRAME_HEIGHT;
            width = FRAME_WIDTH;

            centerOrigin();

            anim = new Spritemap( MEDIC_SPRITE, FRAME_WIDTH, FRAME_HEIGHT );
            anim.add( "move", [ 0, 1, 2, 3, 4, 5, 6, 7 ], FRAMES_PER_SECOND, true );
            anim.centerOO();
            graphic = anim;
            anim.play( "move" );
        }

        override public function update():void {
            this.x = motion.x;
            this.y = motion.y;

            var level:Level = FP.world as Level;
            var player:Player = level.player;

            if ( !carryingPlayer ) {
                if ( direction == "left" && this.x <= player.x ) {
                    carryingPlayer = true;
                }
                if ( direction == "right" && this.x >= player.x ) {
                    carryingPlayer = true;
                }
            }
            else {
                player.x = this.x;
                player.y = this.y - Player.DEAD_HEIGHT + 3;
            }
        }
    }
}
