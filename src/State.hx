/**
	Instance of this class represent a state in a state machine
**/
class State
{
	public var name : String;		// The name of the state
	public var ins : Array<Edge>;	// The array containing the edges entering this state
	public var outs : Array<Edge>;	// The array containing the edges leaving this state
	public var isInitial : Bool;	// Whether the state is initial
	public var isFinal : Bool;		// Whether the state if final

	/**
		Create a new State
	**/
	public function new(name : String, isInitial : Bool, isFinal : Bool)
	{
		this.name = name;
		ins = new Array();
		outs = new Array();
		this.isInitial = isInitial;
		this.isFinal = isFinal;
	}

	/**
		Return an array of edges going to another state
	**/
	public function getEdgesTo(state : State) : Array<Edge>
	{
		var res = new Array<Edge>();
		for(edge in outs)
			if(edge.to == state)
				res.push(edge);
		return res;
	}

	/**
		Return an edge going to another state labelled as value
	**/
	public function getEdgeTo(state : State, value : String) : Edge
	{
		for(edge in outs)
			if(edge.to == state && edge.value == value)
				return edge;
		return null;
	}

	/**
		Return an array of edges coming from another state
	**/
	public function getEdgesFrom(state : State) : Array<Edge>
	{
		var res = new Array<Edge>();
		for(edge in ins)
			if(edge.from == state)
				res.push(edge);
		return res;
	}

	/**
		Return an edge coming from another state labelled as value
	**/
	public function getEdgeFrom(state : State, value : String) : Edge
	{
		for(edge in ins)
			if(edge.from == state && edge.value == value)
				return edge;
		return null;
	}
}