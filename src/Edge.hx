class Edge 
{
	public var value : String;
	public var from : State;
	public var to : State;

	public function new(value : String, from : State, to : State)
	{
		this.value = value;
		this.from = from;
		this.to = to;
	}
}