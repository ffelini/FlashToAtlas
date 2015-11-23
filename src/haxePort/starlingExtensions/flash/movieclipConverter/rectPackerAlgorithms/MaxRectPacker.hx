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
    private var freeRectangles:Array<Rectangle> = [];

    public function new(maximumW:Float, maximumH:Float):Void {
        super(maximumW, maximumH);
    }

    override function init(width:Float, height:Float):Void {
        super.init(width, height);

        freeRectangles.splice(0, freeRectangles.length);
        freeRectangles.push(new Rectangle(0, 0, curentMaxW, curentMaxH));
    }

    override public function freeRectangle(r:Rectangle):Void {
        freeRectangles.unshift(r);
    }

    override public inline function packRect(width:Float, height:Float):Rectangle
    {
        return quickFindPositionForNewNodeBestAreaFit(width, height);
    }
    override function increaseCurentMaxRect() {
        var lastCurentMaxW:Float = curentMaxW;
        var lastCurentMaxH:Float = curentMaxH;

        super.increaseCurentMaxRect();

        var newFreeRect:Rectangle;

        // expanding free rectangles for Main curent maximum size
        var numRectanglesToProcess:Int = freeRectangles.length;
        var i:Int = 0;

        while (i < numRectanglesToProcess) {
            newFreeRect = freeRectangles[i];
            if (curentMaxW > lastCurentMaxW) {
                if (newFreeRect.x + newFreeRect.width == lastCurentMaxW) newFreeRect.width = curentMaxW - newFreeRect.x;
            }
            else if (curentMaxH > lastCurentMaxH) {
                if (newFreeRect.y + newFreeRect.height == lastCurentMaxH) newFreeRect.height = curentMaxH - newFreeRect.y;
            }

            i++;
        }
        removeRedundantRectangles();

        // adding new free recatangles if curent max size was increased
        //				if(curentMaxW>lastCurentMaxW) {
        //					freeRectangles.push(new Rectangle(curentMaxW - lastCurentMaxW + atlasRegionsGap, 0, curentMaxW - lastCurentMaxW, lastCurentMaxH));
        //				} else  if(curentMaxH>lastCurentMaxH) {
        //					freeRectangles.push(new Rectangle(0, curentMaxH - lastCurentMaxH + atlasRegionsGap, lastCurentMaxW, curentMaxH - lastCurentMaxH));
        //				}height);
    }

    private inline function quickFindPositionForNewNodeBestAreaFit(width:Float, height:Float):Rectangle {
        var r:Rectangle;
        var numRectanglesToProcess:Int = freeRectangles.length;
        var score:Float = 1000000000;
        var areaFit:Float;

        var bestNode:Rectangle = null;

// Try to place the rectangle in upright (non-flipped) orientation.
        for (j in 0...numRectanglesToProcess) {
            r = freeRectangles[j];
            if (r.width >= width && r.height >= height) {
                areaFit = r.width * r.height - width * height;
                if (areaFit < score) {
                    if (bestNode == null) bestNode = new Rectangle();

                    bestNode.x = r.x;
                    bestNode.y = r.y;
                    bestNode.width = width + atlasRegionsGap;
                    bestNode.height = height + atlasRegionsGap;
                    score = areaFit;

                    if (!placeInSmallestFreeRect) break;
                }
            }
        }
        if (bestNode != null) {
            var i:Int = 0;
            while (i < numRectanglesToProcess) {
                if (splitFreeNode(freeRectangles[i], bestNode)) {
                    freeRectangles.splice(i, 1);
                    --numRectanglesToProcess;
                    --i;
                }
                else {

                }
                i++;
            }

// Go through each pair and remove any rectangle that is redundant.
            removeRedundantRectangles();
        }
        return bestNode;
    }

    private inline function removeRedundantRectangles() {
        var i:Int = 0;
        var j:Int = 0;
        var len:Int = freeRectangles.length;
        var tmpRect:Rectangle;
        var tmpRect2:Rectangle;
        while (i < len) {
            j = i + 1;
            tmpRect = freeRectangles[i];
            while (j < len) {
                tmpRect2 = freeRectangles[j];
                if (tmpRect2.containsRect(tmpRect)) {
                    freeRectangles.splice(i, 1);
                    --i;
                    --len;
                    break;
                }
                if (tmpRect.containsRect(tmpRect2)) {
                    freeRectangles.splice(j, 1);
                    --len;
                    --j;
                    break;
                }
                j++;
            }
            i++;
        }
    }

    private inline function splitFreeNode(freeNode:Rectangle, node:Rectangle):Bool {
// Test with SAT if the rectangles even intersect.
        if (!node.intersects(freeNode)) return false;

        if (node.containsRect(freeNode)) return true;

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
                freeRectangles.push(newNode);
            }
// New node at the bottom side of the used node.
            if (nb < fb) {
                newNode = freeNode.clone();
                newNode.y = nb;
                newNode.height = fb - nb;
                freeRectangles.push(newNode);
            }
        }
        if (node.y < fb && nb > freeNode.y) {
// New node at the left side of the used node.
            if (node.x > freeNode.x && node.x < fr) {
                newNode = freeNode.clone();
                newNode.width = node.x - newNode.x;
                freeRectangles.push(newNode);
            }
// New node at the right side of the used node.
            if (nr < fr) {
                newNode = freeNode.clone();
                newNode.x = nr;
                newNode.width = fr - nr;
                freeRectangles.push(newNode);
            }
        }
        return true;
    }
}