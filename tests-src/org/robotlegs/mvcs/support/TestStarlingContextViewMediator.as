package org.robotlegs.mvcs.support
{
	import flash.events.Event;

	import org.robotlegs.mvcs.StarlingMediator;

	public class TestStarlingContextViewMediator extends StarlingMediator
	{
		public static const MEDIATOR_IS_REGISTERED:String = "MediatorIsRegistered";

		public function TestStarlingContextViewMediator()
		{
			super();
		}

		override public function onRegister():void
		{
			eventDispatcher.dispatchEvent(new Event(MEDIATOR_IS_REGISTERED));
		}
	}
}
