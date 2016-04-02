package kala.math;

import kha.FastFloat;

class Angle {

	public static var CONST_RAD(default, never):FastFloat = Math.PI / 180; 
	public static var CONST_DEG(default, never):FastFloat = 180 / Math.PI;
	
	@:extern
	public static inline function toRad(deg:FastFloat):FastFloat {
		return deg * CONST_RAD;
	}
	
	
	@:extern
	public static inline function toDeg(rad:FastFloat):FastFloat {
		return rad * CONST_DEG;
	}
	
	@:extern
	public static inline function wrapDeg(angle:FastFloat, positive:Bool = false):FastFloat {
		angle %= 360;
		if (positive) return (angle + 360) % 360;
		return angle;
	}
	
}