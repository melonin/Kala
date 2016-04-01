package kala.math;

import kala.math.helpers.AngleHelper;
import kha.FastFloat;

class Rotation {
	
	public var px:FastFloat;
	public var py:FastFloat;
	public var angle:FastFloat;
	
	public inline function new(angle:FastFloat = 0, pivotX:FastFloat = 0, pivotY:FastFloat = 0) {
		this.angle = angle;
		this.px = pivotX;
		this.py = pivotY;
	}
	
	@:extern
	public inline function set(angle:FastFloat = 0, pivotX:FastFloat = 0, pivotY:FastFloat = 0):Rotation {
		this.angle = angle;
		this.px = pivotX;
		this.py = pivotY;
		
		return this;
	}
	
	@:extern
	public inline function setPivot(pivotX:FastFloat = 0, pivotY:FastFloat = 0):Rotation {
		this.px = pivotX;
		this.py = pivotY;
		
		return this;
	}
	
	@:extern
	public inline function setRad(rad:FastFloat):Rotation {
		angle = rad * AngleHelper.CONST_DEG;
		return this;
	}
	
	@:extern
	public inline function rad():FastFloat {
		return angle * AngleHelper.CONST_RAD;
	}
	
	@:extern
	public inline function setDeg(deg:FastFloat):Rotation {
		angle = deg * AngleHelper.CONST_RAD;
		return this;
	}
	
	@:extern
	public inline function deg():FastFloat {
		return angle * AngleHelper.CONST_DEG;
	}
	
}