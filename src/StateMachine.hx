class StateMachine
{
	var name : String;
	var alphabet : Array<String>;
	var states : Array<State>;
	var edges : Array<Edge>;

	public function new(name : String, alphabet : Array<String>)
	{
		this.name = name;
		this.alphabet = alphabet;
		states = new Array();
		edges = new Array();
	}

	public function addState(state : State) : State
	{
		states.push(state);
		return state;
	}

	public function getState(name : String) : State
	{
		for(state in states)
			if(state.name == name)
				return state;
		return null;
	}

	public function addEdge(edge : Edge) : Edge
	{
		edge.from.outs.push(edge);
		edge.to.ins.push(edge);
		edges.push(edge);
		return edge;
	}

	public function complete() : StateMachine
	{
		// TODO need deep copy to return a new graph

		var well = new State("W", false, false);
		addState(well);

		for(state in states)
		{
			for(lexem in alphabet)
			{
				var found = false;
				for(outEdge in state.outs)
					if(outEdge.value == lexem)
						found = true;

				if(!found)
					addEdge(new Edge(lexem, state, well));
			}
		}

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

		var m1 = new StateMachine("m1", ["a", "b"]);
		var s0 = m1.addState(new State("0", true, true));
		var s1 = m1.addState(new State("1", false, false));
		var s2 = m1.addState(new State("2", false, false));
		var s3 = m1.addState(new State("3", false, true));
		var s4 = m1.addState(new State("4", false, true));
		var s5 = m1.addState(new State("5", false, false));
		var s6 = m1.addState(new State("6", false, true));
		var s7 = m1.addState(new State("7", false, true));
		m1.addEdge(new Edge("a", s0, s2));
		m1.addEdge(new Edge("b", s0, s1));
		m1.addEdge(new Edge("a", s1, s2));
		m1.addEdge(new Edge("b", s1, s1));
		m1.addEdge(new Edge("a", s2, s3));
		m1.addEdge(new Edge("b", s2, s2));
		m1.addEdge(new Edge("a", s3, s2));
		m1.addEdge(new Edge("b", s3, s6));
		m1.addEdge(new Edge("a", s4, s5));
		m1.addEdge(new Edge("b", s4, s4));
		m1.addEdge(new Edge("a", s5, s6));
		m1.addEdge(new Edge("b", s5, s5));
		m1.addEdge(new Edge("a", s6, s5));
		m1.addEdge(new Edge("b", s6, s7));
		m1.addEdge(new Edge("a", s7, s5));
		m1.addEdge(new Edge("b", s7, s3));
		m1.saveAsPNG();

		var m2 = new StateMachine("m2", ["a", "b"]);
		var s1 = m2.addState(new State("1", true, false));
		var s2 = m2.addState(new State("2", false, true));
		var s3 = m2.addState(new State("3", false, true));
		m2.addEdge(new Edge("a", s1, s2));
		m2.addEdge(new Edge("a", s3, s1));
		m2.addEdge(new Edge("b", s2, s3));
		m2.addEdge(new Edge("b", s3, s2));
		m2.saveAsPNG();
		
		/* 
		Completion test
		
		var m1 = new StateMachine("m1", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m1.addState(new State("0", true, false));
		var s1 = m1.addState(new State("1", false, false));
		var s2 = m1.addState(new State("2", false, false));
		var s3 = m1.addState(new State("3", false, true));
		m1.addEdge(new Edge("a", s0, s1));
		m1.addEdge(new Edge("a", s1, s2));
		m1.addEdge(new Edge("b", s2, s3));
		m1.addEdge(new Edge("b", s3, s0));
		m1.complete();
		m1.saveAsPNG();
		*/

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