/*
 * MIT License
 * 
 * Copyright (c) 2018 b+m Informatik AG
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package io.tapirtest.featureide.model.feature

import javax.xml.XMLConstants
import javax.xml.bind.JAXBContext
import javax.xml.bind.Unmarshaller
import javax.xml.validation.SchemaFactory
import org.junit.Test
import static org.junit.Assert.assertThat
import static org.hamcrest.core.IsInstanceOf.instanceOf
import static org.hamcrest.core.Is.is
import static org.hamcrest.core.IsNull.notNullValue
import static org.hamcrest.collection.IsCollectionWithSize.hasSize

class FeatureModelTest {
	 
	@Test
	def void featureModelFileShouldBeParsable() {
		val unmarshaller = createUnmarshaller()
		
		val object = unmarshaller.unmarshal(class.getResource('/featureModel.xml'))
		assertThat(object, is(instanceOf(FeatureModelType)))
		
		val featureModelType = object as FeatureModelType
		val struct = featureModelType.struct
		assertThat(struct, is(notNullValue))
		
		assertThat(struct.and.name, is('Root'))
		val branchedFeature = struct.and.andOrOrOrAlt.get(0).value as BranchedFeatureType
		assertThat(branchedFeature.andOrOrOrAlt, hasSize(4))
	}
	 
	@Test
	def void extendedFeatureModelFileShouldBeParsable() {
		val unmarshaller = createUnmarshaller()
		
		val object = unmarshaller.unmarshal(class.getResource('/extendedFeatureModel.xml'))
		assertThat(object, is(instanceOf(FeatureModelType)))
		
		val featureModelType = object as FeatureModelType
		val struct = featureModelType.struct
		assertThat(struct, is(notNullValue))
		
		assertThat(struct.and.name, is('Root'))
		val branchedFeature = struct.and.andOrOrOrAlt.get(0).value as BranchedFeatureType
		assertThat(branchedFeature.andOrOrOrAlt, hasSize(4))
	}
	
	
	private def Unmarshaller createUnmarshaller() {
		val jaxbContext = JAXBContext.newInstance(ObjectFactory)
		val unmarshaller = jaxbContext.createUnmarshaller
		val schemaFactory =SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI)
		val schema = schemaFactory.newSchema(class.getResource('/feature.xsd'))
		unmarshaller.schema = schema
		
		unmarshaller
	}
	
	
}
