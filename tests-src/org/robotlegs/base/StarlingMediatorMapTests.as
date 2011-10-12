/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
//	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.setTimeout;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.adapters.SwiftSuspendersReflector;
	import org.robotlegs.core.IEventMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.core.IStarlingMediatorMap;
	import org.robotlegs.mvcs.support.StarlingViewComponent;
	import org.robotlegs.mvcs.support.StarlingViewComponentAdvanced;
	import org.robotlegs.mvcs.support.StarlingViewMediator;
	import org.robotlegs.mvcs.support.StarlingViewMediatorAdvanced;
	import org.robotlegs.mvcs.support.TestStarlingContextView;
	import org.robotlegs.mvcs.support.TestStarlingContextViewMediator;

	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;

	public class StarlingMediatorMapTests
	{
		public static const TEST_EVENT:String = 'testEvent';

		protected var contextView:DisplayObjectContainer;
		protected var eventDispatcher:IEventDispatcher;
		protected var commandExecuted:Boolean;
		protected var mediatorMap:StarlingMediatorMap;
		protected var injector:IInjector;
		protected var reflector:IReflector;
		protected var eventMap:IEventMap;

		[BeforeClass]
		public static function runBeforeEntireSuite():void
		{
		}

		[AfterClass]
		public static function runAfterEntireSuite():void
		{
		}

		[Before(ui)]
		public function runBeforeEachTest():void
		{
			contextView = new TestStarlingContextView();
			eventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			reflector = new SwiftSuspendersReflector();
			mediatorMap = new StarlingMediatorMap(contextView, injector, reflector);

			injector.mapValue(DisplayObjectContainer, contextView);
			injector.mapValue(IInjector, injector);
			injector.mapValue(IEventDispatcher, eventDispatcher);
			injector.mapValue(IStarlingMediatorMap, mediatorMap);

//			UIImpersonator.addChild(contextView);
		}

		[After(ui)]
		public function runAfterEachTest():void
		{
			UIImpersonator.removeAllChildren();
			injector.unmap(IStarlingMediatorMap);
		}

		[Test]
		public function mediatorIsMappedAndCreatedForView():void
		{
			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, false, false);
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			contextView.addChild(viewComponent);
			var mediator:IMediator                  = mediatorMap.createMediator(viewComponent);
			var hasMapping:Boolean                  = mediatorMap.hasMapping(StarlingViewComponent);
			Assert.assertNotNull('Mediator should have been created ', mediator);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			Assert.assertTrue('View mapping should exist for View Component', hasMapping);
		}

		[Test]
		public function mediatorIsMappedAndCreatedWithInjectViewAsClass():void
		{
			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, StarlingViewComponent, false, false);
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			contextView.addChild(viewComponent);
			var mediator:IMediator                  = mediatorMap.createMediator(viewComponent);
			var exactMediator:StarlingViewMediator  = mediator as StarlingViewMediator;
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created of the exact desired class', mediator is StarlingViewMediator);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			Assert.assertNotNull('View Component should have been injected into Mediator', exactMediator.view);
			Assert.assertTrue('View Component injected should match the desired class type', exactMediator.view is StarlingViewComponent);
		}

		[Test]
		public function mediatorIsMappedAndCreatedWithInjectViewAsArrayOfSameClass():void
		{
			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, [StarlingViewComponent], false, false);
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			contextView.addChild(viewComponent);
			var mediator:IMediator                  = mediatorMap.createMediator(viewComponent);
			var exactMediator:StarlingViewMediator  = mediator as StarlingViewMediator;
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created of the exact desired class', mediator is StarlingViewMediator);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			Assert.assertNotNull('View Component should have been injected into Mediator', exactMediator.view);
			Assert.assertTrue('View Component injected should match the desired class type', exactMediator.view is StarlingViewComponent);
		}

		[Test]
		public function mediatorIsMappedAndCreatedWithInjectViewAsArrayOfRelatedClass():void
		{
			mediatorMap.mapView(StarlingViewComponentAdvanced, StarlingViewMediatorAdvanced, [StarlingViewComponent,
																							  StarlingViewComponentAdvanced], false, false);
			var viewComponentAdvanced:StarlingViewComponentAdvanced = new StarlingViewComponentAdvanced();
			contextView.addChild(viewComponentAdvanced);
			var mediator:IMediator                                  = mediatorMap.createMediator(viewComponentAdvanced);
			var exactMediator:StarlingViewMediatorAdvanced          = mediator as StarlingViewMediatorAdvanced;
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created of the exact desired class', mediator is StarlingViewMediatorAdvanced);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponentAdvanced));
			Assert.assertNotNull('First Class in the "injectViewAs" array should have been injected into Mediator', exactMediator.view);
			Assert.assertNotNull('Second Class in the "injectViewAs" array should have been injected into Mediator', exactMediator.viewAdvanced);
			Assert.assertTrue('First Class injected via the "injectViewAs" array should match the desired class type', exactMediator.view is StarlingViewComponent);
			Assert.assertTrue('Second Class injected via the "injectViewAs" array should match the desired class type', exactMediator.viewAdvanced is StarlingViewComponentAdvanced);
		}


		[Test]
		public function mediatorIsMappedAddedAndRemoved():void
		{
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			var mediator:IMediator;

			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, false, false);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			mediatorMap.removeMediator(mediator);
			Assert.assertFalse("Mediator Should Not Exist", mediatorMap.hasMediator(mediator));
			Assert.assertFalse("View Mediator Should Not Exist", mediatorMap.hasMediatorForView(viewComponent));
		}

		[Test]
		public function mediatorIsMappedAddedAndRemovedByView():void
		{
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			var mediator:IMediator;

			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, false, false);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			mediatorMap.removeMediatorByView(viewComponent);
			Assert.assertFalse("Mediator should not exist", mediatorMap.hasMediator(mediator));
			Assert.assertFalse("View Mediator should not exist", mediatorMap.hasMediatorForView(viewComponent));
		}

		[Test]
		public function autoRegister():void
		{
			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, true, true);
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			contextView.addChild(viewComponent);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
		}

		[Test(async, timeout = '500')]
		public function mediatorIsKeptDuringReparenting():void
		{
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			var mediator:IMediator;

			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, false, true);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			var container:Sprite                    = new Sprite();
			contextView.addChild(container);
			container.addChild(viewComponent);

			setTimeout(verifyMediatorSurvival, 500, {dispatcher: contextView, method: verifyMediatorSurvival,
													 view: viewComponent, mediator: mediator});
