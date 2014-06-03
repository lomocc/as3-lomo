package cc.lomo.managers
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import cc.lomo.interfaces.IAnimatedObject;
	import cc.lomo.interfaces.IPrioritizable;
	import cc.lomo.interfaces.IQueuedObject;
	import cc.lomo.interfaces.ITickedObject;
	
	
	/**
	 * The EnterFrameManager manages all time related functionality in the engine.
	 * It provides mechanisms for performing actions every frame, every tick, or
	 * at a specific time in the future.
	 * 
	 * <p>A tick happens at a set interval defined by the TICKS_PER_SECOND constant.
	 * Using ticks for various tasks that need to happen repeatedly instead of
	 * performing those tasks every frame results in much more consistent output.
	 * However, for animation related tasks, frame events should be used so the
	 * display remains smooth.</p>
	 * 
	 * @see ITickedObject
	 * @see IAnimatedObject
	 */
	public class EnterFrameManager
	{
		/**
		 * If true, disables warnings about losing ticks.
		 */
		public static var disableSlowWarning:Boolean = true;
		
		/**
		 * The number of ticks that will happen every second.
		 */
		public static const TICKS_PER_SECOND:int = 30;
		
		/**
		 * The rate at which ticks are fired, in seconds.
		 */
		public static const TICK_RATE:Number = 1.0 / Number(TICKS_PER_SECOND);
		
		/**
		 * The rate at which ticks are fired, in milliseconds.
		 */
		public static const TICK_RATE_MS:Number = TICK_RATE * 1000;
		
		/**
		 * The maximum number of ticks that can be processed in a frame.
		 * 
		 * <p>In some cases, a single frame can take an extremely long amount of
		 * time. If several ticks then need to be processed, a game can
		 * quickly get in a state where it has so many ticks to process
		 * it can never catch up. This is known as a death spiral.</p>
		 * 
		 * <p>To prevent this we have a safety limit. Time is dropped so the
		 * system can catch up in extraordinary cases. If your game is just
		 * slow, then you will see that the EnterFrameManager can never catch up
		 * and you will constantly get the "too many ticks per frame" warning,
		 * if you have disableSlowWarning set to false.</p>
		 */
		public static const MAX_TICKS_PER_FRAME:int = 5;
		
		/**
		 * The scale at which time advances. If this is set to 2, the game
		 * will play twice as fast. A value of 0.5 will run the
		 * game at half speed. A value of 1 is normal.
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}
		
		/**
		 * @private
		 */
		public function set timeScale(value:Number):void
		{
			_timeScale = value;
		}
		
		/**
		 * TweenMax uses timeScale as a config property, so by also having a
		 * capitalized version, we can tween TimeScale instead and get along 
		 * just fine.
		 */
		public function set TimeScale(value:Number):void
		{
			timeScale = value;
		}
		
		/**
		 * @private
		 */ 
		public function get TimeScale():Number
		{
			return timeScale;
		}
		
		/**
		 * Used to determine how far we are between ticks. 0.0 at the start of a tick, and
		 * 1.0 at the end. Useful for smoothly interpolating visual elements.
		 */
		public function get interpolationFactor():Number
		{
			return _interpolationFactor;
		}
		
		/**
		 * The amount of time that has been processed by the EnterFrameManager. This does
		 * take the time scale into account. Time is in milliseconds.
		 */
		public function get virtualTime():Number
		{
			return _virtualTime;
		}
		
		/**
		 * Current time reported by getTimer(), updated every frame. Use this to avoid
		 * costly calls to getTimer(), or if you want a unique number representing the
		 * current frame.
		 */
		public function get platformTime():Number
		{
			return _platformTime;
		}
		
		
		
		/**
		 * Returns true if the EnterFrameManager is advancing.
		 */ 
		public function get isTicking():Boolean
		{
			return started;
		}
		
		/**
		 * Schedules a function to be called at a specified time in the future.
		 * 
		 * @param delay The number of milliseconds in the future to call the function.
		 * @param thisObject The object on which the function should be called. This
		 * becomes the 'this' variable in the function.
		 * @param callback The function to call.
		 * @param arguments The arguments to pass to the function when it is called.
		 */
		public function schedule(delay:Number, thisObject:Object, callback:Function, ...arguments):void
		{
			if (!started)
				start();
			
			var schedule:ScheduleObject = new ScheduleObject();
			schedule.dueTime = _virtualTime + delay;
			schedule.thisObject = thisObject;
			schedule.callback = callback;
			schedule.arguments = arguments;
			
			thinkHeap.enqueue(schedule);
		}
		
		/**
		 * Registers an object to receive frame callbacks.
		 * 
		 * @param object The object to add.
		 * @param priority The priority of the object. Objects added with higher priorities
		 * will receive their callback before objects with lower priorities. The highest
		 * (first-processed) priority is Number.MAX_VALUE. The lowest (last-processed) 
		 * priority is -Number.MAX_VALUE.
		 */
		public function addAnimatedObject(object:IAnimatedObject, priority:Number = 0.0):void
		{
			addObject(object, priority, animatedObjects);
		}
		
		/**
		 * Registers an object to receive tick callbacks.
		 * 
		 * @param object The object to add.
		 * @param priority The priority of the object. Objects added with higher priorities
		 * will receive their callback before objects with lower priorities. The highest
		 * (first-processed) priority is Number.MAX_VALUE. The lowest (last-processed) 
		 * priority is -Number.MAX_VALUE.
		 */
		public function addTickedObject(object:ITickedObject, priority:Number = 0.0):void
		{
			addObject(object, priority, tickedObjects);
		}
		
		/**
		 * Queue an IQueuedObject for callback. This is a very cheap way to have a callback
		 * happen on an object. If an object is queued when it is already in the queue, it
		 * is removed, then added.
		 */
		public function queueObject(object:IQueuedObject):void
		{
			// Assert if this is in the past.
			if(object.nextThinkTime < _virtualTime)
				throw new Error("Tried to queue something into the past, but no flux capacitor is present!");
			
			////////Profiler.enter("queueObject");
			
			if(object.nextThinkTime >= _virtualTime && thinkHeap.contains(object))
				thinkHeap.remove(object);
			
			thinkHeap.enqueue(object);
			
			/////////Profiler.exit("queueObject");
		}
		
		/**
		 * Unregisters an object from receiving frame callbacks.
		 * 
		 * @param object The object to remove.
		 */
		public function removeAnimatedObject(object:IAnimatedObject):void
		{
			removeObject(object, animatedObjects);
		}
		
		/**
		 * Unregisters an object from receiving tick callbacks.
		 * 
		 * @param object The object to remove.
		 */
		public function removeTickedObject(object:ITickedObject):void
		{
			removeObject(object, tickedObjects);
		}
		
		/**
		 * Forces the EnterFrameManager to advance by the specified amount. This should
		 * only be used for unit testing.
		 * 
		 * @param amount The amount of time to simulate.
		 */
		public function testAdvance(amount:Number):void
		{
			advance(amount * _timeScale, true);
		}
		
		/**
		 * Forces the EnterFrameManager to seek its virtualTime by the specified amount.
		 * This moves virtualTime without calling advance and without processing ticks or frames.
		 * WARNING: USE WITH CAUTION AND ONLY IF YOU REALLY KNOW THE CONSEQUENCES!
		 */
		public function seek(amount:Number):void
		{
			_virtualTime += amount;
		}
		
		/**
		 * Deferred function callback - called back at start of processing for next frame. Useful
		 * any time you are going to do setTimeout(someFunc, 1) - it's a lot cheaper to do it 
		 * this way.
		 * @param method Function to call.
		 * @param args Any arguments.
		 */
		public function callLater(method:Function, args:Array = null):void
		{
			var dm:DeferredMethod = new DeferredMethod();
			dm.method = method;
			dm.args = args;
			deferredMethodQueue.push(dm);
		}
		
		/**
		 * @return How many objects are depending on the EnterFrameManager right now?
		 */
		private function get listenerCount():int
		{
			return tickedObjects.length + animatedObjects.length;
		}
		
		/**
		 * Internal function add an object to a list with a given priority.
		 * @param object Object to add.
		 * @param priority Priority; this is used to keep the list ordered.
		 * @param list List to add to.
		 */
		private function addObject(object:*, priority:Number, list:Array):void
		{
			// If we are in a tick, defer the add.
			if(duringAdvance)
			{
				callLater(addObject, [ object, priority, list]);
				return;
			}
			
			if (!started)
				start();
			
			var position:int = -1;
			
			var processObject:ProcessObject;
			
			for each (processObject in list) 
			{
				if (processObject && processObject.listener == object)
				{
					return;
				}
			}
			
			for (var i:int = 0; i < list.length; i++)
			{
				if(!list[i])
					continue;
				if (list[i].priority < priority)
				{
					position = i;
					break;
				}
			}
			
			processObject = new ProcessObject();
			processObject.listener = object;
			processObject.priority = priority;
			/////////processObject.profilerKey = TypeUtility.getObjectClassName(object);
			
			if (position < 0 || position >= list.length)
				list.push(processObject);
			else
				list.splice(position, 0, processObject);
		}
		
		/**
		 * Peer to addObject; removes an object from a list. 
		 * @param object Object to remove.
		 * @param list List from which to remove.
		 */
		private function removeObject(object:*, list:Array):void
		{
			
			for (var i:int = 0; i < list.length; i++)
			{
				if(!list[i])
					continue;
				
				if (list[i].listener == object)
				{
					//trace(duringAdvance,i,object);
					if(duringAdvance)
					{
						list[i] = null;
						needPurgeEmpty = true;
					}
					else
					{
						list.splice(i, 1);                        
					}
					
					break;
				}
			}
			
			if (listenerCount == 0 && thinkHeap.size == 0) stop();
			
			//Logger.log(object, "This object has not been added to the EnterFrameManager.");
		}
		
		/**
		 * Main callback; this is called every frame and allows game logic to run. 
		 */
		private function onFrame(event:Event):void
		{
			// This is called from a system event, so it had better be at the 
			// root of the profiler stack!
			////////Profiler.ensureAtRoot();
			
			// Track current time.
			var currentTime:Number = getTimer();
			if (lastTime < 0)
			{
				lastTime = currentTime;
				return;
			}
			
			// Calculate time since last frame and advance that much.
			var deltaTime:Number = Number(currentTime - lastTime) * _timeScale;
			advance(deltaTime);
			
			// Note new last time.
			lastTime = currentTime;
		}
		
		private function advance(deltaTime:Number, suppressSafety:Boolean = false):void
		{
			// Update platform time, to avoid lots of costly calls to getTimer.
			_platformTime = getTimer();
			
			// Note virtual time we started advancing from.
			//var startTime:Number = _virtualTime;
			
			// Add time to the accumulator.
			elapsed += deltaTime;
			
			// Perform ticks, respecting tick caps.
			var tickCount:int = 0;
			while (elapsed >= TICK_RATE_MS && (suppressSafety || tickCount < MAX_TICKS_PER_FRAME))
			{
				// Ticks always happen on interpolation boundary.
				_interpolationFactor = 0.0;
				
				// Process pending events at this tick.
				// This is done in the loop to ensure the correct order of events.
				processScheduledObjects();
				
				// Do the onTick callbacks, noting time in profiler appropriately.
				/////////Profiler.enter("Tick");
				
				duringAdvance = true;
				for(var j:int=0; j<tickedObjects.length; j++)
				{
					var object:ProcessObject = tickedObjects[j] as ProcessObject;
					if(!object)
						continue;
					
					///////////Profiler.enter(object.profilerKey);
					(object.listener as ITickedObject).onTick(TICK_RATE);
					///////////Profiler.exit(object.profilerKey);
				}
				duringAdvance = false;
				
				/////////Profiler.exit("Tick");
				
				// Update virtual time by subtracting from accumulator.
				_virtualTime += TICK_RATE_MS;
				elapsed -= TICK_RATE_MS;
				tickCount++;
			}
			
			// Safety net - don't do more than a few ticks per frame to avoid death spirals.
			if (tickCount >= MAX_TICKS_PER_FRAME && !suppressSafety && !disableSlowWarning)
			{
				// By default, only show when profiling.
				//Logger.log(this, "Exceeded maximum number of ticks for frame (" + elapsed.toFixed() + "ms dropped) .");
				elapsed = 0;
			}
			
			// Make sure that we don't fall behind too far. This helps correct
			// for short-term drops in framerate as well as the scenario where
			// we are consistently running behind.
			elapsed = clamp(elapsed, 0, 300);            
			
			
			// Make sure we don't lose time to accumulation error.
			// Not sure this gains us anything, so disabling -- BJG
			//_virtualTime = startTime + deltaTime;
			
			// We process scheduled items again after tick processing to ensure between-tick schedules are hit
			// Commenting this out because it can cause too-often calling of callLater methods. -- BJG
			// processScheduledObjects();
			
			// Update objects wanting OnFrame callbacks.
			//////////Profiler.enter("frame");
			duringAdvance = true;
			_interpolationFactor = elapsed / TICK_RATE_MS;
			for(var i:int=0; i<animatedObjects.length; i++)
			{
				var animatedObject:ProcessObject = animatedObjects[i] as ProcessObject;
				if(!animatedObject)
					continue;
				
				/////Profiler.enter(animatedObject.profilerKey);
				//trace(i,animatedObject.listener);
				(animatedObject.listener as IAnimatedObject).onFrame(deltaTime / 1000);
				/////Profiler.exit(animatedObject.profilerKey);
			}
			duringAdvance = false;
			//////Profiler.exit("frame");
			
			// Purge the lists if needed.
			if(needPurgeEmpty)
			{
				needPurgeEmpty = false;
				
				//////Profiler.enter("purgeEmpty");
				
				for(j=0; j<animatedObjects.length; j++)
				{
					if(animatedObjects[j])
						continue;
					
					animatedObjects.splice(j, 1);
					j--;
				}
				
				for(var k:int=0; k<tickedObjects.length; k++)
				{                    
					if(tickedObjects[k])
						continue;
					
					tickedObjects.splice(k, 1);
					k--;
				}
				
				if (listenerCount == 0 && thinkHeap.size == 0) stop();
			}
			
			//////Profiler.ensureAtRoot();
		}
		
		/**
		 * Keep a number between a min and a max.
		 */
		public static function clamp(v:Number, min:Number = 0, max:Number = 1):Number
		{
			if(v < min) return min;
			if(v > max) return max;
			return v;
		}
		
		private function processScheduledObjects():void
		{
			// Do any deferred methods.
			var oldDeferredMethodQueue:Array = deferredMethodQueue;
			if(oldDeferredMethodQueue.length)
			{
				////////Profiler.enter("callLater");
				
				// Put a new array in the queue to avoid getting into corrupted
				// state due to more calls being added.
				deferredMethodQueue = [];
				
				for(var j:int=0; j<oldDeferredMethodQueue.length; j++)
				{
					var curDM:DeferredMethod = oldDeferredMethodQueue[j] as DeferredMethod;
					curDM.method.apply(null, curDM.args);
				}
				
				// Wipe the old array now we're done with it.
				oldDeferredMethodQueue.length = 0;
				
				///////////Profiler.exit("callLater");      	
			}
			
			// Process any queued items.
			if(thinkHeap.size)
			{
				///////Profiler.enter("Queue");
				
				while(thinkHeap.front && thinkHeap.front.priority >= -_virtualTime)
				{
					var itemRaw:IPrioritizable = thinkHeap.dequeue();
					var qItem:IQueuedObject = itemRaw as IQueuedObject;
					var sItem:ScheduleObject = itemRaw as ScheduleObject;
					
					///var type:String = TypeUtility.getObjectClassName(itemRaw);
					
					///////Profiler.enter(type);
					if(qItem)
					{
						// Check here to avoid else block that throws an error - empty callback
						// means it unregistered.
						if(qItem.nextThinkCallback != null)
							qItem.nextThinkCallback();
					}
					else if(sItem && sItem.callback != null)
					{
						sItem.callback.apply(sItem.thisObject, sItem.arguments);                    
					}
					else
					{
						throw new Error("Unknown type found in thinkHeap.");
					}
					//////////Profiler.exit(type);                    
					
				}
				
				/////Profiler.exit("Queue");                
			}
		}
		
		private var deferredMethodQueue:Array = [];
		private var started:Boolean = false;
		private var _virtualTime:int = 0.0;
		private var _interpolationFactor:Number = 0.0;
		private var _timeScale:Number = 1.0;
		private var lastTime:int = -1.0;
		private var elapsed:Number = 0.0;
		private var animatedObjects:Array = new Array();
		private var tickedObjects:Array = new Array();
		private var needPurgeEmpty:Boolean = false;
		
		private var _platformTime:int = 0;
		
		private var duringAdvance:Boolean = false;
		
		private var thinkHeap:SimplePriorityQueue = new SimplePriorityQueue(1024);
		
		
		/**
		 * 单例 
		 */		
		private static var _instance:EnterFrameManager;
		
		public static function getInstance():EnterFrameManager{
			if(_instance==null) _instance=new EnterFrameManager(new SingletonEnforcer);
			return _instance;
		}
		
		public function EnterFrameManager(pvt:SingletonEnforcer){
			start();
		}
		
		
		private var _shape:Shape=new Shape();
		
		/**
		 * Starts the EnterFrameManager. This is automatically called when the first object
		 * is added to the EnterFrameManager. If the manager is stopped manually, then this
		 * will have to be called to restart it.
		 */
		public function start():void
		{
			if (started)
			{
				return;
			}
			
			lastTime = -1.0;
			elapsed = 0.0;
			_shape.addEventListener(Event.ENTER_FRAME, onFrame);
			started = true;
		}
		
		/**
		 * Stops the EnterFrameManager. This is automatically called when the last object
		 * is removed from the EnterFrameManager, but can also be called manually to, for
		 * example, pause the game.
		 */
		public function stop():void
		{
			if (!started)
			{
				return;
			}
			
			started = false;
			_shape.removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		
	}
	
}

