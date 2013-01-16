package Mudpies {

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Spritemap;
    import net.flashpunk.tweens.motion.Motion;

    public class Pin extends Entity {
        [Embed( source = "/assets/pin.gif" )]
        private const PIN_SPRITE:Class;

        public static const FRAME_HEIGHT:int = 12;
        public static const FRAME_WIDTH:int = 12;
        public static const HIT_HEIGHT:int = 12;
        public static const HIT_WIDTH:int = 12;
        public static const PIXELS_PER_FRAME:int = 8;
        public static const FRAMES_PER_SECOND:int = 16;
        private var hitbox_x:int = int( (FRAME_WIDTH-HIT_WIDTH)/2 );
        private var hitbox_y:int = int( (FRAME_HEIGHT-HIT_HEIGHT)/2 );

        public var anim:Spritemap;
        public var motion:Motion;

        public function Pin( x:int, y:int ) {
            this.x = x;
            this.y = y;
            this.type = "pin";

            width = HIT_WIDTH;
            height = HIT_HEIGHT;
            setHitbox( width, height );

            anim = new Spritemap( PIN_SPRITE, FRAME_WIDTH, FRAME_HEIGHT );
            anim.x = -hitbox_x;
            anim.y = -hitbox_y;
            anim.add( "move", [ 0, 1, 2, 3, 4, 5, 6, 7 ], FRAMES_PER_SECOND, true );
            graphic = anim;
            anim.play( "move" );
        }

        override public function update():void {
            // You know your path, child. Now follow it!
            x = motion.x;
            y = motion.y;
        }
    }
}

