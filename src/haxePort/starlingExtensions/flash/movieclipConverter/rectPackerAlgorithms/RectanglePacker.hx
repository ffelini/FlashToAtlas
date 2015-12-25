package haxePort.starlingExtensions.flash.movieclipConverter.rectPackerAlgorithms;
import flash.geom.Rectangle;
class RectanglePacker extends TexturePacker {

    public function new(width:Float, height:Float) {
        super(width, height);
    }

    public override function packRect(width:Float, height:Float):Rectangle {
        var newNode:Rectangle = new Rectangle(0,0,width + atlasRegionsGap, height + atlasRegionsGap);
        if(!insertRectangle(newNode)) {
            newNode = null;
        }
        return newNode;
    }

/**
         * Tries to insert new rectangle into the packer
         * @param rectangle
         * @return true if inserted successfully
         */

    private inline function insertRectangle(rectangle:Rectangle):Bool {
        var index:Int = getFreeAreaIndex(rectangle);
        if (index < 0) {
            return false;
        }

        var freeArea:Rectangle = freeAreas[index];
        rectangle.x = freeArea.left;
        rectangle.y = freeArea.top;

// Get the new free areas, these are parts of the old ones intersected by the target
        var newFreeAreas:Array<Rectangle> = generateNewSubAreas(rectangle, freeAreas);
        filterSubAreas(newFreeAreas, freeAreas, true);
        var i:Int = newFreeAreas.length;
        while (--i >= 0) {
            freeAreas.push(newFreeAreas[i]);
        }
        return true;
    }

/**
         * Removes rectangles from the filteredAreas that are sub rectangles of any rectangle in areas.
         * @param filteredAreas rectangles to be filtered
         * @param areas rectangles against which the filtering is performed
         * @param removeEqual if true rectangles that are equal to rectangles is areas are also removed
         */

    private inline function filterSubAreas(filteredAreas:Array<Rectangle>, areas:Array<Rectangle>, removeEqual:Bool):Void {
        var i:Int = filteredAreas.length;
        while (--i >= 0) {
            var filtered:Rectangle = filteredAreas[i];
            var j:Int = areas.length;
            while (--j >= 0) {
                var area:Rectangle = areas[j];
                if (area.x <= filtered.x && area.y <= filtered.y &&
                area.x + area.width >= filtered.x + filtered.width &&
                area.y + area.height >= filtered.y + filtered.height &&
                (removeEqual || area.width > filtered.width || area.height > filtered.height)) {
                    filteredAreas.splice(i, 1);
                    break;
                }
            }
        }
    }

/**
         * Checks what areas the given rectangle intersects, removes those areas and
         * returns the list of new areas those areas are divived into
         * @param target the new rectangle that is dividing the areas
         * @param areas the areas to be divided
         * @return list of new areas
         */

    private inline function generateNewSubAreas(target:Rectangle, areas:Array<Rectangle>):Array<Rectangle> {
        var results:Array<Rectangle> = [];
        var i:Int = areas.length;
        while (--i >= 0) {
            var area:Rectangle = areas[i];
            if (!(target.x >= area.x + area.width || target.x + target.width <= area.x ||
            target.y >= area.y + area.height || target.y + target.height <= area.y)) {
                generateDividedAreas(target, area, results);
                areas.splice(i, 1);
            }
        }

        filterSubAreas(results, results, false);
        return results;
    }

/**
         * Divides the area into new sub areas around the divider.
         * @param divider rectangle that intersects the area
         * @param area rectangle to be divided into sub areas around the divider
         * @param results vector for the new sub areas around the divider
         */

    private inline function generateDividedAreas(divider:Rectangle, area:Rectangle, results:Array<Rectangle>):Void {
        if (divider.right < area.right) {
            results.push(new Rectangle(divider.right, area.y, area.right - divider.right, area.height));
        }

        if (divider.x > area.x) {
            results.push(new Rectangle(area.x, area.y, divider.x - area.x, area.height));
        }

        if (divider.bottom < area.bottom) {
            results.push(new Rectangle(area.x, divider.bottom, area.width, area.bottom - divider.bottom));
        }

        if (divider.y > area.y) {
            results.push(new Rectangle(area.x, area.y, area.width, divider.y - area.y));
        }
    }

/**
         * Gets the index of the best free area for the given rectangle
         * @param rectangle
         * @return index of the best free area or -1 if no suitable free area available
         */

    private inline function getFreeAreaIndex(rectangle:Rectangle):Int {
        var best:Rectangle = new Rectangle(curentMaxW, 0, 0, 0);
        var index:Int = -1;
        var i:Int = freeAreas.length;
        while (--i >= 0) {
            var free:Rectangle = freeAreas[i];
            if (rectangle.width <= free.width && rectangle.height <= free.height) {
                if (free.x < best.x || (free.x <= best.x && free.y < best.y)) {
                    index = i;
                    best = free;
                }
            }
        }

        return index;
    }
}
