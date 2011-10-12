/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.mvcs.support
{
	import org.robotlegs.mvcs.StarlingMediator;

	public class StarlingViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:StarlingViewComponent;

		public function StarlingViewMediator()
		{
		}

		override public function onRegister():void
		{

		}

		override public function onRemove():void
		{

		}
	}
}