import flash.utils.Dictionary;

import cc.lomo.interfaces.IPrioritizable;

final class ProcessObject
{
	///////public var profilerKey:String = null;
	public var listener:* = null;
	public var priority:Number = 0.0;
}

final class DeferredMethod
{
	public var method:Function = null;;
	public var args:Array = null;
}

internal final class ScheduleObject implements IPrioritizable
{
	public var dueTime:Number = 0.0;
	public var thisObject:Object = null;
	public var callback:Function = null;
	public var arguments:Array = null;
	
	public function get priority():int
	{
		return -dueTime;
	}
	
	public function set priority(value:int):void
	{
		throw new Error("Unimplemented.");
	}
}




internal final  class SimplePriorityQueue
{
	private var _heap:Array;
	private var _size:int;
	private var _count:int;
	private var _posLookup:Dictionary;
	
	/**
	 * Initializes a priority queue with a given size.
	 * 
	 * @param size The size of the priority queue.
	 */
	public function SimplePriorityQueue(size:int)
	{
		_heap = new Array(_size = size + 1);
		_posLookup = new Dictionary(true);
		_count = 0;
	}
	
	/**
	 * The front item or null if the heap is empty.
	 */
	public function get front():IPrioritizable
	{
		return _heap[1];
	}
	
	/**
	 * The maximum capacity.
	 */
	public function get maxSize():int
	{
		return _size;
	}
	
