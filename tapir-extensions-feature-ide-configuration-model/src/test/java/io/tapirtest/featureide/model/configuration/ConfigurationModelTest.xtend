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
package io.tapirtest.featureide.model.configuration

import javax.xml.XMLConstants
import javax.xml.bind.JAXBContext
import javax.xml.bind.Unmarshaller
import javax.xml.validation.SchemaFactory
import org.junit.Test

import static org.hamcrest.collection.IsIterableContainingInOrder.contains
import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import static org.hamcrest.core.Is.is
import static org.hamcrest.core.IsInstanceOf.instanceOf
import static org.junit.Assert.assertThat

class ConfigurationModelTest {
	 
	@Test
	def void configurationModelFileShouldBeParsable() {
		val unmarshaller = createUnmarshaller()
		
		val object = unmarshaller.unmarshal(class.getResource('/configuration.xml'))
		assertThat(object, is(instanceOf(Configuration)))
		
		val configuration = object as Configuration

		assertThat(configuration.feature, hasSize(8))
		
		val featureNames = configuration.feature.map[name]
		assertThat(featureNames, contains(#['Root', 'F1', 'F2', 'F3', 'F3.1', 'F4', 'F4.1', 'F4.2']))
	}
	
	private def Unmarshaller createUnmarshaller() {
		val jaxbContext = JAXBContext.newInstance(ObjectFactory)
		val unmarshaller = jaxbContext.createUnmarshaller
		val schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI)
		val schema = schemaFactory.newSchema(class.getResource('/configuration.xsd'))
		unmarshaller.schema = schema
		
		unmarshaller
	}
	
}