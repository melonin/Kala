package kala.objects.shapes;

import kala.math.Color;
import kala.objects.shapes.Shape.ShapeType;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

using kha.graphics2.GraphicsExtension;

class Circle extends Shape {

	public var radius:FastFloat;
	public var segments:Null<Int>;
	
	public function new(radius:FastFloat) {
		super();
		type = ShapeType.CIRCLE;
		this.radius = radius;
	}
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
		segments = null;
	}
	
	override public function draw(
		?antialiasing:Bool = false, 
		?transformation:FastMatrix3, 
		?color:Color, ?colorBlendMode:ColorBlendMode, 
		?opacity:FastFloat = 1, 
		canvas:Canvas
	):Void {
		applyDrawingData(antialiasing, transformation, null, colorBlendMode, opacity, canvas);

		applyDrawingFillData();
		canvas.g2.fillCircle(radius, radius, radius, segments);
		
		applyDrawingLineData();
		canvas.g2.drawCircle(radius, radius, radius, lineStrenght, segments);
	}
	
}