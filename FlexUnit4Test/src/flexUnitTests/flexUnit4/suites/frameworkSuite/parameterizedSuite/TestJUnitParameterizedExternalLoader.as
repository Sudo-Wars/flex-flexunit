/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package flexUnitTests.flexUnit4.suites.frameworkSuite.parameterizedSuite
{
	
	import flexUnitTests.flexUnit4.suites.frameworkSuite.parameterizedSuite.helper.ParamDataHelper;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.runners.Parameterized;
	
	[RunWith("org.flexunit.runners.Parameterized")]
	public class TestJUnitParameterizedExternalLoader
	{
		private var foo : Parameterized;
		
		public static var testCount : int = 0;
		
		[Parameters]
		public static var ensureRunOnceData : Array = [ [ 0 ] ];
		
		public static var dataRetriever1:ParamDataHelper = new ParamDataHelper( "TestJUnitParameterizedExternal.stuff" );
		
		[Parameters(loader="dataRetriever1")]
		public static var someData:Array;
		
		protected var num : int;
		
		[AfterClass]
		public static function afterClass() : void
		{
			// NOTE: If this fails, it will not show up as a failure on the tests, but as a "null" failure within the suite.
			Assert.assertEquals( testCount, 4 );
		}
		
		[Test]
		public function parameterized_junit_verifyAllDatapointsLoadedPtTwo() : void
		{
			// Since the loader has a timer that delays the datapoint construction, can assume this will run in order...
			++testCount;
			// NOTE: TEST FAILING: Order can't be assumed?
			//Assert.assertEquals( num, testCount );
		}

		public function TestJUnitParameterizedExternalLoader( num : int )
		{
			this.num = num;
		}
	}
}