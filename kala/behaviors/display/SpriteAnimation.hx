package kala.behaviors.display;

import haxe.ds.StringMap;
import kala.EventHandle.CallbackHandle;
import kala.math.Rect.RectI;
import kala.objects.Object;
import kala.objects.sprite.Sprite;
import kha.FastFloat;
import kha.Image;

/**
 * Used with sprite-sheets to play animation on a sprite object.
 */
@:access(kala.objects.sprite.Sprite)
class SpriteAnimation extends Behavior<Sprite> {

	public var animations(default, null):StringMap<SpriteAnimationData> = new StringMap<SpriteAnimationData>();
	
	public var anim(default, null):SpriteAnimationData;
	public var frame(default, set):Int;
	public var delay(default, set):FastFloat;
	public var reversed:Bool;
	
	public var timeLeft:FastFloat;
	
	public var onAnimComplete(default, null):CallbackHandle<SpriteAnimation->Void>;
	
	private var _lastAddedKey:String;
	
	public function new(?sprite:Sprite) {
		super(null);
		onAnimComplete = addCBHandle(new CallbackHandle<SpriteAnimation->Void>());
		if (sprite != null) addTo(sprite);
	}
	
	override public function reset():Void {
		super.reset();
		removeAllAnimations();
		anim = null;
		timeLeft = 0;
	}
	
	override public function destroy():Void {
		super.destroy();
		
		anim = null;
		
		removeAllAnimations();
		animations = null;
		
		destroyCBHandles();
		onAnimComplete = null;
	}
	
	override public function addTo(object:Sprite):SpriteAnimation {
		super.addTo(object);
		
		object.onPostUpdate.notifyPrivateCB(this, update);
		object.animation = this;
		
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			object.onPostUpdate.removePrivateCB(this, update);
			object.animation = null;
		}
		
