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
	import flash.utils.setTimeout;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.core.IStarlingMediatorMap;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;

	/**
	 * An abstract <code>IMediatorMap</code> implementation
	 */
	public class StarlingMediatorMap extends StarlingViewMapBase implements IStarlingMediatorMap
	{
		/**
		 * @private
		 */
		protected static const enterFrameDispatcher:Sprite = new Sprite();

		/**
		 * @private
		 */
		protected var mediatorByView:Dictionary;

		/**
		 * @private
		 */
		protected var mappingConfigByView:Dictionary;

		/**
		 * @private
		 */
		protected var mappingConfigByViewClassName:Dictionary;

		/**
		 * @private
		 */
		protected var mediatorsMarkedForRemoval:Dictionary;

		/**
		 * @private
		 */
		protected var hasMediatorsMarkedForRemoval:Boolean;

		/**
		 * @private
		 */
		protected var reflector:IReflector;


		//---------------------------------------------------------------------
		//  Constructor
		//---------------------------------------------------------------------

		/**
		 * Creates a new <code>MediatorMap</code> object
		 *
		 * @param contextView The root view node of the context. The map will listen for ADDED_TO_STAGE events on this node
		 * @param injector An <code>IInjector</code> to use for this context
		 * @param reflector An <code>IReflector</code> to use for this context
		 */
		public function StarlingMediatorMap(contextView:DisplayObjectContainer,
											injector:IInjector,
											reflector:IReflector)
		{
			super(contextView, injector);

			this.reflector = reflector;

			// mappings - if you can do it with fewer dictionaries you get a prize
			this.mediatorByView = new Dictionary(true);
			this.mappingConfigByView = new Dictionary(true);
			this.mappingConfigByViewClassName = new Dictionary(false);
			this.mediatorsMarkedForRemoval = new Dictionary(false);
		}

		//---------------------------------------------------------------------
		//  API
		//---------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function mapView(viewClassOrName:*,
								mediatorClass:Class,
								injectViewAs:*=null,
								autoCreate:Boolean=true,
								autoRemove:Boolean=true):void
		{
			var viewClassName:String = reflector.getFQCN(viewClassOrName);

			if (mappingConfigByViewClassName[viewClassName] != null)
				throw new ContextError(ContextError.E_MEDIATORMAP_OVR + ' - ' + mediatorClass);

			if (reflector.classExtendsOrImplements(mediatorClass, IMediator) == false)
				throw new ContextError(ContextError.E_MEDIATORMAP_NOIMPL + ' - ' + mediatorClass);

			var config:MappingConfig = new MappingConfig();
			config.mediatorClass = mediatorClass;
			config.autoCreate = autoCreate;
			config.autoRemove = autoRemove;
			if (injectViewAs)
			{
				if (injectViewAs is Array)
				{
					config.typedViewClasses = (injectViewAs as Array).concat();
				}
				else if (injectViewAs is Class)
				{
					config.typedViewClasses = [injectViewAs];
				}
			}
			else if (viewClassOrName is Class)
			{
				config.typedViewClasses = [viewClassOrName];
			}
			mappingConfigByViewClassName[viewClassName] = config;

			if (autoCreate || autoRemove)
			{
				viewListenerCount++;
				if (viewListenerCount == 1)
					addListeners(contextView);
			}

			// This was a bad idea - causes unexpected eager instantiation of object graph 
			if (autoCreate && contextView && (viewClassName == getQualifiedClassName(contextView)))
				createMediatorUsing(contextView, viewClassName, config);
		}

		/**
		 * @inheritDoc
		 */
		public function unmapView(viewClassOrName:*):void
		{
			var viewClassName:String = reflector.getFQCN(viewClassOrName);
			var config:MappingConfig = mappingConfigByViewClassName[viewClassName];
			if (config && (config.autoCreate || config.autoRemove))
			{
				viewListenerCount--;
				if (viewListenerCount == 0)
					removeListeners(contextView);
			}
			delete mappingConfigByViewClassName[viewClassName];
		}

		/**
		 * @inheritDoc
		 */
		public function createMediator(viewComponent:Object):IMediator
		{
			return createMediatorUsing(viewComponent);
		}

		/**
		 * @inheritDoc
		 */
		public function registerMediator(viewComponent:Object, mediator:IMediator):void
		{
			injector.mapValue(reflector.getClass(mediator), mediator);
			mediatorByView[viewComponent] = mediator;
			mappingConfigByView[viewComponent] = mappingConfigByViewClassName[getQualifiedClassName(viewComponent)];
			mediator.setViewComponent(viewComponent);
			mediator.preRegister();
		}

		/**
		 * @inheritDoc
		 */
		public function removeMediator(mediator:IMediator):IMediator
		{
			if (mediator)
			{
				var viewComponent:Object = mediator.getViewComponent();
				delete mediatorByView[viewComponent];
				delete mappingConfigByView[viewComponent];
				mediator.preRemove();
				mediator.setViewComponent(null);
				injector.unmap(reflector.getClass(mediator));
			}
			return mediator;
		}

		/**
		 * @inheritDoc
		 */
		public function removeMediatorByView(viewComponent:Object):IMediator
		{
			return removeMediator(retrieveMediator(viewComponent));
		}

		/**
		 * @inheritDoc
		 */
		public function retrieveMediator(viewComponent:Object):IMediator
		{
			return mediatorByView[viewComponent];
		}

		/**
		 * @inheritDoc
		 */
		public function hasMapping(viewClassOrName:*):Boolean
		{
			var viewClassName:String = reflector.getFQCN(viewClassOrName);
			return (mappingConfigByViewClassName[viewClassName] != null);
		}

		/**
		 * @inheritDoc
		 */
		public function hasMediatorForView(viewComponent:Object):Boolean
		{
			return mediatorByView[viewComponent] != null;
		}

		/**
		 * @inheritDoc
		 */
		public function hasMediator(mediator:IMediator):Boolean
		{
			for each (var med:IMediator in mediatorByView)
				if (med == mediator)
					return true;
			return false;
		}

		//---------------------------------------------------------------------
		//  Internal
		//---------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addListeners(dispatcher:DisplayObjectContainer):void
		{
			if (dispatcher && enabled)
			{
				dispatcher.addEventListener(Event.ADDED, onViewAdded);
				dispatcher.addEventListener(Event.REMOVED, onViewRemoved);
				dispatcher.addEventListener(Event.ADDED_TO_STAGE, onViewAdded);
				dispatcher.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemoved);
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
				dispatcher.removeEventListener(Event.REMOVED, onViewRemoved);
				dispatcher.removeEventListener(Event.ADDED_TO_STAGE, onViewAdded);
				dispatcher.removeEventListener(Event.REMOVED_FROM_STAGE, onViewRemoved);
			}
		}

		/**
		 * @private
		 */
		protected function addView(view:DisplayObject):void
		{
			if (mediatorsMarkedForRemoval[view])
			{
				delete mediatorsMarkedForRemoval[view];
			}
			else
			{
				var viewClassName:String = getQualifiedClassName(view);
				var config:MappingConfig = mappingConfigByViewClassName[viewClassName];
				if (config && config.autoCreate)
					createMediatorUsing(view, viewClassName, config);
			}

			var viewContainer:DisplayObjectContainer = view as DisplayObjectContainer;
			if (viewContainer)
			{
				var childCount:int = viewContainer.numChildren;
				for (var i:int = 0; i < childCount; i++)
				{
					var child:DisplayObject = viewContainer.getChildAt(i);
					addView(child);
				}
			}
		}

		/**
		 * @private
		 */
		protected function removeView(view:DisplayObject):void
		{
			var config:MappingConfig = mappingConfigByView[view];
			if (config && config.autoRemove)
			{
				mediatorsMarkedForRemoval[view] = view;

				if (!hasMediatorsMarkedForRemoval)
				{
					hasMediatorsMarkedForRemoval = true;

					setTimeout(removeMediatorLater, 500, null);
				}
			}

			var viewContainer:DisplayObjectContainer = view as DisplayObjectContainer;
			if (viewContainer)
			{
				var childCount:int = viewContainer.numChildren;
				for (var i:int = 0; i < childCount; i++)
				{
					var child:DisplayObject = viewContainer.getChildAt(i);
					removeView(child);
				}
			}
		}

		/**
		 * @private
		 */
		protected override function onViewAdded(e:Event):void
		{
			var view:DisplayObject = DisplayObject(e.target);
			addView(view);
		}

		/**
		 * @private
		 */
		protected function createMediatorUsing(viewComponent:Object, viewClassName:String='', config:MappingConfig=null):IMediator
		{
			var mediator:IMediator = mediatorByView[viewComponent];
			if (mediator == null)
			{
				if (!viewClassName)
					viewClassName = getQualifiedClassName(viewComponent);
				if (!config)
					config = mappingConfigByViewClassName[viewClassName];
				if (config)
				{
					for each (var claxx:Class in config.typedViewClasses)
					{
						injector.mapValue(claxx, viewComponent);
					}
					mediator = injector.instantiate(config.mediatorClass);
					for each (var clazz:Class in config.typedViewClasses)
					{
						injector.unmap(clazz);
					}
					registerMediator(viewComponent, mediator);
				}
			}
			return mediator;
		}

		/**
		 * Flex framework work-around part #5
		 */
		protected function onViewRemoved(e:Event):void
		{
			var view:DisplayObject = DisplayObject(e.target);
			removeView(view);
		}

		/**
		 * Flex framework work-around part #6
		 */
		protected function removeMediatorLater(event:Event):void
		{
			for each (var view:DisplayObject in mediatorsMarkedForRemoval)
			{
				if (!view.stage)
					removeMediatorByView(view);
				delete mediatorsMarkedForRemoval[view];
			}
			hasMediatorsMarkedForRemoval = false;
		}
		
		public function listen(dispatcher:DisplayObjectContainer):void
		{
			addListeners(dispatcher);
		}
	}
}

class MappingConfig
{
	public var mediatorClass:Class;
	public var typedViewClasses:Array;
	public var autoCreate:Boolean;
	public var autoRemove:Boolean;
}
