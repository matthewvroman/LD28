package com.ld48 
{
	/**
	 * ...
	 * @author Matt
	 */
	public class GameManager 
	{
		private static var _instance:GameManager;
		public static function get instance():GameManager { return _instance; }
		
		public static var TOTAL_NUM_PRESENTS:int = 8;
		
		private static var NUM_STARTING_XRAYS:int = 3;
		private static var NUM_STARTING_SHAKES:int = 3;
		private static var NUM_STARTING_WEIGHS:int = 3;
		private static var NUM_STARTING_HINTS:int = 3;
		
		private var _numXRaysLeft:int;
		public function get numXRaysLeft():int { return _numXRaysLeft; }
		private var _numShakesLeft:int;
		public function get numShakesLeft():int { return _numShakesLeft; }
		private var _numWeighsLeft:int;
		public function get numWeighsLeft():int { return _numWeighsLeft; }
		private var _numHintsLeft:int;
		public function get numHintsLeft():int { return _numHintsLeft; }
		
		private var _presents:Vector.<Present>;
		private var _openedPresents:Vector.<Present>;
		
		public function get numPresentsOpened():int { return _openedPresents.length; }
		
		private var _currentDesiredToy:String = "";
		public function get currentDesiredToy():String { return _currentDesiredToy; }
		
		private var availableToys:Vector.<Toy>;
		private var currentToys:Vector.<Toy>;
		private static var MAX_NUM_TOYS_PER_TYPE:int = 3;
		
		public function GameManager() 
		{
			if (_instance != null)
			{
				trace("WARNING! An instance of Game Manager already exists");
			}
			else
			{
				_instance = this;
			}
			
			init();
		}
		
		private function init():void
		{
			GameEventDispatcher.addEventListener(GameEvent.USED_XRAY,onXRayUsed);
			GameEventDispatcher.addEventListener(GameEvent.USED_SHAKE, onShakeUsed);
			GameEventDispatcher.addEventListener(GameEvent.USED_WEIGH, onWeighUsed);
			GameEventDispatcher.addEventListener(GameEvent.USED_HINT, onHintUsed);
			GameEventDispatcher.addEventListener(GameEvent.PRESENT_OPENED, onPresentOpened);
			
			resetGameplay();
		}
		
		public function resetGameplay():void
		{
			availableToys = null;
			availableToys = new Vector.<Toy>();
			availableToys.push(new Toy("StuffedAnimal", Present.TYPE_SMALL,45));
			availableToys.push(new Toy("Fedora", Present.TYPE_SMALL,65));
			availableToys.push(new Toy("Underwear", Present.TYPE_SMALL,35));
			availableToys.push(new Toy("BowlingBall", Present.TYPE_SMALL,345));
			availableToys.push(new Toy("ElectricKeyboard", Present.TYPE_LONG,270));
			availableToys.push(new Toy("LegoBox", Present.TYPE_LONG,245));
			availableToys.push(new Toy("BongoDrums", Present.TYPE_LONG,200));
			availableToys.push(new Toy("ChristmasSweater", Present.TYPE_LONG,75));
			availableToys.push(new Toy("BaseballBat", Present.TYPE_TALL,145));
			availableToys.push(new Toy("Umbrella", Present.TYPE_TALL,110));
			availableToys.push(new Toy("Skateboard", Present.TYPE_TALL,230));
			availableToys.push(new Toy("Rainstick", Present.TYPE_TALL,75));
			
			_presents = null;
			_presents = new Vector.<Present>();
			
			for (var i:int = 0; i < TOTAL_NUM_PRESENTS; i++)
			{
				var type:String = GameManager.instance.getControlledRandomPresentClass();
				var color:String = GameManager.instance.getControlledRandomColorForType(type);
				var toy:Toy = getRandomToyForType(type);
				var present:Present = new Present(type, color, toy.name, i);
				present.weighRotation = toy.weighRotationAmount;
				availableToys.splice(availableToys.indexOf(toy), 1);
				addPresent(present);
			}
			
			_currentDesiredToy = getRandomUnopenedToy();
			
			_openedPresents = null;
			_openedPresents = new Vector.<Present>();
			
			_numXRaysLeft=NUM_STARTING_XRAYS;
			_numShakesLeft=NUM_STARTING_SHAKES;
			_numWeighsLeft=NUM_STARTING_WEIGHS;
			_numHintsLeft=NUM_STARTING_HINTS;
		}
		
		private function onXRayUsed(e:GameEvent):void
		{
			_numXRaysLeft--;
		}
		
		private function onShakeUsed(e:GameEvent):void
		{
			_numShakesLeft--;
		}
		
		private function onWeighUsed(e:GameEvent):void
		{
			_numWeighsLeft--;
		}
		
		private function onHintUsed(e:GameEvent):void
		{
			_numHintsLeft--;
		}
		
		private function onPresentOpened(e:GameEvent):void
		{
			var present:Present = e.data as Present;
			present.isOpened = true;
			_presents.splice(_presents.indexOf(present), 1);
			_openedPresents.push(present);
			
			if(_presents.length>0)
				_currentDesiredToy = getRandomUnopenedToy();
			else
				trace("game win!");
		}
		
		public function getControlledRandomColorForType(type:String):String
		{
			var redAvailable:Boolean = shouldColorStillBeChosenForType(type, Present.COLOR_RED);
			var blueAvailable:Boolean = shouldColorStillBeChosenForType(type, Present.COLOR_BLUE);
			var greenAvailable:Boolean = shouldColorStillBeChosenForType(type, Present.COLOR_GREEN);
			var yellowAvailable:Boolean = shouldColorStillBeChosenForType(type, Present.COLOR_YELLOW);
			
			var colors:Vector.<String> = new Vector.<String>();
			if (redAvailable)
				colors.push(Present.COLOR_RED);
			if (blueAvailable)
				colors.push(Present.COLOR_BLUE);
			if (greenAvailable)
				colors.push(Present.COLOR_GREEN);
			if (yellowAvailable)
				colors.push(Present.COLOR_YELLOW);
				
			return colors[MathHelper.RandomInt(0, colors.length - 1)];
		}
		
		public function getControlledRandomPresentClass():String
		{
			var smallAvailable:Boolean = shouldTypeStillBeChosen(Present.TYPE_SMALL);
			var longAvailable:Boolean = shouldTypeStillBeChosen(Present.TYPE_LONG);
			var tallAvailalbe:Boolean = shouldTypeStillBeChosen(Present.TYPE_TALL);
			
			var types:Vector.<String> = new Vector.<String>();
			if(tallAvailalbe)
				types.push(Present.TYPE_TALL);
			if(longAvailable)
				types.push(Present.TYPE_LONG);
			if(smallAvailable)
				types.push(Present.TYPE_SMALL);
				
			return types[MathHelper.RandomInt(0, types.length - 1)];
		}
		
		public function getRandomPresentClass():String
		{
			var rand:Number = Math.random()*100;
			if(rand<33)
				return Present.TYPE_SMALL;
			if(rand<66)
				return Present.TYPE_LONG;
			return Present.TYPE_TALL;
		}
		
		public function getRandomPresentColor():String
		{
			var rand:Number = Math.random()*100;
			if(rand<25)
				return Present.COLOR_RED;
			if(rand<50)
				return Present.COLOR_GREEN;
			if(rand<75)
				return Present.COLOR_BLUE;
			return Present.COLOR_YELLOW;
		}
		
		public function addPresent(present:Present):void
		{
			_presents.push(present);
		}
		
		public function getAvailablePresentAtIndex(index:int):Present
		{
			for(var i:int=0; i<_presents.length; i++)
			{
				if(_presents[i].holderIndex==index)
				{
					return _presents[i];
				}
			}
			
			return null;
		}
		
		public function getOpenedPresentAtIndex(index:int):Present
		{
			for (var i:int = 0; i < _openedPresents.length; i++)
			{
				if (_openedPresents[i].holderIndex == index)
				{
					return _openedPresents[i];
				}
			}
			
			return null;
		}
		
		public function getNumOfUnopenedPresentsOfType(type:String):int
		{
			var count:int = 0;
			for each(var present:Present in _presents)
			{
				if (present.type == type)
					count++;
			}
			
			return count;
		}
		
		public function getRandomToy():Toy
		{
			return availableToys[MathHelper.RandomInt(0, availableToys.length - 1)];
		}
		
		public function getRandomToyForType(type:String):Toy
		{
			var toys:Vector.<Toy> = new Vector.<Toy>();
			for (var i:int = 0; i < availableToys.length; i++)
			{
				if (availableToys[i].type == type)
				{
					toys.push(availableToys[i]);
				}
			}
			
			return toys[MathHelper.RandomInt(0, toys.length - 1)];
		}
		
		public function shouldTypeStillBeChosen(type:String):Boolean
		{
			return (getNumOfUnopenedPresentsOfType(type) != MAX_NUM_TOYS_PER_TYPE);
		}
		
		public function shouldColorStillBeChosenForType(type:String, color:String):Boolean
		{
			for (var i:int = 0; i < _presents.length; i++)
			{
				if (_presents[i].type == type && _presents[i].color == color)
					return false;
			}
			
			return true;
		}
		
		
		public function getRandomUnopenedToy():String
		{
			return _presents[MathHelper.RandomInt(0, _presents.length - 1)].toy;
		}
		
		public function gameWon():Boolean
		{
			return GameManager.instance.numPresentsOpened == GameManager.TOTAL_NUM_PRESENTS;
		}
	}

}