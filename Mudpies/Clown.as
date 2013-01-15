package Mudpies {

    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Spritemap;
    import net.flashpunk.Tween;
    import net.flashpunk.tweens.motion.Motion;
    import net.flashpunk.tweens.motion.LinearMotion;
    import net.flashpunk.FP;

    import Mudpies.Level;
    import Mudpies.Pie;

    public class Clown extends Entity {
        [Embed( source = "/assets/clown.gif" )]
        private const CLOWN_SPRITE:Class;

        public static const FRAME_HEIGHT:int = 36;
        public static const FRAME_WIDTH:int = 30;
        public static const HIT_HEIGHT:int = 26;
        public static const HIT_WIDTH:int = 18;
        public static const FRAMES_PER_SECOND:int = 8;

        public var anim:Spritemap;
        public var door:int = 0;
        public var level:int = 0;
        public var hit:Boolean = false;
        public var pie:Pie = null; // The pie we were hit by
        public var playing:Boolean = false;
        public var nextPoint:int = 0; // Frames until the next point change
        public var movement:Motion = null;
        public var leftRight:String = "left"; // When we hit a wall, which way should we go?
        public var upDown:String = "up"; // When we hit a wall, which way should we go?

        public function Clown( level:int, door:int ) {
            this.level = level;
            this.door = door;
            type = "clown";

            width = HIT_WIDTH;
            height = HIT_HEIGHT;
            setHitbox( width, height );
            centerOrigin();

            anim = new Spritemap( CLOWN_SPRITE, FRAME_WIDTH, FRAME_HEIGHT );
            anim.add( "move", [ 0, 1 ], FRAMES_PER_SECOND, true );
            anim.centerOO();
            graphic = anim;
            anim.play( "move" );
        }

        override public function update():void {
            if ( playing && !hit ) {
                // Keep pushing on
                var hitWall:Boolean = false;
                if ( movement ) {
                    moveTo( movement.x, movement.y, "wall" );
                    hitWall = collide( "wall", movement.x, movement.y ) as Boolean;
                }

                var player:Player = (FP.world as Level).player;

                // Should we change our point?
                if ( hitWall || nextPoint-- <= 0 ) {
                    if ( movement ) {
                        removeTween( movement );
                    }

                    // Set a new point
                    var point:Point;

                    // Randomly choose between "random point" and "player"
                    if ( Math.random() < 0.5 ) {
                        point = new Point( player.x, player.y );
                    }
                    else {
                        var min_x:int = Level.LEVEL_INNER_OFFSET.x;
                        var max_x:int = Level.LEVEL_INNER_OFFSET.x + Level.LEVEL_INNER_SIZE.x;
                        var min_y:int = Level.LEVEL_INNER_OFFSET.y;
                        var max_y:int = Level.LEVEL_INNER_OFFSET.y + Level.LEVEL_INNER_SIZE.y;
                        var rand_x:int = Math.random() * ( max_x - min_x ) + min_x;
                        var rand_y:int = Math.random() * ( max_y - min_y ) + min_y;
                        point = new Point( rand_x, rand_y );
                    }

                    // Set a length for our new motion
                    nextPoint = Math.random() * ( 50 - 10 ) + 10;

                    // Create the motion
                    var movement:LinearMotion = new LinearMotion( function():void{ movement = null }, Tween.ONESHOT );
                    this.movement = movement;
                    movement.setMotionSpeed( x, y, point.x, point.y, 60 );
                    addTween( movement, true );
                }

                // Take a shot?
                if ( Math.random() < 0.001 ) {
                    var pin:Pin = new Pin( x, y );
                    FP.world.add( pin );

                    // How accurate is our shot?
                    var ACCURACY_RADIUS:int = 5 * Level.WALL_WIDTH;
                    var hit_x:int = Math.random() * ( player.x - ACCURACY_RADIUS - player.x + ACCURACY_RADIUS ) + player.x + ACCURACY_RADIUS;
                    var hit_y:int = Math.random() * ( player.y - ACCURACY_RADIUS - player.y + ACCURACY_RADIUS ) + player.y + ACCURACY_RADIUS;

                    // Trace to the wall
                    var x1:int = x, y1:int = y, x2:int, y2:int;
                    // Get slope
                    var dx:Number = hit_x - x1;
                    var dy:Number = hit_y - y1;
                    var m:Number = dy/dx;

                    if ( dx < 0 ) {
                        // Left wall
                        x2 = Level.LEVEL_OFFSET.x;
                        y2 = m * ( x2 - x1 ) + y1;
                    }
                    else {
                        // Right wall
                        x2 = Level.LEVEL_OFFSET.x + Level.LEVEL_SIZE.x;
                        y2 = m * ( x2 - x1 ) + y1;
                    }

                    // Motion!
                    var callback:Function = function():void{
                        FP.world.remove( pin );
                    }
                    pin.x = x1;
                    pin.y = y1;
                    var tween:LinearMotion = new LinearMotion( callback, Tween.ONESHOT );
                    tween.setMotionSpeed( x1, y1, x2, y2, 160 );
                    addTween( tween, true );
                    pin.motion = tween;
                }
            }
        }
    }
}
