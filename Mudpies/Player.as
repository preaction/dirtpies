package Mudpies {

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Spritemap;
    import net.flashpunk.graphics.Canvas;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;
    import net.flashpunk.utils.Key;
    import net.flashpunk.utils.Draw;
    import net.flashpunk.Tween;
    import net.flashpunk.tweens.motion.Motion;
    import net.flashpunk.tweens.motion.LinearMotion;
    import net.flashpunk.tweens.motion.LinearPath;
    import net.flashpunk.FP;

    import flash.geom.Rectangle;

    import Mudpies.Level;
    import Mudpies.Door;
    import Mudpies;
    import Mudpies.Medic;

    public class Player extends Entity {
        [Embed( source = "/assets/player-green.gif" )]
        private const PLAYER_GREEN:Class;

        [Embed( source = "/assets/player_green_dead.gif" )]
        private const PLAYER_GREEN_DEAD:Class;

        public static const FRAME_HEIGHT:int = 32;
        public static const FRAME_WIDTH:int = 18;
        public static const DEAD_HEIGHT:int = 16;
        public static const DEAD_WIDTH:int = 32;
        public static const HIT_HEIGHT:int = 30;
        public static const HIT_WIDTH:int = 6;
        public static const PIXELS_PER_FRAME:int = 5;
        public static const FRAMES_PER_SECOND:int = 24;

        public var anim:Spritemap;
        public var playing:Boolean = false; // Is the player in control
        public var hasPie:Boolean = false;

        public function Player() {
            // add a centered hitbox
            width = HIT_WIDTH;
            height = HIT_HEIGHT;
            centerOrigin();

            anim = new Spritemap( PLAYER_GREEN, FRAME_WIDTH, FRAME_HEIGHT );
            anim.add( "stand", [ 0 ] );
            anim.add( "move", [ 1, 2, 3, 4, 5, 6, 7, 8 ], FRAMES_PER_SECOND, true );
            anim.add( "stand_pie", [ 9 ] );
            anim.add( "move_pie", [ 10, 11, 12, 13, 14, 15, 16, 17 ], FRAMES_PER_SECOND, true );
            anim.centerOO();
            graphic = anim;

            Input.define("up", Key.UP, Key.W);
            Input.define("down", Key.DOWN, Key.S);
            Input.define("left", Key.LEFT, Key.A);
            Input.define("right", Key.RIGHT, Key.D);
        }

        override public function update():void {
            if ( playing ) {
                updatePlaying();
            }
        }

        public function updatePlaying():void {
            var level = FP.world as Level;
            var new_x   = x;
            var new_y   = y;

            var flip:Boolean = false; // Are we flipped?
            if ( Input.check("up") ) {
                new_y -= PIXELS_PER_FRAME;
            }
            if ( Input.check("down") ) {
                new_y += PIXELS_PER_FRAME;
            }
            if ( Input.check("right") ) {
                flip = true;
                new_x += PIXELS_PER_FRAME;
            }
            if ( Input.check("left") ) {
                new_x -= PIXELS_PER_FRAME;
            }

            // Check if we're at the exit!
            var door = collide( "door_exit", new_x, new_y ) as Door;
            if ( door ) {
                // Go to the next level
                var changeLevel = function(){
                    var level = FP.world as Level;
                    level.removeAll();
                    var newLevel = new Level( level.player, level.number+1 );
                    FP.world = newLevel;
                };
                door.exit( this, changeLevel );
                this.playing = false;
                this.anim.play( hasPie ? "move_pie" : "move" );
                return;
            }

            // if we're not leaving, make sure we don't leave the level
            if ( x != new_x || y != new_y ) {
                moveTo( new_x, new_y, "wall", true );
                if ( hasPie ) {
                    anim.play( "move_pie" );
                }
                else {
                    anim.play( "move" );
                }
            }
            else {
                if ( hasPie ) {
                    anim.play( "stand_pie" );
                }
                else {
                    anim.play( "stand" );
                }
            }

            if ( flip ) {
                anim.flipped = true;
            }
            else {
                anim.flipped = false;
            }

            // Have we intersected a pie?
            if ( !hasPie ) {
                var pie = collide( "pie", x, y );
                if ( pie ) {
                    FP.world.remove(pie)
                    hasPie = true;
                }
            }
            else {
                if ( Input.mousePressed ) {
                    fire();
                }
            }

            // Have we intersected something deadly?
            var killer:Entity = collideTypes( [ "pin", "clown" ], x, y );
            if ( killer ) {
                die();
            }
        }

        public function fire():void {
            if ( !hasPie ) {
                return;
            }
            hasPie = false;

            var x1:int = centerX, y1:int = centerY, x2:int, y2:int;
            // Get slope
            var dx:Number = Input.mouseX - x1;
            var dy:Number = Input.mouseY - y1;
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

            var firedPie = new Pie();
            firedPie.x = x1;
            firedPie.y = y1;
            firedPie.type = "pie_fired";
            firedPie.fired = true;
            FP.world.add( firedPie );
            var removePie = function(){
                // If pie has any clowns, remove them too
                FP.world.remove( firedPie );
            };
            var tween:LinearMotion = new LinearMotion( removePie, Tween.ONESHOT );
            tween.setMotionSpeed( x1, y1, x2, y2, 320 );
            addTween( tween, true );
            firedPie.motion = tween;
        }

        public function die():void {
            var level:Level = FP.world as Level;

            // I'VE FALLEN AND I CAN'T GET UP!
            playing = false;
            hasPie = false;
            graphic = new Image( PLAYER_GREEN_DEAD );
            graphic.x = -DEAD_WIDTH/2;

            // MEDIC!
            var medic:Medic = new Medic();
            FP.world.add( medic );

            // Closest door on left and right
            var left_location:int;
            var left_distance:Number    = 100000000; // ONE HUNDRED MILLION DOLLARS
            var right_location:int;
            var right_distance:Number   = 1000000000; // ONE BILLION DOLLARS

            // right
            for ( var i = 3; i <= 5; i++ ) {
                var door:Door = level.doorByLocation[ i ];
                if ( door.type != "door_enemy" ) {
                    continue;
                }
                var distance:Number = door.distanceToPoint( x, y );
                if ( distance < right_distance ) {
                    right_distance = distance;
                    right_location = i;
                }
            }

            // left
            for ( var i = 9; i <= 11; i++ ) {
                var door:Door = level.doorByLocation[ i ];
                if ( door.type != "door_enemy" ) {
                    continue;
                }
                var distance:Number = door.distanceToPoint( x, y );
                if ( distance < left_distance ) {
                    left_distance = distance;
                    left_location = i;
                }
            }

            // Build a path
            var self:Player = this;
            var motion:LinearPath = new LinearPath( 
                function():void{ level.remove( medic ); level.startPlayer(self) }, 
                Tween.ONESHOT
            );

            // Closest door is enter
            if ( left_distance < right_distance ) {
                var door_loc:Object = Door.DOOR_LOCATIONS[left_location].origin;
                // Enter left
                // Start off-screen
                medic.x = door_loc.x;
                medic.y = door_loc.y;
                medic.direction = "right";
                motion.addPoint( door_loc.x, door_loc.y );
                motion.addPoint( door_loc.x + Medic.FRAME_WIDTH, door_loc.y );

                // FLIP BABY FLIP
                (medic.graphic as Spritemap).flipped = true;

            }
            else {
                var door_loc:Object = Door.DOOR_LOCATIONS[right_location].origin;
                // Enter right
                // Start off-screen
                medic.x = door_loc.x + Medic.FRAME_WIDTH;
                medic.y = door_loc.y;
                medic.direction = "left";
                motion.addPoint( door_loc.x + Medic.FRAME_WIDTH, door_loc.y );
                motion.addPoint( door_loc.x - Medic.FRAME_WIDTH, door_loc.y );

                (medic.graphic as Spritemap).flipped = false;
            }

            // Midpoint is our deceased corpse
            motion.addPoint( x, y+DEAD_HEIGHT-3 );

            // Other door is exit
            if ( left_distance < right_distance ) {
                var door_loc:Object = Door.DOOR_LOCATIONS[right_location].origin;
                // Exit right
                // Start off-screen
                motion.addPoint( door_loc.x, door_loc.y );
                motion.addPoint( door_loc.x + Medic.FRAME_WIDTH, door_loc.y );
            }
            else {
                var door_loc:Object = Door.DOOR_LOCATIONS[left_location].origin;
                // Exit left
                // End off-screen
                motion.addPoint( door_loc.x + Medic.FRAME_WIDTH, door_loc.y );
                motion.addPoint( door_loc.x - Medic.FRAME_WIDTH, door_loc.y );
            }

            medic.motion = motion;
            motion.setMotion( 3 );
            FP.world.addTween( motion, true );
        }
    }
}
