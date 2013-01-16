package dirtpies {

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Spritemap;
    import net.flashpunk.graphics.Canvas;
    import net.flashpunk.utils.Draw;
    import net.flashpunk.tweens.motion.Motion;
    import net.flashpunk.FP;

    import flash.geom.Rectangle;

    import dirtpies.Clown;

    public class Pie extends Entity {
        [Embed( source = "/assets/pie.gif" )]
        private const PIE_SPRITE:Class;
        public static const FRAME_WIDTH:int = 10;
        public static const FRAME_HEIGHT:int = 10;

        public var anim:Spritemap;
        public var showingHitbox:int = 0;
        public var motion:Motion;
        public var fired:Boolean = false;
        public var clowns:Array = [];

        public function Pie() {
            width = 10;
            height = 10;
            setHitbox( width, height );
            centerOrigin();

            anim = new Spritemap( PIE_SPRITE, FRAME_WIDTH, FRAME_HEIGHT );
            anim.add( "up", [0] );
            anim.add( "up_right", [1] );
            anim.add( "right", [2] );
            anim.add( "down_right", [3] );
            anim.add( "down", [4] );
            anim.add( "down_left", [5] );
            anim.add( "left", [6] );
            anim.add( "up_left", [7] );
            anim.centerOO();
            graphic = anim;
            anim.play( "up" );
        }

        override public function update():void {
            if ( fired ) {
                var dx:Number = x > motion.x ? motion.x - x : x - motion.x;
                var dy:Number = y > motion.y ? motion.y - y : y - motion.y;

                // Move our clowns along with us
                for ( var i:int = 0; i < clowns.length; i++ ) {
                    var clown:Clown = clowns[i];
                    clown.x = x < motion.x ? clown.x - dx : clown.x + dx;
                    clown.y = y < motion.y ? clown.y - dy : clown.y + dy;
                }

                x = motion.x;
                y = motion.y;

                // Check for collision with enemy
                var new_clowns:Array = [];
                collideInto( "clown", x, y, new_clowns );

                // Check if our clowns collided with clowns
                for ( var i:int = 0; i < clowns.length; i++ ) {
                    var clown:Clown = clowns[i];
                    clown.collideInto( "clown", x, y, new_clowns );
                }

                if ( new_clowns.length > 0 ) {
                    // Hit another one!
                    for ( var i:int = 0; i < new_clowns.length; i++ ) {
                        var clown:Clown = new_clowns[i];
                        if ( clown.hit ) {
                            continue;
                        }
                        clown.hit = true;
                        clown.anim.frame = clown.anim.frame;
                        clowns.push( clown );
                    }
                }
            }
        }

        override public function removed():void {
            for ( var i:int = 0; i < clowns.length; i++ ) {
                FP.world.remove(clowns[i]);
            }
        }
    }
}
