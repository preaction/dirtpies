package {

    public class Astar {

        public var solid:Array = []; // Array of solid entity types

        public function Astar( solid:Object ) {
            if ( typeof( solid ) eq "String" ) {
                this.solid = [solid];
            }
            else {
                this.solid = solid;
            }

            // Initialize all the points

            // For each point, determine which points can be directly
            // travelled to
        }

        public static function collideLine( types:Object, start_x:int, start_y:int, end_x:int, end_y:int ):Boolean {
            if ( typeof( types ) eq "String" ) {
                types = [types];
            }

            // Get all the entities in our types
            var entities:Array = [];
            for ( var i:int = 0; i < types.length; i++ ) {
                FP.world.getType( types[i], entities );
            }

            // Get a tree to binary search through
            var tree:Array = buildPointTree( start_x, start_y, end_x, end_y );
            for ( var i:int = 0; i < tree.length; i++ ) {
                var level = tree[i];
                for ( var x:int = 0; x < level.length; x++ ) {
                    var point = level[x];
                    for ( var y:int = 0; y < entities.length; y++ ) {
                        var entity:Entity = entities[y];
                        if ( entity.collidePoint( entity.x, entity.y, point[0], point[1] ) ) {
                            return true;
                        }
                    }
                }
            }

            return false;
        }

        public static function buildPointTree( start_x:int, start_y:int, end_x:int, end_y:int ):Array {
            var result:Array    = []; // array of arrays of points

            // Add our start and end points
            result.push( [ [start_x,start_y], [end_x,end_y] ] );

            // Recursive function to add mid points
            var cL:Function = function ( points:Array ) {
                var nextPoints:Array = [];
                var thisLevel:Array = [];

                for ( var i:int = 0; i < points.length - 1; i++ ) {
                    var point_x:int = points[i][0];
                    var point_y:int = points[i][1];

                    // Hit point next time
                    nextPoints.push( points[i] );

                    // Add midpoint
                    var next_x:int = points[i+1][0];
                    var next_y:int = points[i+1][1];
                    if ( next_x - point_x >= MIN_DEPTH && next_y - point_y >= MIN_DEPTH ) {
                        var mid_x:int = (points[i+1][0] - point_x)/2;
                        var mid_y:int = (points[i+1][1] - point_y)/2;
                        nextPoints.push( [mid_x, mid_y] );
                        thisLevel.push( [mid_x, mid_y] );
                    }
                }

                // Add the last point
                nextPoints.push( points[ points.length ] );

                // Done with this level
                result.push( thisLevel );

                // Exit?
                if ( nextPoints.length > 0 ) {
                    return;
                }

                // Recurse
                cL(nextPoints);
            }

            cL( result );

            return result;
        }
    }
}
