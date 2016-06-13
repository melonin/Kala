package kala.behaviors.collision.shapes;

import kala.math.Matrix;
import kala.math.Position;
import kala.math.Rotation;
import kala.math.Vec2;
import kala.math.Vec2T;
import kha.FastFloat;

@:allow(kala.behaviors.Behavior)
class CollisionShape {
	
	// To avoid using Std.is
	public var isCircle(default, null):Bool;
	
	public var collider(default, null):Collider;

	public var position:Position = new Position();
	
	public var scale:Vec2T = new Vec2T();
	public var rotation:Rotation = new Rotation();
	
	public var matrix(default, null):Matrix;
	
	public var width(get, never):FastFloat;
	public var height(get, never):FastFloat;
	
	public var available(get, never):Bool;
	
	private var _vertices:Array<Vec2> = new Array<Vec2>();

	public function new() {
		reset();
	}
	
	public function reset():Void {
		position.set();
		scale.set(1, 1, 0, 0);
		rotation.set(0, 0, 0);
	}
	
	public function destroy():Void {
		position = null;
		
		scale = null;
		rotation = null;
		
		_vertices = null;
		
		matrix = null;
	}
	
	public function put():Void {
		
	}
	
	public inline function getLocalMatrix():Matrix {
		return Matrix.getTransformation(position, scale, rotation);
	}
	
	public inline function updateMatrix(objectMatrix:Matrix):Void {
		matrix = objectMatrix.multmat(getLocalMatrix());
	}
	
	public function getVertices():Array<Vec2> {
		return _vertices.copy();
	}
	
	public function getTransformedVertices():Array<Vec2> {
		var transformedVertices = new Array<Vec2>();
		
		for (vert in _vertices) {
			transformedVertices.push(vert.transform(matrix));
		}

		return transformedVertices;
	}
	
	public function test(shape:CollisionShape):CollisionResult {
		if (shape.isCircle) return testCircle(cast shape);
		return testPolygon(cast shape);
	}
	
	public function testCircle(circle:CollisionCircle):CollisionResult {
		return null;
	}
	
	public function testPolygon(polygon:CollisionPolygon):CollisionResult {
		return null;
	}
	
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		return false;
	}
	
	function get_width():FastFloat {
		return 0;
	}
	
	function get_height():FastFloat {
		return 0;
	}
	
	inline function get_available():Bool {
		return matrix != null;
	}
	
}