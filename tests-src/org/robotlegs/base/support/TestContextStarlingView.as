/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.robotlegs.base.support
{
	import starling.display.Sprite;

	public class TestContextStarlingView extends Sprite
	{
		[Inject(name = "injectionName")]
		public var injectionPoint:String;

		static public var instance:TestContextStarlingView;

		public function TestContextStarlingView()
		{
			instance = this;
		}
	}
}