//			Async.handleEvent(this, contextView, Event.ENTER_FRAME, delayFurther, 500, {dispatcher: contextView,
//																						method: verifyMediatorSurvival,
//																						view: viewComponent,
//																						mediator: mediator});
		}

		private function verifyMediatorSurvival(data:Object):void
		{
			var viewComponent:StarlingViewComponent = data.view;
			var mediator:IMediator                  = data.mediator;
			Assert.assertTrue("Mediator should exist", mediatorMap.hasMediator(mediator));
			Assert.assertTrue("View Mediator should exist", mediatorMap.hasMediatorForView(viewComponent));
		}

		private var removalObject:Object;

		[Test(async, timeout = '1000')]
		public function mediatorIsRemovedWithView():void
		{
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			var mediator:IMediator;

			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, false, true);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));

			removalObject = {dispatcher: contextView, method: verifyMediatorRemoval, view: viewComponent,
							 mediator: mediator};
//			contextView.addEventListener(Event.REMOVED, onViewRemoved);
//			contextView.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemoved);
			contextView.removeChild(viewComponent);

//			verifyMediatorRemoval({dispatcher: contextView, method: verifyMediatorRemoval, view: viewComponent,
//								   mediator: mediator});
			setTimeout(verifyMediatorRemoval, 750, {dispatcher: contextView, method: verifyMediatorRemoval,
													view: viewComponent, mediator: mediator});

//			Async.handleEvent(this, contextView, Event.ENTER_FRAME, delayFurther, 500, {dispatcher: contextView,
//																						method: verifyMediatorRemoval,
//																						view: viewComponent,
//																						mediator: mediator});
		}

		private function onViewRemoved(event:starling.events.Event):void
		{
//			verifyMediatorRemoval(removalObject);
			setTimeout(verifyMediatorRemoval, 500, removalObject);
		}

		private function verifyMediatorRemoval(data:Object):void
		{
			var viewComponent:StarlingViewComponent = data.view;
			var mediator:IMediator                  = data.mediator;
			Assert.assertFalse("Mediator should not exist", mediatorMap.hasMediator(mediator));
			Assert.assertFalse("View Mediator should not exist", mediatorMap.hasMediatorForView(viewComponent));
		}

//		private function delayFurther(event:Event, data:Object):void
//		{
//			Async.handleEvent(this, data.dispatcher, Event.ENTER_FRAME, data.method, 500, data);
//			delete data.dispatcher;
//			delete data.method;
//		}

		[Test]
		public function contextViewMediatorIsCreatedWhenMapped():void
		{
			mediatorMap.mapView(TestStarlingContextView, TestStarlingContextViewMediator);
			Assert.assertTrue('Mediator should have been created for contextView', mediatorMap.hasMediatorForView(contextView));
		}

		[Test]
		public function contextViewMediatorIsNotCreatedWhenMappedAndAutoCreateIsFalse():void
		{
			mediatorMap.mapView(TestStarlingContextView, TestStarlingContextViewMediator, null, false);
			Assert.assertFalse('Mediator should NOT have been created for contextView', mediatorMap.hasMediatorForView(contextView));
		}

		[Test]
		public function unmapView():void
		{
			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator);
			mediatorMap.unmapView(StarlingViewComponent);
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();
			contextView.addChild(viewComponent);
			var hasMediator:Boolean                 = mediatorMap.hasMediatorForView(viewComponent);
			var hasMapping:Boolean                  = mediatorMap.hasMapping(StarlingViewComponent);
			Assert.assertFalse('Mediator should NOT have been created for View Component', hasMediator);
			Assert.assertFalse('View mapping should NOT exist for View Component', hasMapping);
		}

		[Test]
		public function autoRegisterUnregisterRegister():void
		{
			var viewComponent:StarlingViewComponent = new StarlingViewComponent();

			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, true, true);
			mediatorMap.unmapView(StarlingViewComponent);
			contextView.addChild(viewComponent);
			Assert.assertFalse('Mediator should NOT have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			contextView.removeChild(viewComponent);

			mediatorMap.mapView(StarlingViewComponent, StarlingViewMediator, null, true, true);
			contextView.addChild(viewComponent);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
		}
	}
}
