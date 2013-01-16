package dirtpies {

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.TiledImage;

    public class Wall extends Entity {
        [Embed( source = "/assets/tile_fence.gif" )]
        private const TILE_FENCE:Class;

        [Embed( source = "/assets/tile_brick.gif" )]
        private const TILE_BRICK:Class;

        [Embed( source = "/assets/tile_yellow_circle.gif" )]
        private const TILE_YELLOW_CIRCLE:Class;

        [Embed( source = "/assets/tile_blue_diamond.gif" )]
        private const TILE_BLUE_DIAMOND:Class;

        [Embed( source = "/assets/tile_purple_diamond.gif" )]
        private const TILE_PURPLE_DIAMOND:Class;

        private const tiles:Object = {
            fence               : TILE_FENCE,
            yellow_circle       : TILE_YELLOW_CIRCLE,
            blue_diamond        : TILE_BLUE_DIAMOND,
            brick               : TILE_BRICK,
            purple_diamond      : TILE_PURPLE_DIAMOND
        };

        public function Wall( x:int, y:int, width:int, height:int, tile:String=null ) {
            this.type = "wall";
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
            if ( tile ) {
                graphic = new TiledImage( tiles[tile], width, height );
            }
        }
    }
}
