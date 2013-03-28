/**
	Instances of this class represent a directed edge in a state machine
**/

class Edge
{
	public var value : String; 	// The value of the edge, must be one of the alphabet's symbol of the state machine it belongs to
	public var from : State;	// The state which the edge come from
	public var to : State;		// The state which the edge goes to

	/**
		Create a new edge
	**/
	public function new(value : String, from : State, to : State)
	{
		this.value = value;
		this.from = from;
		this.to = to;
	}
}