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
package org.flexunit.experimental.theories {
	import flex.lang.reflect.Constructor;
	import flex.lang.reflect.Field;
	import flex.lang.reflect.Method;
	import flex.lang.reflect.metadata.MetaDataAnnotation;
	
	import org.flexunit.runners.model.FrameworkMethod;
	
	/**
	 * The <code>ParameterSignature</code> is the signautre for a specific parameter in a theory method.  It contains
	 * information about the parameter's type as well as information about the method it belongs to.
	 */
	public class ParameterSignature {
		
		/**
		 * @private
		 */
		private var _type:Class;
		/**
		 * @private
		 */
		private var _metaDataList:Array;
		
		/**
		 * Creates an Array of <code>ParameterSignature</code>s for each parameter in a theory method.
		 * 
		 * @param method The current theory method.
		 * 
		 * @return an Array containing the <code>ParameterSignature</code> for each parameter in the method.
		 */
 		public static function signaturesByMethod( method:Method ):Array {
 			//trace("yo");
			return signatures( method.parameterTypes, method.metadata );
		}
		
		/**
		 * Creates an Array of <code>ParameterSignature</code>s for each parameter in a theory constructor.
		 * 
		 * @param constructor The current theory constructor.
		 * 
		 * @return an Array containing the <code>ParameterSignature</code> for each parameter in the constructor.
		 */
		public static function signaturesByContructor( constructor:Constructor ):Array {
			return signatures( constructor.parameterTypes, null );
		}
		
		/**
		 * Creates an Array of <code>ParameterSignature</code>s for each parameter in the parameter types array.
		 * 
		 * @param parameterTypes An Array consisting of the types of parameters in a given signature.
		 * 
		 * @return an Array containing the <code>ParameterSignature</code> for each parameter in the signautre.
		 */
		private static function signatures( parameterTypes:Array, metadataList:Array ):Array {
			var sigs:Array = new Array();
			for ( var i:int= 0; i < parameterTypes.length; i++) {
				sigs.push( new ParameterSignature( parameterTypes[i], metadataList ) );
			}
			return sigs;
		}
		
		/**
		 * Determine if the type of the parameter matches the provided candidate type.
		 * 
		 * @param candidate A Class that represents a potential provided parameter.
		 * 
		 * @return a Boolean value indicating whether the current parameter can accept a parameter of a provided tpye.
		 */
		public function canAcceptType( candidate:Class ):Boolean {
			return ( type == candidate );
		}
		
		/**
		 * Returns the type of the <code>ParameterSignature</code>.
		 */
		public function get type():Class {
			return _type;
		}
		
		/**
		 * Determine if the provided field has a type of Array and if the element type of the field matches the 
		 * type in this <code>ParameterSignature</code>.
		 * 
		 * @param field The current field to check.
		 * 
		 * @return a Boolean value indicating whether the current parameter can accept the element type 
		 * supplied in the potential field.
		 */
		public function canAcceptArrayType( field:Field ):Boolean {
			return ( field.type == Array ) && canAcceptType( field.elementType ); 
		}
		
		/**
		 * Determine if the provided framework method produces a type of Array and if the element type of the framework method's method 
		 * matches the type in this <code>ParameterSignature</code>.
		 * 
		 * @param frameworkMethod The current framework method.
		 * 
		 * @return a Boolean value indicating whether the current parameter can accept the element type 
		 * supplied in the framework method's method.
		 */
		public function canAcceptArrayTypeMethod( frameworkMethod:FrameworkMethod ):Boolean {
			return ( frameworkMethod.producesType( Array ) && canAcceptType( frameworkMethod.method.elementType ) );
		}
		
		/**
		 * Determine if there is a name attribute in the metadata that matches the supplied type.
		 * 
		 * @param type The name to check for in the metadata.
		 * 
		 * @return a Boolean value indicating whether there is metadata that has a name that matches the supplied type.
		 */
		public function hasMetadata( type:String ):Boolean {
			return getAnnotation(type) != null;
		}
		
 		public function findDeepAnnotation( type:String ):MetaDataAnnotation {
			//TODO
			var metaDataList2:Array = _metaDataList.slice();
			return privateFindDeepAnnotation( metaDataList2, type, 3);
		}
	
		private function privateFindDeepAnnotation( metaDataList:Array, type:String, depth:int ):MetaDataAnnotation {
			if (depth == 0)
				return null;

			//just return these for now... not sure how this will apply yet
			return getAnnotation( type );

/* 			for (Annotation each : annotations) {
				if (annotationType.isInstance(each))
					return annotationType.cast(each);
				Annotation candidate= findDeepAnnotation(each.annotationType()
						.getAnnotations(), annotationType, depth - 1);
				if (candidate != null)
					return annotationType.cast(candidate);
			}
			//not really getting this yet
 */	
			return null;
		}
		
		/**
		 * Determine if there is a name attribute in the metadata that matches the supplied type.
		 * 
		 * @param type The name to check for in the metadata.
		 * 
		 * @return a MetaDataAnnotation that is the metadata that has a name attribute that matches the provided type.  If no name match is found,
		 * a value of null is returned.
		 */
		public function getAnnotation( type:String ):MetaDataAnnotation {
			for ( var i:int=0;i<_metaDataList.length; i++ ) {
				if ( ( _metaDataList[ i ] as MetaDataAnnotation ).name == type ) {
					return _metaDataList[ i ];
				}
			}

			return null;
		}
		
		/**
		 * Returns a string that includes the name of the type of the parameter as well as the 
		 * parameter's associated method metadata.
		 */
 		public function toString():String {
			return "ParameterSignature ( type:" + type + ", metadata:" + _metaDataList + " )";
		}
		
		/**
		 * Constructor.
		 * 
		 * @param type The Class type of the parameter.
		 * @param metaDataList Associated metadata for the method the parameter is associated with.
		 */
		public function ParameterSignature( type:Class, metaDataList:Array ) {
			this._type= type;
			this._metaDataList = metaDataList;
		}
	}
}