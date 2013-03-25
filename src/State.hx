class State
{
	public var name : String;
	public var ins : Array<Edge>;
	public var outs : Array<Edge>;
	public var isInitial : Bool;
	public var isFinal : Bool;

	public function new(name : String, isInitial : Bool, isFinal : Bool)
	{
		this.name = name;
		ins = new Array();
		outs = new Array();
		this.isInitial = isInitial;
		this.isFinal = isFinal;
	}

	public function getEdgesTo(state : State)
	{
		var res = new Array<Edge>();
		for(edge in outs)
			if(edge.to == state)
				res.push(edge);
		return res;
	}

	public function getEdgeTo(state : State, value : String)
	{
		for(edge in outs)
			if(edge.to == state && edge.value == value)
				return edge;
		return null;
	}

	public function getEdgesFrom(state : State)
	{
		var res = new Array<Edge>();
		for(edge in ins)
			if(edge.from == state)
				res.push(edge);
		return res;
	}

	public function getEdgeFrom(state : State, value : String)
	{
		for(edge in ins)
			if(edge.from == state && edge.value == value)
				return edge;
		return null;
	}
}