		super.remove();
	}
	
	/**
	 * Play an animation.
	 * 
	 * @param	key				The key used to add the animation.
	 * @param	delay			Delay time between frames. Left null to use the current setting.
	 * @param	reversed		Whether to play the animation in reverse or not.
	 * @param	forceReplay		Whether to force replay the animation if it is already playing with the same settings.
	 * 
	 * @return 					This behavior.
	 */
	public function play(?key:String, ?delay:UInt, reversed:Bool = false, forceReplay:Bool = false):SpriteAnimation {
		if (key == null) {
			if (_lastAddedKey == null) return null;
			key = _lastAddedKey;
		}
		
		if (
			anim != null && key == anim.key && !forceReplay &&
			(delay == null || delay == this.delay) &&
			reversed == this.reversed
		) {
			return this;
		}
		
		anim = animations.get(key);
		
		if (anim != null) {
			this.delay = timeLeft = (delay == null) ? anim.delay : delay;
			this.reversed = reversed;
			frame = reversed ? anim.frames.length - 1 : 0; 
			if (anim.image != null) object.image = anim.image;
		} else {
			return null;
		}
		
		return this;
	}
	
	public inline function pause():Void {
		delay = -1;
	}
	
	/**
	 * Add a new animation.
	 * 
	 * @param	key				Key used to access animation.
	 * @param	image			Source image contains sprite sheet. If set to null, will use the current image of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is null and the behavior wasn't added to a sprite or the sprite image is null, this method will do nothing and return null.
	 * @param	sheetX			X position of sprite sheet. If set to smaller than 0, will use the current frame x of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to smaller than 0 and the behavior wasn't added to a sprite, this method will do nothing and return null.
	 * @param	sheetY			Y position of sprite sheet. If set to smaller than 0, will use the current frame y of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to to smaller than 0 and the behavior wasn't added to a sprite, this method will do nothing and return null.
	 * @param	frameWidth		Frame width. If set to 0, will use the current frame width of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to 0 and the behavior wasn't added to a sprite, this method will do nothing and return null.
	 * @param	frameHeight		Frame height. If set to 0, will use the current frame height of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to 0 and the behavior wasn't added to a sprite, this method will do nothing and return null.
	 * @param	totalFrames		Total number of frames in sprite sheet.
	 * @param	framesPerRow	Number of frames per row. (Last row may have less frames.)
	 * @param	delay			Delay time between frames. In seconds if Kala.deltaTiming is set to true otherwise in frames.
	 * 
	 * @return					Return this behavior if success otherwise return null.
	 */
	public function addAnim(
		key:String,
		?image:Image,
		sheetX:Int, sheetY:Int, frameWidth:UInt, frameHeight:UInt,
		totalFrames:UInt,
		framesPerRow:UInt,
		delay:UInt
	):SpriteAnimation {
		if (
			(image == null && (object == null || object.image == null)) ||
			(object == null && (sheetX < 0 || sheetY < 0 || frameWidth == 0 || frameHeight == 0))
		) {
			return null;
		}
		
		if (image == null) image = object.image;
		else object.image = image;
		
		if (sheetX < 0) sheetX = object.frameRect.x;
		else object.frameRect.x = sheetX;
		
		if (sheetY < 0) sheetY = object.frameRect.y;
		else object.frameRect.y = sheetY;
		
		if (frameWidth == 0) frameWidth = object.frameRect.width;
		else object.frameRect.width = frameWidth;
		
		if (frameHeight == 0) frameHeight = object.frameRect.height;
		else object.frameRect.height = frameHeight;
		
		var anim = new SpriteAnimationData(key, image, delay);
		
		var col:UInt = 0;
		var row = 0;
		for (i in 0...totalFrames) {
			anim.addFrame(sheetX + frameWidth * col, sheetY + frameHeight * row, frameWidth, frameHeight);
			
			col++;
			
			if (col == framesPerRow) {
				col = 0;
				row++;
			}
		}
		
		animations.set(key, anim);
		_lastAddedKey = key;
		
		return this;
	}
	
	public function addAnimFromSpriteData(?key:String, ?image:Image, data:SpriteData, delay:Int):SpriteAnimation {
		if (key == null) key = data.key;
		
		if (image == null) {
			if (data.image == null) {
				image = object.image;
			} else {
				image = data.image;
			}
		}
			
		object.image = image;
		object.frameRect.copy(data.frames[0]);
		
		var anim = new SpriteAnimationData(key, image, delay);
		
		for (frame in data.frames) {
			anim.addFrameRect(frame);
		}
		
		animations.set(key, anim);
		_lastAddedKey = key;
		
		return this;
	}
	
	public function removeAnim(key:String):SpriteAnimation {
		animations.remove(key);
		if (_lastAddedKey == key) _lastAddedKey = null;
		
		return this;
	}
	
	public function getAnimations():Array<SpriteAnimationData> {
		var array = new Array<SpriteAnimationData>();
		for (key in animations.keys()) {
			array.push(animations.get(key));
		}
		return array;
	}
	
	public function removeAllAnimations():Void {
		for (key in animations.keys()) animations.remove(key);
	}
	
	function update(obj:Object, elapsed:FastFloat):Void {
		if (anim != null && delay > -1) {
			timeLeft -= elapsed;
			
			if (timeLeft <= 0) {
				timeLeft = delay;
				
				if (!reversed) {
					if (frame < anim.frames.length - 1) {
						frame++;
					} else {
						frame = 0;
						for (callback in onAnimComplete) callback.cbFunction(this);
					}
				} else {
					if (frame > 0) {
						frame--;
					} else {
						frame = anim.frames.length - 1;
						for (callback in onAnimComplete) callback.cbFunction(this);
					}
				}

			}
		}
	}
	
	inline function set_frame(value:Int):Int {
		object.frameRect.copy(anim.frames[frame = value]);
		return value;
	}
	
	inline function set_delay(value:FastFloat):FastFloat {
		if (value > -1 && timeLeft > value) timeLeft = value;
		return delay = value;
	}

}

class SpriteAnimationData {
	
	public var key(default, null):String;
	public var image:Image;
	public var frames:Array<RectI>;
	public var delay:FastFloat;
	
	public inline function new(key:String, image:Image, delay:UInt) {
		this.key = key;
		this.image = image;
		this.delay = delay;
		
		frames = new Array<RectI>();
	}

	@:extern
	public inline function addFrame(x:UInt, y:UInt, width:UInt, height:UInt):SpriteAnimationData {
		frames.push(new RectI(x, y, width, height));
		return this;
	}
	
	@:extern
	public inline function addFrameRect(rect:RectI):SpriteAnimationData {
		frames.push(rect.clone());
		return this;
	}
	
	@:extern
	public inline function removeFrame(index:Int):SpriteAnimationData {
		frames.splice(index, 1);
		return this;
	}
	
}