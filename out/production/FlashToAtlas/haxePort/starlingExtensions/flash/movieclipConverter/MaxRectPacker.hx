package haxePort.starlingExtensions.flash.movieclipConverter;

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

class MaxRectPacker
{
	public var freeRectangles:Array<Rectangle>;
	
	public var curentMaxW:Float;
	public var curentMaxH:Float;
	
	private var textureAtlasRect:Rectangle = new Rectangle();
	public var regionPoint:Point = new Point();
	
	public var atlasRegionsGap:Float = 2;

	@:isVar public var xOffset(get, set):Float;

	function set_xOffset(value:Float) {
		return this.xOffset = value;
	}

	function get_xOffset():Float {
		return xOffset;
	}

	function set_yOffset(value:Float) {
		return this.yOffset = value;
	}

	function get_yOffset():Float {
		return yOffset;
	}
	@:isVar public var yOffset(get, set):Float;

	public var textureAtlasToBeDrawn(get, null):Rectangle;
	private var _textureAtlasToBeDrawn:Rectangle;
	public inline function get_textureAtlasToBeDrawn():Rectangle {
		if(_textureAtlasToBeDrawn==null) {
			_textureAtlasToBeDrawn = textureAtlasRect.clone();
		}
		_textureAtlasToBeDrawn.width = textureAtlasRect.width;
		_textureAtlasToBeDrawn.height = textureAtlasRect.height;
		_textureAtlasToBeDrawn.x = xOffset;
		_textureAtlasToBeDrawn.y = yOffset;
		return _textureAtlasToBeDrawn;
	}

/**
	 * if true - this flag will control the max. rectangle zie. It will start from the smallest possible and will increase each size twice till the maximum. This is useful because the content may be packed using the smalles possible size
	 * if false - the max size will be fixed and algorithm will pack all regions in that size.
	 */		
	public var smartSizeIncrease:Bool = true;
	/**
	 * by this value the size of the rect will be increased 
	 */		
	public var smartSizeIncreaseFactor:Float = 1.25;
	/**
	 * if true - algorithm will place the rect in the smallest free rectangle
	 * if flase - algorithm will place the rect in the first found proper rectangle (a bit faster because will not go through all free rectangles) 
	 */		
	public var placeInSmallestFreeRect:Bool = true;
		
	public function new(maximumW:Float, maximumH:Float):Void
	{
		freeRectangles = [];
		xOffset = yOffset = 0;
		init(maximumW, maximumH);
	}
	public var maximumWidth:Float;
	public var maximumHeight:Float;
	function init(width:Float, height:Float):Void
	{
		_isFull = false;
		maximumWidth = width;
		maximumHeight = height;
		
		if(smartSizeIncrease)
		{
			width = width/8;
			height = height/8;
		}

		regionPoint.x = regionPoint.y = 0;
		textureAtlasRect.x = 0;
		textureAtlasRect.y = 0;
		textureAtlasRect.width = textureAtlasRect.height = 0;
		curentMaxW = width;
		curentMaxH = height;
		
		freeRectangles.splice(0,freeRectangles.length);
		freeRectangles.push(new Rectangle(0, 0, width, height));
	}

