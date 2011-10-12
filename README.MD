robotlegs-starling-plugin

This plugin adds some classes to Robotlegs to support usage with the Starling framework. Because the Starling framework uses Stage3D and not the flash.display.DisplayList a StarlingContext must be used along with a StarlingMediator. The rest of the framework usage remains the same.

Added Classes
-------------
StarlingMediatorMap.as
StarlingViewMap.as
StarlingViewMapBase.as
IStarlingMediatorMap.as
IStarlingViewMap.as
StarlingContext.as
StarlingMediator.as


Usage Example
-------------
Below are some excerpts from a very simple usage example. The .fxp file for the example file is in the Downloads section. Below are the key parts.

The main class set up remains the same:
	package
	{
		import com.example.MyGame;

		import flash.display.Sprite;
		import flash.events.Event;

		import org.robotlegs.mvcs.StarlingContext;

		import starling.core.Starling;

		public class Main extends Sprite
		{
			private var _starling:Starling;
			private var _starlingContext:StarlingContext;

			public function Main()
			{
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}

			protected function onAddedToStage(event:Event):void
			{
				_starling = new Starling(MyGame, stage);
				_starling.start();
			}
		}
	}


Inside the main Starling class (MyGame) sent into the first Starling constructor argument start a subclass of a StarlingContext instance. Usage of the StarlingContext is identical to the default Robotlegs Context class.
	package com.example
	{
		import flash.utils.setTimeout;

		import org.robotlegs.mvcs.StarlingContext;

		import starling.display.Sprite;
		import starling.events.Event;

		public class MyGame extends Sprite
		{
			private var _starlingContext:StarlingContext;

			public function MyGame()
			{
				super();

				_starlingContext = new MyStarlingGameContext(this);

				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}

			private function onAddedToStage(event:Event):void
			{
				var secondView:SecondView = new SecondView();
				addChild(secondView);

				// Test mediator removal
				setTimeout(secondView.parent.removeChild, 3000, secondView);
			}
		}
	}

Contents of the MyStarlingGameContext class (StarlingContext subclass):
	package com.example
	{
		import org.robotlegs.mvcs.StarlingContext;

		import starling.display.DisplayObjectContainer;

		public class MyStarlingGameContext extends StarlingContext
		{
			public function MyStarlingGameContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
			{
				super(contextView, autoStartup);
			}

			override public function startup():void
			{
				mediatorMap.mapView(MyGame, MyGameMediator);
				mediatorMap.mapView(SecondView, SecondViewMediator);

				super.startup();
			}
		}
	}

And finally, the contents of one of the mediators (SecondViewMediator):
	package com.example
	{
		import org.robotlegs.mvcs.StarlingMediator;

		public class SecondViewMediator extends StarlingMediator
		{
			public function SecondViewMediator()
			{
				super();
			}

			override public function onRegister():void
			{
				trace("SecondViewMediator.onRegister()");
			}

			override public function onRemove():void
			{
				trace("SecondViewMediator.onRemove()");
			}
		}
	}
