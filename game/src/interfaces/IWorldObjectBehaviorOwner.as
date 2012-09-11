package interfaces
{
	import flash.geom.Point;

	// the following interface is passed into behavior's exec function (instead of passing down the entire WorldObjectSim shabango
	public interface IWorldObjectBehaviorOwner
	{
		function get position() : Point;		
		function offset( p : Point ) : void ;				
	}
}