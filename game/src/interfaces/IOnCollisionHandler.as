package interfaces {
	import sim.PlayerSim;

	public interface IOnCollisionHandler {
		function exec( p : PlayerSim ) : void ;
	}
}