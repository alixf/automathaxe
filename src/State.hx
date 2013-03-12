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
}