	/**
	 * Enqueues a prioritized item.
	 * 
	 * @param obj The prioritized data.
	 * @return False if the queue is full, otherwise true.
	 */
	public function enqueue(obj:IPrioritizable):Boolean
	{
		if (_count + 1 < _size)
		{
			_count++;
			_heap[_count] = obj;
			_posLookup[obj] = _count;
			walkUp(_count);
			return true;
		}
		return false;
	}
	
	/**
	 * Dequeues and returns the front item.
	 * This is always the item with the highest priority.
	 * 
	 * @return The queue's front item or null if the heap is empty.
	 */
	public function dequeue():IPrioritizable
	{
		if (_count >= 1)
		{
			var o:* = _heap[1];
			delete _posLookup[o];
			
			_heap[1] = _heap[_count];
			walkDown(1);
			
			delete _heap[_count];
			_count--;
			return o;
		}
		return null;
	}
	
	/**
	 * Reprioritizes an item.
	 * 
	 * @param obj         The object whose priority is changed.
	 * @param newPriority The new priority.
	 * @return True if the repriorization succeeded, otherwise false.
	 */
	public function reprioritize(obj:IPrioritizable, newPriority:int):Boolean
	{
		if (!_posLookup[obj]) return false;
		
		var oldPriority:int = obj.priority;
		obj.priority = newPriority;
		var pos:int = _posLookup[obj];
		newPriority > oldPriority ? walkUp(pos) : walkDown(pos);
		return true;
	}
	
