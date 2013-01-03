/*
 * Copyright (c) 2009, 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	import org.robotlegs.core.IInjector;

	/**
	 * A base ViewMap implementation
	 */
	public class StarlingViewMapBase
	{
		/**
		 * @private
		 */
		protected var _enabled:Boolean = true;

		/**
		 * @private
		 */
		protected var _contextView:DisplayObjectContainer;

		/**
		 * @private
		 */
		protected var injector:IInjector;

		/**
		 * @private
		 */
		protected var useCapture:Boolean;

		/**
		 * @private
		 */
		protected var viewListenerCount:uint;

		//---------------------------------------------------------------------
		// Constructor
		//---------------------------------------------------------------------

		/**
		 * Creates a new <code>ViewMap</code> object
		 *
		 * @param contextView The root view node of the context. The map will listen for ADDED_TO_STAGE events on this node
		 * @param injector An <code>IInjector</code> to use for this context
		 */
		public function StarlingViewMapBase(contextView:DisplayObjectContainer, injector:IInjector)
		{
			this.injector = injector;

			// change this at your peril lest ye understand the problem and have a better solution
			this.useCapture = true;

			// this must come last, see the setter
			this.contextView = contextView;
		}

		//---------------------------------------------------------------------
		// API
		//---------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		public function get contextView():DisplayObjectContainer
		{
			return _contextView;
		}

		/**
		 * @inheritDoc
		 */
		public function set contextView(value:DisplayObjectContainer):void
		{
			if (value != _contextView)
			{
				removeListeners(_contextView);
				_contextView = value;
				if (viewListenerCount > 0)
					addListeners(_contextView);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}

		/**
		 * @inheritDoc
		 */
		public function set enabled(value:Boolean):void
		{
			if (value != _enabled)
			{
				removeListeners(_contextView);
				_enabled = value;
				if (viewListenerCount > 0)
					addListeners(_contextView);
			}
		}

		//---------------------------------------------------------------------
		// Internal
		//---------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function addListeners(dispatcher:DisplayObjectContainer):void
		{
		}

		/**
		 * @private
		 */
		protected function removeListeners(dispatcher:DisplayObjectContainer):void
		{
		}

		/**
		 * @private
		 */
		protected function onViewAdded(e:Event):void
		{
		}
	}
}
