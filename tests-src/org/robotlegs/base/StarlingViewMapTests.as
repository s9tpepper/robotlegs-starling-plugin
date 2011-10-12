/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.display.Stage;
	import flash.utils.setTimeout;

	import mx.core.FlexGlobals;

	import org.flexunit.Assert;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.hamcrest.object.nullValue;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.adapters.SwiftSuspendersReflector;
	import org.robotlegs.base.support.ITestComponent;
	import org.robotlegs.base.support.StarlingSpriteComponent;
	import org.robotlegs.base.support.TestContextStarlingView;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.core.IStarlingViewMap;
	import org.robotlegs.mvcs.StarlingContextTests;
	import org.robotlegs.mvcs.support.TestStarlingContextView;

	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class StarlingViewMapTests
	{
		protected static const INJECTION_NAME:String   = 'injectionName';
		protected static const INJECTION_STRING:String = 'injectionString';

		protected var contextView:TestStarlingContextView;
		protected var testView:StarlingSpriteComponent;
		protected var injector:IInjector;
		protected var reflector:IReflector;
		protected var viewMap:IStarlingViewMap;
		private var testMain:Sprite;

		[BeforeClass]
		public static function runBeforeSuite():void
		{
			if (!StarlingContextTests.starlingInstance)
			{
				StarlingContextTests.starlingInstance = new Starling(TestStarlingContextView, FlexGlobals.topLevelApplication.stage as flash.display.Stage);
				StarlingContextTests.starlingInstance.start();
			}
		}

		[Before(ui)]
		public function runBeforeEachTest():void
		{
			contextView = TestStarlingContextView.instance;
			testView = new StarlingSpriteComponent();
			injector = new SwiftSuspendersInjector();
			reflector = new SwiftSuspendersReflector();
			viewMap = new StarlingViewMap(contextView, injector);

			injector.mapValue(String, INJECTION_STRING, INJECTION_NAME);
		}

		[After(ui)]
		public function runAfterEachTest():void
		{
			if (testMain && testMain.numChildren)
				testMain.removeChildren();
			testMain = null;
			testView = null;
			contextView.removeChildren();
			contextView = null;
			testView = null;
			viewMap.enabled = false;
			viewMap = null;
			injector = null;
			reflector = null;
		}

		[Test]
		public function mapType():void
		{
			viewMap.mapType(StarlingSpriteComponent);
			var mapped:Boolean = viewMap.hasType(StarlingSpriteComponent);
			Assert.assertTrue("Class should be mapped", mapped);
		}

		[Test]
		public function unmapType():void
		{
			viewMap.mapType(StarlingSpriteComponent);
			viewMap.unmapType(StarlingSpriteComponent);
			var mapped:Boolean = viewMap.hasType(StarlingSpriteComponent);
			Assert.assertFalse("Class should NOT be mapped", mapped);
		}

		[Test(async, timeout = "5000")]
		public function mapTypeAndAddToDisplay():void
		{
			viewMap.mapType(StarlingSpriteComponent);
			contextView.addChild(testView);
			Assert.assertEquals("Injection points should be satisfied", INJECTION_STRING, testView.injectionPoint);
		}

		[Test]
		public function unmapTypeAndAddToDisplay():void
		{
			viewMap.mapType(StarlingSpriteComponent);
			viewMap.unmapType(StarlingSpriteComponent);
			testView = new StarlingSpriteComponent();
			contextView.addChild(testView);
			Assert.assertNull("Injection points should NOT be satisfied after unmapping", testView.injectionPoint);
		}

		[Test]
		public function mapTypeAndAddToDisplayTwice():void
		{
			viewMap.mapType(StarlingSpriteComponent);
			contextView.addChild(testView);
			testView.injectionPoint = null;
			contextView.removeChild(testView);
			contextView.addChild(testView);
			Assert.assertNull("View should NOT be injected into twice", testView.injectionPoint);
		}

		[Test]
		public function mapTypeOfContextViewShouldInjectIntoIt():void
		{
			viewMap.mapType(TestStarlingContextView);
			Assert.assertEquals("Injection points in contextView should be satisfied", INJECTION_STRING, contextView.injectionPoint);
		}

		[Test]
		public function mapTypeOfContextViewTwiceShouldInjectOnlyOnce():void
		{
			viewMap.mapType(TestContextStarlingView);
			contextView.injectionPoint = null;
			viewMap.mapType(TestContextStarlingView);
			Assert.assertNull("contextView should NOT be injected into twice", testView.injectionPoint);
		}

		[Test]
		public function mapPackage():void
		{
			viewMap.mapPackage('org.robotlegs');
			var mapped:Boolean = viewMap.hasPackage('org.robotlegs');
			Assert.assertTrue("Package should be mapped", mapped);
		}

		[Test]
		public function unmapPackage():void
		{
			viewMap.mapPackage('org.robotlegs');
			viewMap.unmapPackage('org.robotlegs');
			var mapped:Boolean = viewMap.hasPackage('org.robotlegs');
			Assert.assertFalse("Package should NOT be mapped", mapped);
		}

		[Test]
		public function mappedPackageIsInjected():void
		{
			viewMap.mapPackage('org.robotlegs');
			contextView.addChild(testView);
			Assert.assertEquals("Injection points should be satisfied", INJECTION_STRING, testView.injectionPoint);
		}

		[Test]
		public function mappedAbsolutePackageIsInjected():void
		{
			viewMap.mapPackage('org.robotlegs.base.support');
			contextView.addChild(testView);
			Assert.assertEquals("Injection points should be satisfied", INJECTION_STRING, testView.injectionPoint);
		}

		[Test]
		public function unmappedPackageShouldNotBeInjected():void
		{
			viewMap.mapPackage('org.robotlegs');
			viewMap.unmapPackage('org.robotlegs');
			testView = new StarlingSpriteComponent();
			contextView.addChild(testView);
			Assert.assertNull("Injection points should NOT be satisfied after unmapping", testView.injectionPoint);
		}

		[Test]
		public function mappedPackageNotInjectedTwiceWhenRemovedAndAdded():void
		{
			viewMap.mapPackage('org.robotlegs');
			contextView.addChild(testView);
			testView.injectionPoint = null;
			contextView.removeChild(testView);
			contextView.addChild(testView);
			Assert.assertNull("View should NOT be injected into twice", testView.injectionPoint);
		}

		[Test]
		public function mapInterface():void
		{
			viewMap.mapType(ITestComponent);
			var mapped:Boolean = viewMap.hasType(ITestComponent);
			Assert.assertTrue("Inteface should be mapped", mapped);
		}

		[Test]
		public function unmapInterface():void
		{
			viewMap.mapType(ITestComponent);
			viewMap.unmapType(ITestComponent);
			var mapped:Boolean = viewMap.hasType(ITestComponent);
			Assert.assertFalse("Class should NOT be mapped", mapped);
		}

		[Test]
		public function mappedInterfaceIsInjected():void
		{
			viewMap.mapType(ITestComponent);
			contextView.addChild(testView);
			Assert.assertEquals("Injection points should be satisfied", INJECTION_STRING, testView.injectionPoint);
		}

		[Test]
		public function unmappedInterfaceShouldNotBeInjected():void
		{
			viewMap.mapType(ITestComponent);
			viewMap.unmapType(ITestComponent);
			testView = new StarlingSpriteComponent();
			contextView.addChild(testView);
			Assert.assertNull("Injection points should NOT be satisfied after unmapping", testView.injectionPoint);
		}

		[Test]
		public function mappedInterfaceNotInjectedTwiceWhenRemovedAndAdded():void
		{
			viewMap.mapType(ITestComponent);
			contextView.addChild(testView);
			testView.injectionPoint = null;
			contextView.removeChild(testView);
			contextView.addChild(testView);
			Assert.assertNull("View should NOT be injected into twice", testView.injectionPoint);
		}
	}
}
