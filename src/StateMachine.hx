class StateMachine
{
	var states : Array<State>;
	var edges : Array<Edge>;
	var name : String;

	public function new(name : String)
	{
		states = new Array();
		edges = new Array();
		this.name = name;
	}

	public function addState(state : State)
	{
		states.push(state);
	}

	public function getState(name : String)
	{
		for(state in states)
			if(state.name == name)
				return state;
		return null;
	}

	public function addEdge(edge : Edge)
	{
		edge.from.outs.push(edge);
		edge.to.ins.push(edge);
		edges.push(edge);
	}

	public function complete() : StateMachine
	{
		//TODO
		return null;
	}
	public function union(sm : StateMachine) : StateMachine
	{
		//TODO
		return null;
	}
	public function intersect(sm : StateMachine) : StateMachine
	{
		//TODO
		return null;
	}
	public function mirror() : StateMachine
	{
		/*TODO

		var res = new StateMachine();

		for(state in states)
		{
			var tmp1 = state.ins;
			state.ins = state.outs;
			state.outs = tmp1;
			var tmp2 = state.isFinal;
			state.isFinal = state.isInitial;
			state.isInitial = tmp2;
		}
		for(edge in edges)
		{
			var tmp = edge.to;
			edge.to = edge.from;
			edge.from = tmp;
		}

		return res;
		*/
		return null;
	}
	public function determine() : StateMachine
	{
		//TODO
		return null;
	}
	public function complement() : StateMachine
	{
		//TODO
		return null;
	}
	public function minimize() : StateMachine 
	{
		//TODO
		return null;
	}
	public static function fromExpression(expression : String) : StateMachine
	{
		//TODO
		return null;
	}

	public function toDOT() : String
	{
		var res = "";
		res += "digraph "+name+"\n{\n";
		for(state in states)
		{
			if(state.isInitial && state.isFinal)
				res += state.name+" [shape=doubleoctagon];";
			else if(state.isFinal)
				res += state.name+" [shape=doublecircle];";
			else if(state.isInitial)
				res += state.name+" [shape=octagon];";
			else
				res += state.name+" [shape=circle];";

			for(edge in state.outs)
				res += edge.from.name + " -> " + edge.to.name + " [label=\"" + edge.value + "\"];\n";
		}
		res += "}";
		return res;
	}

	public function saveAsPNG() : Void
	{
		sys.io.File.saveContent(name+".gv", toDOT());
		Sys.command("neato -Tpng -o"+name+".png "+name+".gv");
	}

	public static function main() : Int
	{
		var m1 = new StateMachine("m1");
		m1.addState(new State("0", true, true));
		m1.addState(new State("1", false, false));
		m1.addState(new State("2", false, false));
		m1.addState(new State("3", false, true));
		m1.addState(new State("4", false, true));
		m1.addState(new State("5", false, false));
		m1.addState(new State("6", false, true));
		m1.addState(new State("7", false, true));
		m1.addEdge(new Edge("a", m1.getState("0"), m1.getState("2")));
		m1.addEdge(new Edge("b", m1.getState("0"), m1.getState("1")));
		m1.addEdge(new Edge("a", m1.getState("1"), m1.getState("2")));
		m1.addEdge(new Edge("b", m1.getState("1"), m1.getState("1")));
		m1.addEdge(new Edge("a", m1.getState("2"), m1.getState("3")));
		m1.addEdge(new Edge("b", m1.getState("2"), m1.getState("2")));
		m1.addEdge(new Edge("a", m1.getState("3"), m1.getState("2")));
		m1.addEdge(new Edge("b", m1.getState("3"), m1.getState("6")));
		m1.addEdge(new Edge("a", m1.getState("4"), m1.getState("5")));
		m1.addEdge(new Edge("b", m1.getState("4"), m1.getState("4")));
		m1.addEdge(new Edge("a", m1.getState("5"), m1.getState("6")));
		m1.addEdge(new Edge("b", m1.getState("5"), m1.getState("5")));
		m1.addEdge(new Edge("a", m1.getState("6"), m1.getState("5")));
		m1.addEdge(new Edge("b", m1.getState("6"), m1.getState("7")));
		m1.addEdge(new Edge("a", m1.getState("7"), m1.getState("5")));
		m1.addEdge(new Edge("b", m1.getState("7"), m1.getState("3")));
		m1.saveAsPNG();

		var m2 = new StateMachine("m2");
		m2.addState(new State("1", true, false));
		m2.addState(new State("2", false, true));
		m2.addState(new State("3", false, true));
		m2.addEdge(new Edge("a", m2.getState("1"), m2.getState("2")));
		m2.addEdge(new Edge("a", m2.getState("3"), m2.getState("1")));
		m2.addEdge(new Edge("b", m2.getState("2"), m2.getState("3")));
		m2.addEdge(new Edge("b", m2.getState("3"), m2.getState("2")));
		m2.saveAsPNG();

		return 0;
	}

	/*
	Choisissez au moins une de ces questions pour terminer :
	a) Montrer l’algorithme du double renversement, comme proposé dans la feuille de TD no 3.
	b) Écrire un analyseur d’expressions rationnelles, qui convertit les expressions rationnelles, données
	comme chaînes de caractères de la forme (a + b * a)*, en listes Python, de la forme ["*",
	["+", ["a", [".", ["*","b"], ["a"]]]]].

	*/
}