package Mudpies {

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.Tween;
    import net.flashpunk.FP;
    import flash.geom.Rectangle;

    import Mudpies.Level;
    import Mudpies.Player;

    public class Door extends Entity {
        [Embed( source = "/assets/door-closed.gif" )]
        public static const DOOR_CLOSED:Class;

        [Embed( source = "/assets/door-oneway.gif" )]
        public static const DOOR_ONEWAY:Class;

        public static const DOOR_TYPES:Object = {
            door_enemy : DOOR_ONEWAY,
            door_enter : DOOR_ONEWAY,
            door_exit : null,
            door_closed : DOOR_CLOSED
        };

        public static const DOOR_WIDTH:int = 96;

        public static const DOOR_COL_1:int = 70 + DOOR_WIDTH/2;
        public static const DOOR_COL_2:int = 310 + DOOR_WIDTH/2;
        public static const DOOR_COL_3:int = 550 + DOOR_WIDTH/2;

        public static const DOOR_ROW_1:int = 64 + DOOR_WIDTH/2;
        public static const DOOR_ROW_2:int = 252 + DOOR_WIDTH/2;
        public static const DOOR_ROW_3:int = 442 + DOOR_WIDTH/2;

        public static const DOOR_LOCATIONS:Array = [
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + DOOR_COL_1,
                    y: Level.LEVEL_OFFSET.y + Level.WALL_WIDTH/2,
                    a: 0
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + DOOR_COL_2,
                    y: Level.LEVEL_OFFSET.y + Level.WALL_WIDTH/2,
                    a: 0
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + DOOR_COL_3,
                    y: Level.LEVEL_OFFSET.y + Level.WALL_WIDTH/2,
                    a: 0
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + Level.LEVEL_SIZE.x - Level.WALL_WIDTH/2,
                    y: DOOR_ROW_1,
                    a: 270
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + Level.LEVEL_SIZE.x - Level.WALL_WIDTH/2,
                    y: DOOR_ROW_2,
                    a: 270
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + Level.LEVEL_SIZE.x - Level.WALL_WIDTH/2,
                    y: DOOR_ROW_3,
                    a: 270
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + DOOR_COL_3,
                    y: Level.LEVEL_OFFSET.y + Level.LEVEL_SIZE.y - Level.WALL_WIDTH/2,
                    a: 180
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + DOOR_COL_2,
                    y: Level.LEVEL_OFFSET.y + Level.LEVEL_SIZE.y - Level.WALL_WIDTH/2,
                    a: 180
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + DOOR_COL_1,
                    y: Level.LEVEL_OFFSET.y + Level.LEVEL_SIZE.y - Level.WALL_WIDTH/2,
                    a: 180
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + Level.WALL_WIDTH/2,
                    y: DOOR_ROW_3,
                    a: 90
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + Level.WALL_WIDTH/2,
                    y: DOOR_ROW_2,
                    a: 90
                }
            },
            {
                origin : {
                    x: Level.LEVEL_OFFSET.x + Level.WALL_WIDTH/2,
                    y: DOOR_ROW_1,
                    a: 90
                }
            }
        ];

        public static const ENTER_DURATION:Number = 0.5;
        public static const ENTER_OFFSET:Number = 40;

        public var location:int;

        public function Door( type:String, location:int ) {
            this.type = type;
            this.location = location;
            var door_loc:Object = DOOR_LOCATIONS[ location ];

            var hitbox_hwidth:Number = (DOOR_WIDTH-2*Player.HIT_WIDTH); // Player must pass through center
            var hitbox_hheight:Number = Level.WALL_WIDTH;
            var hitbox_hx:Number = -hitbox_hwidth/2;
            var hitbox_hy:Number = -hitbox_hheight/2;
            var hitbox_vwidth:Number = Level.WALL_WIDTH;
            var hitbox_vheight:Number = (DOOR_WIDTH-2*Player.HIT_HEIGHT); // Player must pass through center
            var hitbox_vx:Number = -hitbox_vwidth/2;
            var hitbox_vy:Number = -hitbox_vheight/2;

            var hitbox_width:Number, hitbox_height:Number, hitbox_x:Number, hitbox_y:Number;

            if ( location <= 2 ) {
                width = DOOR_WIDTH;
                height = Level.WALL_WIDTH;
                hitbox_width = hitbox_hwidth; hitbox_height = hitbox_hheight;
                hitbox_x = hitbox_hx; hitbox_y = hitbox_hy;
            }
            else if ( location <= 5 ) {
                width = Level.WALL_WIDTH;
                height = DOOR_WIDTH;
                hitbox_width = hitbox_vwidth; hitbox_height = hitbox_vheight;
                hitbox_x = hitbox_vx; hitbox_y = hitbox_vy;
            }
            else if ( location <= 8 ) {
                width = DOOR_WIDTH;
                height = Level.WALL_WIDTH;
                hitbox_width = hitbox_hwidth; hitbox_height = hitbox_hheight;
                hitbox_x = hitbox_hx; hitbox_y = hitbox_hy;
            }
            else {
                width = Level.WALL_WIDTH;
                height = DOOR_WIDTH;
                hitbox_width = hitbox_vwidth; hitbox_height = hitbox_vheight;
                hitbox_x = hitbox_vx; hitbox_y = hitbox_vy;
            }

            x = door_loc.origin.x;
            y = door_loc.origin.y;
            centerOrigin();
            setHitbox( hitbox_width, hitbox_height, -hitbox_x, -hitbox_y );

            if ( DOOR_TYPES[type] ) {
                var image:Image = new Image(DOOR_TYPES[type]);
                image.angle = door_loc.origin.a;
                image.centerOO();
                graphic = image;
            }
        }

        public function enter( e:Entity, callback:Function ):void {
            // 0-2 : down
            // 3-5 : left
            // 6-8 : up
            // 9-11 : right
            var door:Object = DOOR_LOCATIONS[location]

            var x1:int, y1:int, x2:int, y2:int;
            if ( location <= 2 ) {
                x1 = x;
                x2 = x1;
                y1 = y - e.height - halfHeight;
                y2 = y + Level.WALL_WIDTH/2 + ENTER_OFFSET;
            }
            else if ( location <= 5 ) {
                x1 = x + e.width + halfWidth;
                x2 = x - e.width - halfWidth - ENTER_OFFSET;
                y1 = y;
                y2 = y1;
            }
            else if ( location <= 8 ) {
                x1 = x;
                x2 = x1;
                y1 = y + halfHeight;
                y2 = y - e.height - halfHeight - ENTER_OFFSET;
            }
            else {
                x1 = x - e.width - halfWidth;
                x2 = x + e.height + halfWidth + ENTER_OFFSET;
                y1 = y;
                y2 = y1;
            }

            e.x = x1;
            e.y = y1;
            FP.tween( e, { x : x2, y : y2 }, ENTER_DURATION, { type : Tween.ONESHOT, complete : callback } );
        }

        public function exit( e:Entity, callback:Function ):void {
            // 0-2 : up
            // 3-5 : right
            // 6-8 : down
            // 9-11 : left
            var door:Object = DOOR_LOCATIONS[location];

            var x1:int = e.x, y1:int = e.y, x2:int, y2:int;
            if ( location <= 2 ) {
                x2 = x1;
                y2 = y - halfHeight - e.height;
            }
            else if ( location <= 5 ) {
                x2 = x + halfWidth + e.width;
                y2 = y1;
            }
            else if ( location <= 8 ) {
                x2 = x1;
                y2 = y + halfHeight + e.height;
            }
            else {
                x2 = x - halfWidth - e.width;
                y2 = y1;
            }

            e.x = x1;
            e.y = y1;
            FP.tween( e, { x : x2, y : y2 }, ENTER_DURATION, { type : Tween.ONESHOT, complete : callback } );
        }
    }
}
