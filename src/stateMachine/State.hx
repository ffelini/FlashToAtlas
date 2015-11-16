package stateMachine;

class State
{
	public var name:String;
	public var from:Dynamic;
	public var enter:Dynamic;
	public var exit:Dynamic;
	public var _parent:State;
	public var children:Array<State>;
	
	public function new(name:String, from:Dynamic = null, enter:Dynamic = null, exit:Dynamic = null, parent:State = null)
	{
		this.name = name;
		if (!from) from = "*";
		this.from = from;
		this.enter = enter;
		this.exit = exit;
		this.children = [];
		if (parent!=null)
		{
			_parent = parent;
			_parent.children.push(this);
		}
	}
	public function enterState(data:Dynamic,evt:StateMachineEvent):Void
	{
		
	}
	public function exitState(data:Dynamic,evt:StateMachineEvent):Void
	{
		
	}
	public var parent(get, set):State;
	public function set_parent(parent:State):State
	{
		_parent = parent;
		_parent.children.push(this);
		return _parent;
	}
	
	public function get_parent():State
	{
		return _parent;
	}
	public var root(get, null):State;
	public function get_root():State
	{
		var parentState:State = _parent;
		if(parentState!=null)
		{
			while (parentState.parent!=null)
			{
				parentState = parentState.parent;
			}
		}
		return parentState;
	}
	public var parents(get, null):Array<State>;
	public function get_parents():Array<State>
	{
		var parentList:Array<State> = [];
		var parentState:State = _parent;
		if(parentState!=null)
		{
			parentList.push(parentState);
			while (parentState.parent!=null)
			{
				parentState = parentState.parent;
				parentList.push(parentState);
			}
		}
		return parentList;
	}
	public function toString():String
	{
		return this.name;
	}
}
