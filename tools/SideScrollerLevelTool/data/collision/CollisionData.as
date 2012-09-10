§package collision
{
	import interfaces.ICollisionData;

	public class CollisionDataProxy { 
		private var map:Array = new Array();
		public function getCollisionData( s : String ) : ICollisionData { return map[s]; }

		public function CollisionDataProxy() {
		}
	}
}

import flash.geom.Point;
import interfaces.ICollisionData;

class CollisionDataBase implements ICollisionData {
	protected var _data:Array;
	protected var _width:int;
	protectedÂ var _height:int;
	public function get data() : Array { return _data; }
	public function testPoint(p:Point) : Boolean { return testxy( p.x, p.y ); }
	public function testxy( x : int, y:int ) : Boolean { return _data[y*_width + x];}
}