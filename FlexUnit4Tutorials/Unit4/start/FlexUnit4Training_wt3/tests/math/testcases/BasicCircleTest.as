package math.testcases {
	import flash.geom.Point;
	
	import net.digitalprimates.math.Circle;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	
	public class BasicCircleTest {		

		[Test]
		public function shouldReturnProvidedRadius():void {
			var circle:Circle = new Circle( new Point( 0, 0 ), 5 );
			assertEquals( 5, circle.radius );
		}
		
		[Test]
		public function shouldComputeCorrectDiameter ():void {
			var circle:Circle = new Circle( new Point( 0, 0 ), 5 ); 
			assertEquals( 10, circle.diameter );
		}
		
		[Test]
		public function shouldReturnProvidedOrigin():void {
			var circle:Circle = new Circle( new Point( 0, 0 ), 5 ); 
			assertEquals( 0, circle.origin.x );
			assertEquals( 0, circle.origin.y );
		}
		
		[Test]
		public function shouldReturnTrueForEqualCircle():void {
			var circle:Circle = new Circle( new Point( 0, 0 ), 5 );
			var circle2:Circle = new Circle( new Point( 0, 0 ), 5 );
			
			assertTrue( circle.equals( circle2 ) );	
		}
		
		[Test]
		public function shouldReturnFalseForUnequalOrigin():void {
			var circle:Circle = new Circle( new Point( 0, 0 ), 5 );
			var circle2:Circle = new Circle( new Point( 0, 5 ), 5);
			
			assertFalse( circle.equals( circle2 ) );
		}
		
		[Test]
		public function shouldReturnFalseForUnequalRadius():void {
			var circle:Circle = new Circle( new Point( 0, 0 ), 5 );
			var circle2:Circle = new Circle( new Point( 0, 0 ), 7);
			
			assertFalse( circle.equals( circle2 ) );
		}
		
		[Test]
		public function shouldGetPointsOnCircle():void {
			var circle:Circle = new Circle( new Point( 0, 0 ), 5 );
			var point:Point;
			
			//top-most point of circle
			point = circle.getPointOnCircle( 0 );
			assertEquals( 5, point.x );
			assertEquals( 0, point.y );
			
			//bottom-most point of circle
			point = circle.getPointOnCircle( Math.PI );
			assertEquals( -5, point.x );
			assertEquals( 0, point.y );
		}
		
		[Test]
		public function shouldThrowRangeError():void {
			
		}

		
	}
}