	private var _isFull:Bool = false;
	public var isFull(get,null):Bool = false;
	public function get_isFull():Bool
	{
		return _isFull;
	}
	public function freeRectangle(r:Rectangle):Void
	{
		freeRectangles.unshift(r);
	}
	public inline function quickInsert(width:Float, height:Float):Rectangle
	{
		var newNode:Rectangle = quickFindPositionForNewNodeBestAreaFit(width, height);
		
		if (newNode!=null) 
		{
			textureAtlasRect.width = newNode.x + width>textureAtlasRect.width ? newNode.x + width : textureAtlasRect.width;
			textureAtlasRect.height = newNode.y + height>textureAtlasRect.height ? newNode.y + height : textureAtlasRect.height;
			regionPoint.x = newNode.x + xOffset;
			regionPoint.y = newNode.y + yOffset;
		}
		else
		{
			if(curentMaxW<maximumWidth || curentMaxH<maximumHeight)
			{
				var newFreeRect:Rectangle = new Rectangle();
				var lastCurentMaxW:Float = curentMaxW;
				var lastCurentMaxH:Float = curentMaxH;
				
				if(curentMaxW==curentMaxH) curentMaxW = curentMaxW*smartSizeIncreaseFactor<maximumWidth ? curentMaxW*smartSizeIncreaseFactor : maximumWidth;
				else 
				{
					if(curentMaxW>curentMaxH) curentMaxH = curentMaxH*smartSizeIncreaseFactor<maximumHeight ? curentMaxH*smartSizeIncreaseFactor : maximumHeight;
					else curentMaxW = curentMaxW*smartSizeIncreaseFactor<maximumWidth ? curentMaxW*smartSizeIncreaseFactor : maximumWidth;
				}
				
				// expanding free rectangles for Main curent maximum size
				var numRectanglesToProcess:Int = freeRectangles.length;
				var i:Int = 0;
				
				while (i < numRectanglesToProcess) 
				{
					newFreeRect = freeRectangles[i];
					if(curentMaxW>lastCurentMaxW)
					{
						if(newFreeRect.x+newFreeRect.width==lastCurentMaxW) newFreeRect.width = curentMaxW - newFreeRect.x;
					}
					else if(curentMaxH>lastCurentMaxH)
					{
						if(newFreeRect.y+newFreeRect.height==lastCurentMaxH) newFreeRect.height = curentMaxH - newFreeRect.y;
					}
					
					i++;
				}
				
				// trying to add the rect using Main size
				newNode = quickInsert(width,height); 
			}
		}
		
		_isFull = newNode==null;
		
		return newNode;
	}
	private inline function quickFindPositionForNewNodeBestAreaFit(width:Float, height:Float):Rectangle 
	{
		var r:Rectangle;			
		var numRectanglesToProcess:Int = freeRectangles.length;
		var score:Float = 1000000000;
		var areaFit:Float;
		
		var bestNode:Rectangle = null;
		
		// Try to place the rectangle in upright (non-flipped) orientation.
		for (j in 0...numRectanglesToProcess) 
		{
			r = freeRectangles[j];
			if (r.width >= width && r.height >= height) 
			{
				areaFit = r.width * r.height - width * height;
				if (areaFit < score) 
				{
					if(bestNode==null) bestNode = new Rectangle();
					
					bestNode.x = r.x;
					bestNode.y = r.y;
					bestNode.width = width+atlasRegionsGap;
					bestNode.height = height+atlasRegionsGap;
					score = areaFit;

					if(!placeInSmallestFreeRect) break;
				}
			}
		}
		if(bestNode!=null)
		{
			var i:Int = 0;
			while (i < numRectanglesToProcess) 
			{
				if (splitFreeNode(freeRectangles[i], bestNode)) 
				{
					freeRectangles.splice(i, 1);
					--numRectanglesToProcess;
					--i;
				}
				else
				{
					
				}
				i++;
			}
			
			// Go through each pair and remove any rectangle that is redundant.
			var k:Int = 0;
			var m:Int = 0;
			var len:Int = freeRectangles.length;
			var tmpRect:Rectangle;
			var tmpRect2:Rectangle;
			while (k < len) {
				m = k + 1;
				tmpRect = freeRectangles[k];
				while (m < len)
				{
					tmpRect2 = freeRectangles[m];
					if (tmpRect2.containsRect(tmpRect)) 
					{
						freeRectangles.splice(k, 1);
						--k;
						--len;
						break;
					}
					if (tmpRect.containsRect(tmpRect2))
					{
						freeRectangles.splice(m, 1);
						--len;
						--m;
						break;
					}
					m++;
				}
				k++;
			}
		}
		return bestNode;
	}
	private inline function splitFreeNode(freeNode:Rectangle, node:Rectangle):Bool 
	{
		// Test with SAT if the rectangles even intersect.
		if (!node.intersects(freeNode)) return false;
		
		if(node.containsRect(freeNode)) return true;
		
		var newNode:Rectangle;
		
		var nb:Float = node.bottom;
		var nr:Float = node.right;
		var fb:Float = freeNode.bottom;
		var fr:Float = freeNode.right;
		
		if (node.x < fr && nr > freeNode.x) 
		{
			// New node at the top side of the used node.
			if (node.y > freeNode.y && node.y < fb) 
			{
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
		if (node.y < fb && nb > freeNode.y) 
		{
			// New node at the left side of the used node.
			if (node.x > freeNode.x && node.x < fr) 
			{
				newNode = freeNode.clone();
				newNode.width = node.x - newNode.x;
				freeRectangles.push(newNode);
			}
			// New node at the right side of the used node.
			if (nr < fr) 
			{
				newNode = freeNode.clone();
				newNode.x = nr;
				newNode.width = fr - nr;
				freeRectangles.push(newNode);
			}
		}
		return true;
	}
}