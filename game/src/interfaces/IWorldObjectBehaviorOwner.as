package interfaces
{
	import flash.geom.Point;

	public interface IWorldObjectBehaviorOwner
	{
//		function get bounds() : Rectangle;
		function get position() : Point;		
		function offset( p : Point ) : void ;				
	}
}