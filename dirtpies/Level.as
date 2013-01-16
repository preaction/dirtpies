package dirtpies {

    import net.flashpunk.World;
    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.Tween;
    import net.flashpunk.tweens.motion.LinearMotion;
    import net.flashpunk.tweens.misc.Alarm;
    import net.flashpunk.FP;

    import dirtpies.Player;
    import dirtpies.Pie;
    import dirtpies.Door;

    public class Level extends World {
        [Embed( source = "/assets/level-back.gif" )]
        public static const LEVEL_BACK:Class;

        public static const LEVEL_OFFSET:Object = { x: 80, y:0 };
        public static const LEVEL_SIZE:Object = { x:720, y:600 };
        public static const WALL_WIDTH:int = 16;
        public static const LEVEL_INNER_OFFSET:Object = { 
            x:LEVEL_OFFSET.x+WALL_WIDTH,
            y:LEVEL_OFFSET.y+WALL_WIDTH
        };
        public static const LEVEL_INNER_SIZE:Object = { 
            x:LEVEL_SIZE.x-WALL_WIDTH*2,
            y:LEVEL_SIZE.y-WALL_WIDTH*2
        };

        public const DOORS_BY_LEVEL:Array = [
            {
                enemy : [ 0, 1, 4, 5, 6, 7, 10, 11 ],
                closed : [ 2, 9 ],
                enter : 3,
                exit : 8
            },
            {
                enemy : [ 1, 2, 3, 4, 7, 8, 9, 10 ],
                closed : [ 5, 11 ],
                enter : 0,
                exit : 6
            },
            {
                enemy : [ 0, 1, 4, 5, 6, 7, 10, 11 ],
                closed : [ 3, 8 ],
                enter : 2,
                exit : 9
            },
            {
                enemy : [ 1, 2, 3, 4, 7, 8, 9, 10 ],
                closed : [ 6, 11 ],
                enter : 5,
                exit : 0
            },
            {
                enemy : [ 0, 1, 4, 5, 6, 7, 10, 11 ],
                closed : [ 3, 9 ],
                enter : 8,
                exit : 2
            },
            {
                enemy : [ 1, 2, 3, 4, 7, 8, 9, 10 ],
                closed : [ 5, 0 ],
                enter : 6,
                exit : 11
            }
        ];

        public const WALLS_BY_LEVEL:Array = [
            [ ],        // First level has no inner walls
            [
                {
                    tile: "fence",
                    x: LEVEL_INNER_OFFSET.x+WALL_WIDTH*8,
                    y: LEVEL_INNER_OFFSET.y+(LEVEL_INNER_SIZE.y/2)-WALL_WIDTH/2,
                    width: WALL_WIDTH * 27,
                    height: WALL_WIDTH
                }
            ],
            [
                {
                    tile : "yellow_circle",
                    x: LEVEL_INNER_OFFSET.x+WALL_WIDTH*6-WALL_WIDTH/2,
                    y: LEVEL_INNER_OFFSET.y+(LEVEL_INNER_SIZE.y/2)-WALL_WIDTH,
                    width: WALL_WIDTH * 32,
                    height: WALL_WIDTH * 2
                },
                {
                    tile : "yellow_circle",
                    x: LEVEL_INNER_OFFSET.x+(LEVEL_INNER_SIZE.x/2)-WALL_WIDTH,
                    y: LEVEL_INNER_OFFSET.y+WALL_WIDTH*4+WALL_WIDTH*0.75,
                    width: WALL_WIDTH*2,
                    height: WALL_WIDTH*26
                }
            ],
            [
                {
                    tile : "blue_diamond",
                    x: LEVEL_INNER_OFFSET.x+WALL_WIDTH*5,
                    y: LEVEL_INNER_OFFSET.y+WALL_WIDTH*5,
                    width: WALL_WIDTH,
                    height: WALL_WIDTH*12
                },
                {
                    tile : "blue_diamond",
                    x: LEVEL_INNER_OFFSET.x+WALL_WIDTH*5,
                    y: LEVEL_INNER_OFFSET.y+WALL_WIDTH*5,
                    width: WALL_WIDTH*12,
                    height: WALL_WIDTH
                },
                {
                    tile : "blue_diamond",
                    x: LEVEL_INNER_OFFSET.x+LEVEL_INNER_SIZE.x-WALL_WIDTH*5,
                    y: LEVEL_INNER_OFFSET.y+LEVEL_INNER_SIZE.y-WALL_WIDTH*5-WALL_WIDTH*11,
                    width: WALL_WIDTH,
                    height: WALL_WIDTH*12
                },
                {
                    tile : "blue_diamond",
                    x: LEVEL_INNER_OFFSET.x+LEVEL_INNER_SIZE.x-WALL_WIDTH*5-WALL_WIDTH*11,
                    y: LEVEL_INNER_OFFSET.y+LEVEL_INNER_SIZE.y-WALL_WIDTH*5,
                    width: WALL_WIDTH*11,
                    height: WALL_WIDTH
                }
            ]
        ];


        public var number:int = 0;
        public var doorSet:int = 0;
        public var player:Player = null;
        public var enterDoor:Door;
        public var enemies:Array = [];
        public var doorByLocation:Object = {};
        public var clownByDoor:Object = {};

        public function Level( player:Player, number:int=0 ) {
            this.player = player;
            this.number = number;
            this.doorSet = number % DOORS_BY_LEVEL.length;

            var back:Entity = addGraphic( new Image(LEVEL_BACK), 0, LEVEL_OFFSET.x, LEVEL_OFFSET.y );
        }

        override public function begin():void {
            // Initialize outer walls
            // top
            add( new Wall( LEVEL_OFFSET.x, LEVEL_OFFSET.y, LEVEL_SIZE.x, WALL_WIDTH ) );
            // right
            add( new Wall( LEVEL_INNER_OFFSET.x+LEVEL_INNER_SIZE.x, LEVEL_OFFSET.y, WALL_WIDTH, LEVEL_SIZE.y ) );
            // bottom
            add( new Wall( LEVEL_OFFSET.x, LEVEL_INNER_OFFSET.y+LEVEL_INNER_SIZE.y, LEVEL_SIZE.x, WALL_WIDTH ) );
            // left
            add( new Wall( LEVEL_OFFSET.x, LEVEL_OFFSET.y, WALL_WIDTH, LEVEL_SIZE.y ) );

            // Initialize any inner walls
            buildInnerWalls();

            // Initialize pies after walls to prevent overlap
            buildPies();

            // Initialize doors
            var door_def:Object = getDoorDefinition();
            for ( var i:int = 0; i < door_def.enemy.length; i++ ) {
                var door:Door = new Door( "door_enemy", door_def.enemy[i] );
                add( door );
                doorByLocation[ door_def.enemy[i] ] = door;

                // Add enemy
                buildClown( number, door );
            }
            for ( var i:int = 0; i < door_def.closed.length; i++ ) {
                var door:Door = new Door( "door_closed", door_def.closed[i] );
                doorByLocation[ door_def.closed[i] ] = door;
                add( door );
            }
            var enterDoor:Door = new Door( "door_enter", door_def.enter ); 
            doorByLocation[ door_def.enter ] = enterDoor;
            add( enterDoor );
            var exitDoor:Door = new Door( "door_exit", door_def.exit );
            doorByLocation[ door_def.exit ] = exitDoor;
            add( exitDoor );

            // Add player
            add( player );
            startPlayer( player );

            // Start the clown respawn countdown
            var self:Level = this;
            addTween( 
                new Alarm( 15, function():void{ self.refreshClowns(); }, Tween.LOOPING ),
                true
            );
        }

        public function getDoorDefinition( ):Object {
            return DOORS_BY_LEVEL[ doorSet ];
        }

        public function buildPies():void {
            var min_x:int = LEVEL_INNER_OFFSET.x;
            var max_x:int = LEVEL_INNER_OFFSET.x + LEVEL_INNER_SIZE.x - Pie.FRAME_WIDTH;
            var min_y:int = LEVEL_INNER_OFFSET.y;
            var max_y:int = LEVEL_INNER_OFFSET.y + LEVEL_INNER_SIZE.y - Pie.FRAME_HEIGHT;
            for ( var i:int = 0; i < 50; i++ ) {
                var pie:Pie = new Pie();
                pie.x = Math.random() * ( max_x - min_x ) + min_x;
                pie.y = Math.random() * ( max_y - min_y ) + min_y;
                pie.type = "pie";
                add( pie );
                var wall:Entity = pie.collide( "wall", pie.x, pie.y );
                while ( wall ) {
                    trace(" PIE COLLIDED! ");
                    pie.x = Math.random() * ( max_x - min_x ) + min_x;
                    pie.y = Math.random() * ( max_y - min_y ) + min_y;
                    wall = pie.collide( "wall", pie.x, pie.y );
                }
            }
        }

        public function buildInnerWalls():void {
            var walls:Array = WALLS_BY_LEVEL[ number ];
            for ( var i:int = 0; i < walls.length; i++ ) {
                var wall:Object = walls[i];
                add( new Wall( wall.x, wall.y, wall.width, wall.height, wall.tile ) );
            }
        }

        public function buildClown( number:int, door:Door ):void {
            var clown:Clown = new Clown( number, door.location );
            add( clown );
            clownByDoor[ door.location ] = clown;
            clown.anim.play("move");

            door.enter( clown, function():void {
                clown.playing = true;
            } );
        }

        public function refreshClowns( ):void {
            var door_def:Object = getDoorDefinition();
            for ( var i:int = 0; i < door_def.enemy.length; i++ ) {
                var location:int = door_def.enemy[i];
                if ( clownByDoor[ location ].hit ) {
                    buildClown( location, doorByLocation[ location ] );
                }
            }
        }

        public function startPlayer( player:Player ):void {
            // Send in the player
            var door_def:Object = getDoorDefinition();
            var enterDoor:Door = doorByLocation[ door_def.enter ];
            enterDoor.enter( player, function():void {
                player.playing = true;
            } );
            player.graphic = player.anim;
            player.anim.play( player.hasPie ? "move_pie" : "move" );
        }
    }
}

