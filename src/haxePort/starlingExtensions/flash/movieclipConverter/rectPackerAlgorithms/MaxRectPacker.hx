package haxePort.starlingExtensions.flash.movieclipConverter.rectPackerAlgorithms;

import flash.geom.Point;
import flash.geom.Rectangle;

/*
Implements different bin packer algorithms that use the MAXRECTS data structure.
See http://clb.demon.fi/projects/even-more-rectangle-bin-packing

Author: Jukka Jylänki
- Original

Author: Claus Wahlers
- Ported to ActionScript3

Author: Tony DiPerna
- Ported to HaXe, optimized

Author: Shawn Skinner (treefortress)
- Ported back to AS3

*/

class MaxRectPacker extends TexturePacker {

    public function new(maximumW:Float, maximumH:Float):Void {
        super(maximumW, maximumH);
    }

    override function init(width:Float, height:Float):Void {
        super.init(width, height);
    }

    override public inline function packRect(width:Float, height:Float):Rectangle {
        return quickFindPositionForNewNodeBestAreaFit(width, height);
    }

    private inline function quickFindPositionForNewNodeBestAreaFit(width:Float, height:Float):Rectangle {
        width += atlasRegionsGap;
        height += atlasRegionsGap;
        var free:Rectangle;
        var numRectanglesToProcess:Int = freeAreas.length;
        var score:Float = 1000000000;
        var areaFit:Float;

        var bestNode:Rectangle = null;
        var best:Rectangle = new Rectangle(curentMaxW, 0, 0, 0);

// Try to place the rectangle in upright (non-flipped) orientation.
        for (j in 0...numRectanglesToProcess) {
            free = freeAreas[j];

            if (free.width >= width && free.height >= height) {
                areaFit = free.width * free.height - width * height;

                if ((placeInSmallestFreeRect && areaFit < score) ||
                (free.x < best.x || (free.x <= best.x && free.y < best.y))) {
                    best = free;

                    if (bestNode == null) bestNode = new Rectangle();
                    bestNode.x = free.x;
                    bestNode.y = free.y;
                    bestNode.width = width;
                    bestNode.height = height;
                    score = areaFit;
                }
            }
        }
        if (bestNode != null) {
            var i:Int = numRectanglesToProcess;
            while (--i >=0) {
                if (splitFreeNode(freeAreas[i], bestNode)) {
                    freeAreas.splice(i, 1);
                }
            }

// Go through each pair and remove any rectangle that is redundant.
            removeRedundantRectangles();
        }
        return bestNode;
    }

    private inline function removeRedundantRectangles() {
        var i:Int = 0;
        var j:Int = 0;
        var len:Int = freeAreas.length;
        var tmpRect:Rectangle;
        var tmpRect2:Rectangle;
        while (i < len) {
            j = i + 1;
            tmpRect = freeAreas[i];
            while (j < len) {
                tmpRect2 = freeAreas[j];
                if (tmpRect2.containsRect(tmpRect)) {
                    freeAreas.splice(i, 1);
                    --i;
                    --len;
                    break;
                }
                if (tmpRect.containsRect(tmpRect2)) {
                    freeAreas.splice(j, 1);
                    --len;
                    --j;
//                    break;
                }
                j++;
            }
            i++;
        }
    }

    private inline function splitFreeNode(freeNode:Rectangle, node:Rectangle):Bool {
// Test with SAT if the rectangles even intersect.
        if (!node.intersects(freeNode)) return false;

        if (node.containsRect(freeNode)) {
            return true;
        }

        var newNode:Rectangle;

        var nb:Float = node.bottom;
        var nr:Float = node.right;
        var fb:Float = freeNode.bottom;
        var fr:Float = freeNode.right;

        if (node.x < fr && nr > freeNode.x) {
// New node at the top side of the used node.
            if (node.y > freeNode.y && node.y < fb) {
                newNode = freeNode.clone();
                newNode.height = node.y - newNode.y;
                freeAreas.push(newNode);
            }
// New node at the bottom side of the used node.
            if (nb < fb) {
                newNode = freeNode.clone();
                newNode.y = nb;
                newNode.height = fb - nb;
                freeAreas.push(newNode);
            }
        }
        if (node.y < fb && nb > freeNode.y) {
// New node at the left side of the used node.
            if (node.x > freeNode.x && node.x < fr) {
                newNode = freeNode.clone();
                newNode.width = node.x - newNode.x;
                freeAreas.push(newNode);
            }
// New node at the right side of the used node.
            if (nr < fr) {
                newNode = freeNode.clone();
                newNode.x = nr;
                newNode.width = fr - nr;
                freeAreas.push(newNode);
            }
        }
        return true;
    }
}