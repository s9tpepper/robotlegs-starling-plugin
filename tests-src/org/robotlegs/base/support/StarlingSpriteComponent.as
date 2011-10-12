/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base.support
{
	import starling.display.Sprite;

	public class StarlingSpriteComponent extends Sprite implements ITestComponent
	{
		[Inject(name = "injectionName")]
		public var injectionPoint:String;

		public function StarlingSpriteComponent()
		{
		}
	}
}
