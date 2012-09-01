package interfaces
{
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	import util.Vector2;

	public interface ICollider
	{
		function get bounds() : Rectangle;
		function get velocity()  : Vector2;
		function get collisionTestPoints() : Vector.<Point>;	
	}
}