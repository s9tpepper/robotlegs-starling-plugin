/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.events.IEventDispatcher;

	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	import org.robotlegs.core.IStarlingEventMap;
	
	/**
	 * An abstract <code>IStarlingEventMap</code> implementation
	 */
	public class StarlingEventMap extends EventMap implements IStarlingEventMap
	{
		/**
		 * @private
		 */
		protected var starlingListeners:Array;
		
		//---------------------------------------------------------------------
		//  Constructor
		//---------------------------------------------------------------------
		
		/**
		 * Creates a new <code>StarlingEventMap</code> object
		 *
		 * @param eventDispatcher An <code>IEventDispatcher</code> to treat as a bus
		 */
		public function StarlingEventMap(eventDispatcher:IEventDispatcher)
		{
			super(eventDispatcher)
			starlingListeners = new Array();
		}
		
		/**
		 * The same as calling <code>addEventListener</code> directly on the Starling <code>EventDispatcher</code>,
		 * but keeps a list of listeners for easy (usually automatic) removal.
		 *
		 * @param dispatcher The <code>EventDispatcher</code> to listen to
		 * @param type The <code>Event</code> type to listen for
		 * @param listener The <code>Event</code> handler
		 * @param eventClass Optional Event class for a stronger mapping. Defaults to <code>starling.events.Event</code>.
		 */
		public function mapStarlingListener(dispatcher:EventDispatcher, type:String, listener:Function, eventClass:Class = null):void
		{
			eventClass ||= Event;
			
			var params:Object;
			var i:int = starlingListeners.length;
			while (i--)
			{
				params = starlingListeners[i];
				if (params.dispatcher == dispatcher
					&& params.type == type
					&& params.listener == listener
					&& params.eventClass == eventClass)
				{
					return;
				}
			}
			
			var callback:Function = function(event:Event):void
			{
				routeStarlingEventToListener(event, listener, eventClass);
			};
			params = {
				dispatcher: dispatcher,
				type: type,
				listener: listener,
				eventClass: eventClass,
				callback: callback
			};
			starlingListeners.push(params);
			dispatcher.addEventListener(type, callback);
		}
		
		/**
		 * The same as calling <code>removeEventListener</code> directly on the Starling <code>EventDispatcher</code>,
		 * but updates our local list of listeners.
		 *
		 * @param dispatcher The <code>EventDispatcher</code>
		 * @param type The <code>Event</code> type
		 * @param listener The <code>Event</code> handler
		 * @param eventClass Optional Event class for a stronger mapping. Defaults to <code>starling.events.Event</code>.
		 */
		public function unmapStarlingListener(dispatcher:EventDispatcher, type:String, listener:Function, eventClass:Class = null):void
		{
			eventClass ||= Event;
			var params:Object;
			var i:int = starlingListeners.length;
			while (i--)
			{
				params = starlingListeners[i];
				if (params.dispatcher == dispatcher
					&& params.type == type
					&& params.listener == listener
					&& params.eventClass == eventClass)
				{
					dispatcher.removeEventListener(type, params.callback);
					starlingListeners.splice(i, 1);
					return;
				}
			}
		}
		
		/**
		 * Removes all listeners registered through <code>mapListener</code>
		 */
		override public function unmapListeners():void
		{
			super.unmapListeners();
			var params:Object;
			var dispatcher:EventDispatcher;
			while (params = starlingListeners.pop())
			{
				dispatcher = params.dispatcher;
				dispatcher.removeEventListener(params.type, params.callback);
			}
		}
		
		//---------------------------------------------------------------------
		//  Internal
		//---------------------------------------------------------------------
		
		/**
		 * Event Handler
		 *
		 * @param event The <code>Event</code>
		 * @param listener
		 * @param originalEventClass
		 */
		protected function routeStarlingEventToListener(event:Event, listener:Function, originalEventClass:Class):void
		{
			if (event is originalEventClass)
			{
				var numArgs:int = listener.length;
				if (numArgs == 0) listener();
				else if (numArgs == 1) listener(event);
				else listener(event, event.data);
			}
		}
	}
}