/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.robotlegs.mvcs
{
  import flash.display.Stage;
  import flash.events.Event;

  import mx.core.FlexGlobals;

  import org.flexunit.Assert;
  import org.fluint.uiImpersonation.UIImpersonator;
  import org.robotlegs.base.ContextEvent;
  import org.robotlegs.mvcs.support.TestStarlingContext;
  import org.robotlegs.mvcs.support.TestStarlingContextView;

  import starling.core.Starling;
  import starling.display.DisplayObjectContainer;
  import starling.display.Sprite;

  public class StarlingContextTests
	{
		private var context:TestStarlingContext;
		private var contextView:DisplayObjectContainer;
		private var testMain:Sprite;
		public static var starlingInstance:Starling;

		[BeforeClass]
		public static function runBeforeEntireSuite():void
		{
			if (starlingInstance)
			{
				starlingInstance.dispose();
				starlingInstance = null;
			}
		}

		[AfterClass]
		public static function runAfterEntireSuite():void
		{
		}

		[Before(ui)]
		public function runBeforeEachTest():void
		{
			if (!starlingInstance)
			{
        var stage:Stage = UIImpersonator.testDisplay.stage as Stage;
        trace("stage = " + stage);
				starlingInstance = new Starling(TestStarlingContextView, stage);
				starlingInstance.start();
			}
			contextView = TestStarlingContextView.instance;
			testMain = TestStarlingContextView.instance;


		}

		[After(ui)]
		public function runAfterEachTest():void
		{
			if (testMain && testMain.numChildren)
				testMain.removeChildren();
			testMain = null;

      if (contextView && contextView.numChildren) {
        contextView.removeChildren();
      }
      contextView = null;

      if (starlingInstance) {
        starlingInstance.dispose();
      }

      starlingInstance = null;
		}

		[Test]
		public function autoStartupWithViewComponent():void
		{
			context = new TestStarlingContext(contextView, true);
			Assert.assertTrue("Context should have started, contextView.stage = " + contextView.stage, context.startupComplete);
		}

		[Test]
		public function autoStartupWithLateViewComponent():void
		{
			context = new TestStarlingContext(null, true);
			Assert.assertFalse("Context should NOT have started", context.startupComplete);
			context.contextView = contextView;
			Assert.assertTrue("Context should have started", context.startupComplete);
		}

		[Test]
		public function manualStartupWithViewComponent():void
		{
			context = new TestStarlingContext(contextView, false);
			Assert.assertFalse("Context should NOT have started", context.startupComplete);
			context.startup();
			Assert.assertTrue("Context should now be started", context.startupComplete);
		}

		[Test]
		public function manualStartupWithLateViewComponent():void
		{
			context = new TestStarlingContext(null, false);
			Assert.assertFalse("Context should NOT have started", context.startupComplete);
			context.contextView = contextView;
			context.startup();
			Assert.assertTrue("Context should now be started", context.startupComplete);
		}

		[Test(async, timeout = "3000")]
		public function autoStartupWithViewComponentAfterAddedToStage():void
		{
			contextView = new TestStarlingContextView();
			context = new TestStarlingContext(contextView, true);
			contextView.addEventListener(ContextEvent.STARTUP_COMPLETE, handleContextAutoStartupOnAddedToStage);

			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			var tester:Sprite = new Sprite();
			tester.addChild(contextView);
		}

		[Test(async, timeout = "3000")]
		public function autoStartupWithLateViewComponentAfterAddedToStage():void
		{
			contextView = new TestStarlingContextView();
			context = new TestStarlingContext(null, true);
//			Async.handleEvent(this, context, ContextEvent.STARTUP_COMPLETE, handleContextAutoStartupOnAddedToStage);
			context.addEventListener(ContextEvent.STARTUP_COMPLETE, handleContextAutoStartupOnAddedToStage);
			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			context.contextView = contextView;
			Assert.assertFalse("Context should still NOT be started", context.startupComplete);
			testMain = new Sprite();
			testMain.addChild(contextView);
		}

		private function handleContextAutoStartupOnAddedToStage(event:ContextEvent):void
		{
			Assert.assertTrue("Context should be started", context.startupComplete);
		}

		[Test(async, timeout = "3000")]
		public function manualStartupWithViewComponentAfterAddedToStage():void
		{
			contextView = new TestStarlingContextView();
			context = new TestStarlingContext(contextView, false);
			context.addEventListener(Event.ADDED_TO_STAGE, handleContextManualStartupOnAddedToStage);
			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			testMain.addChild(contextView);
		}

		private function handleContextManualStartupOnAddedToStage(event:Event):void
		{
			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			context.startup();
			Assert.assertTrue("Context should now be started", context.startupComplete);
		}

		[Test]
		public function contextInitializationComplete():void
		{
			context = new TestStarlingContext(contextView);
			Assert.assertTrue("Context should be initialized", context.isInitialized);
		}
	}
}
