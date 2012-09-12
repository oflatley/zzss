package interfaces
{
	public interface IFiniteState
	{
		function enter() : void;
		function update( delta_ms : Number ) : String;
		function exit() : void
	}
}