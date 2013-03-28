/**
	Instance of this class represent a state machine
**/
class StateMachine
{
	var name : String;				// The name of the machine
	var alphabet : Array<String>;	// The alphabet of the machine, as an array of symbols
	var states : Array<State>;		// The states of the machine, as an array of State
	var edges : Array<Edge>;		// The edges of the machine, as an array of Edge

	/**
		Create a new state machine
	**/
	public function new(name : String, alphabet : Array<String>)
	{
		this.name = name;
		this.alphabet = alphabet;
		states = new Array();
		edges = new Array();
	}

	/**
		Add a state to the machine
	**/
	public function addState(state : State) : State
	{
		states.push(state);
		return state;
	}

	/**
		Remove a state from the machine
	**/
	public function removeState(state : State) : State
	{
		var it = state.ins.iterator();
		for(edge in state.ins.copy())
			removeEdge(edge);
		for(edge in state.outs.copy())
			removeEdge(edge);
		return states.remove(state) ? state : null;
	}

	/**
		Get a state of the machine from its name
	**/
	public function getState(name : String) : State
	{
		for(state in states)
			if(state.name == name)
				return state;
		return null;
	}

	/**
		Add an edge to the machine
	**/
	public function addEdge(edge : Edge) : Edge
	{
		edge.from.outs.push(edge);
		edge.to.ins.push(edge);
		edges.push(edge);
		return edge;
	}

	/**
		Remove an edge from the machine
	**/
	public function removeEdge(edge : Edge) : Edge
	{
		edge.from.outs.remove(edge);
		edge.to.ins.remove(edge);
		return edges.remove(edge) ? edge : null;
	}

	/**
		Perform a deep copy of the machine, returning the copy
		All states and edges are copied
	**/
	public function copy() : StateMachine
	{
		var res = new StateMachine(new String(name), alphabet.copy());

		// Copy states
		for(state in states)
			res.addState(new State(new String(state.name), state.isInitial, state.isFinal));

		// Copy edges
		for(edge in edges)
			res.addEdge(new Edge(new String(edge.value), res.getState(edge.from.name), res.getState(edge.to.name)));
		return res;
	}

	/**
		Return a new machine, which is equal to the object but complete
	**/
	public function complete() : StateMachine
	{
		// Create a copy with a well
		var res = copy();
		var well = res.addState(new State("W", false, false));

		for(state in res.states)
		{
			for(symbol in res.alphabet)
			{
				var found = false;
				for(outEdge in state.outs)
					found = found || (outEdge.value == symbol);

				if(!found)
					res.addEdge(new Edge(symbol, state, well));
			}
		}

		//
		// Try to remove well if it is unnecessary
		//
		var wellIsNecessary = false;
		for(edge in well.ins)
			wellIsNecessary = wellIsNecessary || (edge.from != well);
		for(edge in well.outs)
			wellIsNecessary = wellIsNecessary || (edge.to != well);
		if(!wellIsNecessary)
			res.removeState(well) == null;

		return res;
	}

	/**
		Return a new machine, which is the union between this machine and sm
	**/
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

	/**
		Return a new machine, which is the intersection between this machine an sm
	**/
	public function intersect(sm : StateMachine) : StateMachine
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

		// Consider every couple of state from the two machines as a state in the result
		for(state1 in sm1.states)
			for(state2 in sm2.states)
				res.addState(new State("a"+state1.name+"b"+state2.name, state1.isInitial && state2.isInitial, state1.isFinal && state2.isFinal));

		// Consider two couples of states (s1,s2) and (s3,s4) as created before
		// Create an edge labelled as 'a' only if there is :
		// an edge with the label 'a' from s1 to s3 and an edge with the label 'a' from s2 to s4
		for(s1 in sm1.states)
			for(s2 in sm2.states)
				for(s3 in sm1.states)
					for(s4 in sm2.states)
						for(symbol in res.alphabet)
							if(s1.getEdgeTo(s3, symbol) != null && s2.getEdgeTo(s4, symbol) != null)
								res.addEdge(new Edge(symbol, res.getState("a"+s1.name+"b"+s2.name), res.getState("a"+s3.name+"b"+s4.name)));

		// Remove uneeded states
		for(state in res.states)
			if(state.ins.length == 0 && state.outs.length == 0)
				res.removeState(state);

		// Rename the states
		var i = 0;
		for(state in res.states)
			state.name = Std.string(++i);

