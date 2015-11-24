package stateMachine;

import flash.events.Event;

class StateMachineEvent extends Event
{
	public inline static var EXIT_CALLBACK:String = "exit";
	public inline static var ENTER_CALLBACK:String = "enter";
	public inline static var TRANSITION_COMPLETE:String = "transition complete";
	public inline static var TRANSITION_DENIED:String = "transition denied";
	
	public var fromState : String;
	public var toState : String;
	public var currentState : String;
	public var allowedStates : Dynamic;

	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
	}
}