	/**
	 * Removes an item.
	 * 
	 * @param obj The item to remove.
	 * @return True if removal succeeded, otherwise false.
	 */
	public function remove(obj:IPrioritizable):Boolean
	{
		if (_count >= 1)
		{
			var pos:int = _posLookup[obj];
			
			var o:* = _heap[pos];
			delete _posLookup[o];
			
			_heap[pos] = _heap[_count];
			
			walkDown(pos);
			
			delete _heap[_count];
			delete _posLookup[_count];
			_count--;
			return true;
		}
		
		return false;
	}
	
	/**
	 * @inheritDoc
	 */
	public function contains(obj:*):Boolean
	{
		for (var i:int = 1; i <= _count; i++)
		{
			if (_heap[i] === obj)
				return true;
		}
		return false;
	}
	
	/**
	 * @inheritDoc
	 */
	public function clear():void
	{
		_heap = new Array(_size);
		_posLookup = new Dictionary(true);
		_count = 0;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get size():int
	{
		return _count;
	}
	
	/**
	 * @inheritDoc
	 */
	public function isEmpty():Boolean
	{
		return _count == 0;
	}
	
	/**
	 * @inheritDoc
	 */
	public function toArray():Array
	{
		return _heap.slice(1, _count + 1);
	}
	
	/**
	 * Prints out a string representing the current object.
	 * 
	 * @return A string representing the current object.
	 */
	public function toString():String
	{
		return "[SimplePriorityQueue, size=" + _size +"]";
	}
	
	/**
	 * Prints all elements (for debug/demo purposes only).
	 */
	public function dump():String
	{
		if (_count == 0) return "SimplePriorityQueue (empty)";
		
		var s:String = "SimplePriorityQueue\n{\n";
		var k:int = _count + 1;
		for (var i:int = 1; i < k; i++)
		{
			s += "\t" + _heap[i] + "\n";
		}
		s += "\n}";
		return s;
	}
	
	private function walkUp(index:int):void
	{
		var parent:int = index >> 1;
		var parentObj:IPrioritizable;
		
		var tmp:IPrioritizable = _heap[index];
		var p:int = tmp.priority;
		
		while (parent > 0)
		{
			parentObj = _heap[parent];
			
			if (p - parentObj.priority > 0)
			{
				_heap[index] = parentObj;
				_posLookup[parentObj] = index;
				
				index = parent;
				parent >>= 1;
			}
			else break;
		}
		
		_heap[index] = tmp;
		_posLookup[tmp] = index;
	}
	
	private function walkDown(index:int):void
	{
		var child:int = index << 1;
		var childObj:IPrioritizable;
		
		var tmp:IPrioritizable = _heap[index];
		var p:int = tmp.priority;
		
		while (child < _count)
		{
			if (child < _count - 1)
			{
				if (_heap[child].priority - _heap[int(child + 1)].priority < 0)
					child++;
			}
			
			childObj = _heap[child];
			
			if (p - childObj.priority < 0)
			{
				_heap[index] = childObj;
				_posLookup[childObj] = index;
				
				_posLookup[tmp] = child;
				
				index = child;
				child <<= 1;
			}
			else break;
		}
		_heap[index] = tmp;
		_posLookup[tmp] = index;
	}
}