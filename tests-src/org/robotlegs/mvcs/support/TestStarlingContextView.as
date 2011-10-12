/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.robotlegs.mvcs.support
{
	import starling.display.Sprite;
	import starling.events.Event;

	public class TestStarlingContextView extends Sprite
	{
		[Inject(name = "injectionName")]
		public var injectionPoint:String;

		static public var instance:TestStarlingContextView;

		public function TestStarlingContextView()
		{
			super();

			instance = this;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event:Event):void
		{
		}
	}
}
