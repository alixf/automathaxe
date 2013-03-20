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

	public function copy() : StateMachine
	{
		var res = new StateMachine(new String(name), alphabet.copy());
		for(state in states)
			res.addState(new State(new String(state.name), state.isInitial, state.isFinal));
		for(edge in edges)
			res.addEdge(new Edge(new String(edge.value), res.getState(edge.from.name), res.getState(edge.to.name)));
		return res;
	}

	public function complete() : StateMachine
	{
		var res = copy();

		var well = new State("W", false, false);
		res.addState(well);

		for(state in res.states)
		{
			for(lexem in res.alphabet)
			{
				var found = false;
				for(outEdge in state.outs)
				{
					if(outEdge.value == lexem)
						found = true;
				}

				if(!found)
					res.addEdge(new Edge(lexem, state, well));
			}
		}
		return res;
	}

	public function union(sm : StateMachine) : StateMachine
	{
		// Make local copies to work on
		var sm1 = this.copy();
		var sm2 = sm.copy();
		var res = new StateMachine(new String(name), alphabet.copy());

		// Rename the states to prevent collision
		var i = 0;
		for(state in sm1.states)
			state.name = Std.string(++i);
		for(state in sm2.states)
			state.name = Std.string(++i);

		// Merge the copies
		for(state in sm1.states)
			res.addState(new State(new String(state.name), state.isInitial, state.isFinal));
		for(edge in sm1.edges)
			res.addEdge(new Edge(new String(edge.value), res.getState(edge.from.name), res.getState(edge.to.name)));
		for(state in sm2.states)
			res.addState(new State(new String(state.name), state.isInitial, state.isFinal));
		for(edge in sm2.edges)
			res.addEdge(new Edge(new String(edge.value), res.getState(edge.from.name), res.getState(edge.to.name)));

		// Create the bounding states
		var start = res.addState(new State("S", false, false));
		var end = res.addState(new State("E", false, false));

		// Bound states to bounding states and remove their attributes
		for(state in res.states)
		{
			if(state.isInitial)
			{
				res.addEdge(new Edge("", start, state));
				state.isInitial = false;
			}
			if(state.isFinal)
			{
				res.addEdge(new Edge("", state, end));
				state.isFinal = false;
			}
		}

		// Set correct attributes to bounding states
		start.isInitial = true;
		end.isFinal = true;

		// Return the result
		return res;
	}

	public function intersect(sm : StateMachine) : StateMachine
	{
		//TODO
		return null;
	}

	public function mirror() : StateMachine
	{
		var res = copy();

		for(state in res.states)
		{
			var tmp1 = state.ins;
			state.ins = state.outs;
			state.outs = tmp1;
			var tmp2 = state.isFinal;
			state.isFinal = state.isInitial;
			state.isInitial = tmp2;
		}
		for(edge in res.edges)
		{
			var tmp = edge.to;
			edge.to = edge.from;
			edge.from = tmp;
		}

		return res;
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
				res += "\t"+state.name+" [shape=doubleoctagon];\n";
			else if(state.isFinal)
				res += "\t"+state.name+" [shape=doublecircle];\n";
			else if(state.isInitial)
				res += "\t"+state.name+" [shape=octagon];\n";
			else
				res += "\t"+state.name+" [shape=circle];\n";
		}
		for(state in states)
		{
			for(edge in state.outs)
				res += "\t"+edge.from.name + " -> " + edge.to.name + " [label=\"" + edge.value + "\"];\n";
		}
		res += "}";
		return res;
	}

	public function saveAsPNG() : Void
	{
		sys.io.File.saveContent(name+".gv", toDOT());
		Sys.command("dot -Tpng -o"+name+".png "+name+".gv");
	}

	public static function main() : Int
	{
		/*
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
		m12.saveAsPNG();

		var m2 = new StateMachine("m2", ["a", "b"]);
		var s1 = m2.addState(new State("1", true, false));
		var s2 = m2.addState(new State("2", false, true));
		var s3 = m2.addState(new State("3", false, true));
		m2.addEdge(new Edge("a", s1, s2));
		m2.addEdge(new Edge("a", s3, s1));
		m2.addEdge(new Edge("b", s2, s3));
		m2.addEdge(new Edge("b", s3, s2));
		m2.saveAsPNG();
		*/
		
		/*//
		// Completion test
		var m1 = new StateMachine("m1", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m1.addState(new State("0", true, false));
		var s1 = m1.addState(new State("1", false, false));
		var s2 = m1.addState(new State("2", false, false));
		var s3 = m1.addState(new State("3", false, true));
		m1.addEdge(new Edge("a", s0, s1));
		m1.addEdge(new Edge("a", s1, s2));
		m1.addEdge(new Edge("b", s2, s3));
		m1.addEdge(new Edge("b", s3, s0));
		m1.complete().saveAsPNG();
		//*/

		/*//
		// Mirror test
		var m1 = new StateMachine("m1", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m1.addState(new State("0", true, false));
		var s1 = m1.addState(new State("1", false, false));
		var s2 = m1.addState(new State("2", false, false));
		var s3 = m1.addState(new State("3", false, true));
		m1.addEdge(new Edge("a", s0, s1));
		m1.addEdge(new Edge("a", s1, s2));
		m1.addEdge(new Edge("b", s2, s3));
		m1.addEdge(new Edge("b", s3, s0));
		m1.mirror().saveAsPNG();
		//*/

		///
		// Union test
		var m1 = new StateMachine("m1", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m1.addState(new State("0", true, false));
		var s1 = m1.addState(new State("1", false, false));
		var s2 = m1.addState(new State("2", false, false));
		var s3 = m1.addState(new State("3", false, true));
		m1.addEdge(new Edge("a", s0, s1));
		m1.addEdge(new Edge("a", s1, s2));
		m1.addEdge(new Edge("b", s2, s3));
		m1.addEdge(new Edge("b", s3, s0));
		m1.union(m1).saveAsPNG();
		//*/

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