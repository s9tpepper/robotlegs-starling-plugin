/*
 * Copyright (c) 2009, 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IStarlingViewMap;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	/**
	 * An abstract <code>IViewMap</code> implementation
	 */
	public class StarlingViewMap extends StarlingViewMapBase implements IStarlingViewMap
	{
		/**
		 * @private
		 */
		protected var mappedPackages:Array;

		/**
		 * @private
		 */
		protected var mappedTypes:Dictionary;

		/**
		 * @private
		 */
		protected var injectedViews:Dictionary;

		//---------------------------------------------------------------------
		// Constructor
		//---------------------------------------------------------------------

		/**
		 * Creates a new <code>ViewMap</code> object
		 *
		 * @param contextView The root view node of the context. The map will listen for ADDED_TO_STAGE events on this node
		 * @param injector An <code>IInjector</code> to use for this context
		 */
		public function StarlingViewMap(contextView:DisplayObjectContainer, injector:IInjector)
		{
			super(contextView, injector);

			// mappings - if you can do it with fewer dictionaries you get a prize
			this.mappedPackages = new Array();
			this.mappedTypes = new Dictionary(false);
			this.injectedViews = new Dictionary(true);
		}

		//---------------------------------------------------------------------
		// API
		//---------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function mapPackage(packageName:String):void
		{
			if (mappedPackages.indexOf(packageName) == -1)
			{
				mappedPackages.push(packageName);
				viewListenerCount++;
				if (viewListenerCount == 1)
					addListeners(_contextView);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function unmapPackage(packageName:String):void
		{
			var index:int = mappedPackages.indexOf(packageName);
			if (index > -1)
			{
				mappedPackages.splice(index, 1);
				viewListenerCount--;
				if (viewListenerCount == 0)
					removeListeners(_contextView);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function mapType(type:Class):void
		{
			if (mappedTypes[type])
				return;

			mappedTypes[type] = type;

			viewListenerCount++;
			if (viewListenerCount == 1)
				addListeners(_contextView);

			// This was a bad idea - causes unexpected eager instantiation of object graph 
			if (contextView && (contextView is type))
				injectInto(contextView);
		}

		/**
		 * @inheritDoc
		 */
		public function unmapType(type:Class):void
		{
			var mapping:Class = mappedTypes[type];
			delete mappedTypes[type];
			if (mapping)
			{
				viewListenerCount--;
				if (viewListenerCount == 0)
					removeListeners(_contextView);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function hasType(type:Class):Boolean
		{
			return (mappedTypes[type] != null);
		}

		/**
		 * @inheritDoc
		 */
		public function hasPackage(packageName:String):Boolean
		{
			return mappedPackages.indexOf(packageName) > -1;
		}

		//---------------------------------------------------------------------
		// Internal
		//---------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addListeners(dispatcher:DisplayObjectContainer):void
		{
			if (dispatcher && enabled)
			{
				dispatcher.addEventListener(Event.ADDED, onViewAdded);
			}
		}

		/**
		 * @private
		 */
		protected override function removeListeners(dispatcher:DisplayObjectContainer):void
		{
			if (dispatcher)
			{
				dispatcher.removeEventListener(Event.ADDED, onViewAdded);
			}
		}

		/**
		 * @private
		 */
		protected override function onViewAdded(e:Event):void
		{
			var target:DisplayObject = DisplayObject(e.target);
			if (injectedViews[target])
				return;

			for each (var type:Class in mappedTypes)
			{
				if (target is type)
				{
					injectInto(target);
					return;
				}
			}

			var len:int              = mappedPackages.length;
			if (len > 0)
			{
				var className:String = getQualifiedClassName(target);
				for (var i:int = 0; i < len; i++)
				{
					var packageName:String = mappedPackages[i];
					if (className.indexOf(packageName) == 0)
					{
						injectInto(target);
						return;
					}
				}
			}
		}

		protected function injectInto(target:DisplayObject):void
		{
			injector.injectInto(target);
			injectedViews[target] = true;
		}
	}
}
