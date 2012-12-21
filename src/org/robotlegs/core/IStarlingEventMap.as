package org.robotlegs.core
{
	import starling.events.EventDispatcher;

	public interface IStarlingEventMap extends IEventMap
	{
		function mapStarlingListener(dispatcher:EventDispatcher, type:String, listener:Function, eventClass:Class = null):void;
		function unmapStarlingListener(dispatcher:EventDispatcher, type:String, listener:Function, eventClass:Class = null):void;
	}
}
