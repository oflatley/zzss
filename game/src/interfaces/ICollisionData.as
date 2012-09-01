package interfaces
{
	import flash.geom.Point;
	
	import util.Vector2;

	public interface ICollisionData
	{
		function testPoint( p : Point ) : Vector2 ;
		function testxy( x : Number, y : Number ) : Vector2;
	}
}