		return res;
	}

	/**
		Return a new machine, which is a copy of this machine
	**/
	public function mirror() : StateMachine
	{
		var res = copy();

		for(state in res.states)
		{
			// Swap "in" edge and "out" edges
			var tmp1 = state.ins;
			state.ins = state.outs;
			state.outs = tmp1;

			// Swap final and initial
			var tmp2 = state.isFinal;
			state.isFinal = state.isInitial;
			state.isInitial = tmp2;
		}

		// Mirror edges
		for(edge in res.edges)
		{
			var tmp = edge.to;
			edge.to = edge.from;
			edge.from = tmp;
		}

		return res;
	}


	/**
		Return a new state machine, which is equal to the object but determinist
	**/
	public function determinize() : StateMachine
	{
		/**
			Create a line in the determinization table
		**/
		function createLine(map : Map<String, Map<String, Array<State>>>, queue : Array<String>, key : String)
		{
			map.set(key, new Map<String, Array<State>>());
			for(symbol in alphabet)
				map.get(key).set(symbol, new Array<State>());
			queue.push(key);
		}
		/**
			Check if an array contains a value
		**/
		function arrayContains(array : Array<State>, value : State)
		{
			var res = false;
			for(i in array)
				res = res || (i == value);
			return res;
		}
		/**
			Convert an array of string to a key
		**/
		function stateNameArrayToKey(array : Array<String>) : String
		{
			array.sort(function(a,b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
			if(array.length <= 0)
				return "";
			return "s"+array.join("s");
		}
		/**
			Convert an key to an array of string
		**/
		function keyToStateNameArray(key : String) : Array<String>
		{
			if(key.length <= 0)
				return new Array();
			return key.split("s").slice(1);
		}

		// Create the determinization table and the new states queue
		var map = new Map<String, Map<String, Array<State>>>();
		var queue = new Array<String>();

		//
		// Initialize map with current states
		//
		// Retrieve initial states' names
		var initialStates = new Array();
		for(state in states)
			if(state.isInitial)
				initialStates.push(state.name);

		// Create empty line in the table
		createLine(map, queue, stateNameArrayToKey(initialStates));

		//
		// Fill the determinization table
		//
		while(queue.length > 0)
		{
			var key = queue.shift();
			var stateNames = keyToStateNameArray(key);
			for(stateName in stateNames)
			{
				var state = getState(stateName);
				for(edge in state.outs)
					if(!arrayContains(map.get(key).get(edge.value), edge.to))
						map.get(key).get(edge.value).push(edge.to);
			}

			for(symbol in alphabet)
			{
				var newStates = map.get(key).get(symbol);
				var keysArray = [];
				for(newState in newStates)
					keysArray.push(newState.name);

				var newKey = stateNameArrayToKey(keysArray);
				if(newStates.length > 0 && !map.exists(newKey))
					createLine(map, queue, newKey);
			}
		}

		//
		// Create states
		//
		var res = new StateMachine(new String(name), alphabet.copy());
		for(key in map.keys())
		{
			var isFinal = false;
			for(stateName in keyToStateNameArray(key))
				isFinal = isFinal || getState(stateName).isFinal;
			res.addState(new State(new String(key), false, isFinal));
		}
		res.getState(stateNameArrayToKey(initialStates)).isInitial = true;

		//
		// Create edges
		//
		for(key in map.keys())
		{
			var state1 = res.getState(key);
			for(symbol in res.alphabet)
			{
				var statesNames = [];
				for(state in map.get(key).get(symbol))
					statesNames.push(state.name);
				var stateName = stateNameArrayToKey(statesNames);
				if(stateName.length > 0)
				{
					var state2 = res.getState(stateName);
					res.addEdge(new Edge(symbol, state1, state2));
				}
			}
		}

		//
		// Rename states
		//
		var i = 0;
		for(state in res.states)
			state.name = Std.string(++i);

		return res;
	}

	/**
		Return a new state machine, reconizing the complement of the set of expressions recognized by the object
	**/
	public function complement() : StateMachine
	{
		var res = determinize();
		res = res.complete();

		// The final states become non-final and the non-final states become final
		for(state in res.states)
			state.isFinal = !state.isFinal;

		return res;
	}

	/**
		Return a new state machine, equal to the object but with the minimum state count possible
	**/
	public function minimize() : StateMachine 
	{
		return determinize().mirror().determinize().mirror();
	}

	/**
		Return a string containing the description of the state machine in DOT Format
		The DOT Format is used for visualization by GraphViz
	**/
	public function toDOT() : String
	{
		var res = "";
		res += "digraph "+name+"\n{\n";
		for(state in states)
		{
			if(state.isInitial && state.isFinal)
				res += "\t"+state.name+" [shape=diamond,peripheries=2];\n";
			else if(state.isFinal)
				res += "\t"+state.name+" [shape=ellipse,peripheries=2];\n";
			else if(state.isInitial)
				res += "\t"+state.name+" [shape=diamond];\n";
			else
				res += "\t"+state.name+" [shape=ellipse];\n";
		}
		for(state in states)
		{
			for(edge in state.outs)
				res += "\t"+edge.from.name + " -> " + edge.to.name + " [label=\"" + edge.value + "\"];\n";
		}
		res += "}";
		return res;
	}

	/**
		Render and save the state machine as a PNG Image
	**/
	public function saveAsPNG() : Void
	{
		sys.io.File.saveContent(name+".gv", toDOT());
		Sys.command("dot -Tpng -o"+name+".png "+name+".gv");
	}

	public static function main() : Int
	{
		///
		// Completion test
		///
		var m1 = new StateMachine("complete_before", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m1.addState(new State("0", true, false));
		var s1 = m1.addState(new State("1", false, false));
		var s2 = m1.addState(new State("2", false, false));
		var s3 = m1.addState(new State("3", false, true));
		m1.addEdge(new Edge("a", s0, s1));
		m1.addEdge(new Edge("a", s1, s2));
		m1.addEdge(new Edge("b", s2, s3));
		m1.addEdge(new Edge("b", s3, s0));
		m1.complete().saveAsPNG();
		var m2 = m1.complete();
		m2.name = "complete_after";
		m2.saveAsPNG();
		//*/

		///
		// Mirror test
		///
		var m3 = new StateMachine("mirror_before", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m3.addState(new State("0", true, false));
		var s1 = m3.addState(new State("1", false, false));
		var s2 = m3.addState(new State("2", false, false));
		var s3 = m3.addState(new State("3", false, true));
		m3.addEdge(new Edge("a", s0, s1));
		m3.addEdge(new Edge("a", s1, s2));
		m3.addEdge(new Edge("b", s2, s3));
		m3.addEdge(new Edge("b", s3, s0));
		m3.mirror().saveAsPNG();
		var m4 = m1.mirror();
		m4.name = "mirror_after";
		m4.saveAsPNG();
		//*/

		///
		// Union test
		///
		var m5 = new StateMachine("union_before_a", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m5.addState(new State("0", true, false));
		var s1 = m5.addState(new State("1", false, false));
		var s2 = m5.addState(new State("2", false, false));
		var s3 = m5.addState(new State("3", false, true));
		m5.addEdge(new Edge("a", s0, s1));
		m5.addEdge(new Edge("a", s1, s2));
		m5.addEdge(new Edge("b", s2, s3));
		m5.addEdge(new Edge("b", s3, s0));

		var m6 = new StateMachine("union_before_b", ["a", "b"]);
		var s2 = m6.addState(new State("2", true, true));
		var s3 = m6.addState(new State("3", false, false));
		var s4 = m6.addState(new State("4", false, false));
		m6.addEdge(new Edge("a", s2, s2));
		m6.addEdge(new Edge("a", s3, s3));
		m6.addEdge(new Edge("a", s4, s4));
		m6.addEdge(new Edge("b", s2, s3));
		m6.addEdge(new Edge("b", s3, s4));
		m6.addEdge(new Edge("b", s4, s2));

		m5.mirror().saveAsPNG();
		m6.mirror().saveAsPNG();
		
		var m7 = m5.union(m6);
		m7.name = "union_after";
		m7.saveAsPNG();
		//*/

		///
		// Intersection test
		///
		var m8 = new StateMachine("intersection_before_a", ["a", "b"]);
		var s0 = m8.addState(new State("0", true, true));
		var s1 = m8.addState(new State("1", false, false));
		m8.addEdge(new Edge("a", s0, s0));
		m8.addEdge(new Edge("a", s1, s1));
		m8.addEdge(new Edge("b", s0, s1));
		m8.addEdge(new Edge("b", s1, s0));

		var m9 = new StateMachine("intersection_before_b", ["a", "b"]);
		var s2 = m9.addState(new State("2", true, true));
		var s3 = m9.addState(new State("3", false, false));
		var s4 = m9.addState(new State("4", false, false));
		m9.addEdge(new Edge("a", s2, s2));
		m9.addEdge(new Edge("a", s3, s3));
		m9.addEdge(new Edge("a", s4, s4));
		m9.addEdge(new Edge("b", s2, s3));
		m9.addEdge(new Edge("b", s3, s4));
		m9.addEdge(new Edge("b", s4, s2));

		m8.saveAsPNG();
		m9.saveAsPNG();
		var m10 = m8.intersect(m9);
		m10.name="intersection_after";
		m10.saveAsPNG();
		//*/

		///
		// Determinization test
		///
		var m11 = new StateMachine("determinize_before", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m11.addState(new State("0", true, false));
		var s1 = m11.addState(new State("1", false, false));
		var s2 = m11.addState(new State("2", false, false));
		var s3 = m11.addState(new State("3", false, true));
		for(symbol in m11.alphabet)
		{	
			m11.addEdge(new Edge(symbol, s0, s1));
			m11.addEdge(new Edge(symbol, s0, s2));
			m11.addEdge(new Edge(symbol, s0, s3));
			m11.addEdge(new Edge(symbol, s1, s0));
			m11.addEdge(new Edge(symbol, s1, s2));
			m11.addEdge(new Edge(symbol, s1, s3));
			m11.addEdge(new Edge(symbol, s2, s0));
			m11.addEdge(new Edge(symbol, s2, s1));
			m11.addEdge(new Edge(symbol, s2, s3));
			m11.addEdge(new Edge(symbol, s3, s0));
			m11.addEdge(new Edge(symbol, s3, s1));
			m11.addEdge(new Edge(symbol, s3, s2));
		}
		m11.saveAsPNG();
		var m12 = m11.determinize();
		m12.name="determinize_after";
		m12.saveAsPNG();
		//*/

		///
		// Complementation test
		///
		var m13 = new StateMachine("complement_before", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m13.addState(new State("0", true, false));
		var s1 = m13.addState(new State("1", false, false));
		var s2 = m13.addState(new State("2", false, false));
		var s3 = m13.addState(new State("3", false, true));
		for(symbol in m13.alphabet)
		{	
			m13.addEdge(new Edge(symbol, s0, s1));
			m13.addEdge(new Edge(symbol, s0, s2));
			m13.addEdge(new Edge(symbol, s0, s3));
			m13.addEdge(new Edge(symbol, s1, s0));
			m13.addEdge(new Edge(symbol, s1, s2));
			m13.addEdge(new Edge(symbol, s1, s3));
			m13.addEdge(new Edge(symbol, s2, s0));
			m13.addEdge(new Edge(symbol, s2, s1));
			m13.addEdge(new Edge(symbol, s2, s3));
			m13.addEdge(new Edge(symbol, s3, s0));
			m13.addEdge(new Edge(symbol, s3, s1));
			m13.addEdge(new Edge(symbol, s3, s2));
		}
		m13.saveAsPNG();
		var m14 = m13.complement();
		m14.name="complement_after";
		m14.saveAsPNG();
		//*/
		
		///
		// Minimization test
		///
		var m15 = new StateMachine("minimize_before", ["a", "b", "c", "d", "e", "f"]);
		var s0 = m15.addState(new State("0", true, false));
		var s1 = m15.addState(new State("1", false, false));
		var s2 = m15.addState(new State("2", false, false));
		var s3 = m15.addState(new State("3", false, true));
		for(symbol in m15.alphabet)
		{	
			m15.addEdge(new Edge(symbol, s0, s1));
			m15.addEdge(new Edge(symbol, s0, s2));
			m15.addEdge(new Edge(symbol, s0, s3));
			m15.addEdge(new Edge(symbol, s1, s0));
			m15.addEdge(new Edge(symbol, s1, s2));
			m15.addEdge(new Edge(symbol, s1, s3));
			m15.addEdge(new Edge(symbol, s2, s0));
			m15.addEdge(new Edge(symbol, s2, s1));
			m15.addEdge(new Edge(symbol, s2, s3));
			m15.addEdge(new Edge(symbol, s3, s0));
			m15.addEdge(new Edge(symbol, s3, s1));
			m15.addEdge(new Edge(symbol, s3, s2));
		}
		m15.saveAsPNG();
		var m16 = m15.minimize();
		m16.name="minimize_after";
		m16.saveAsPNG();
		//*/

		return 0;
	}
}