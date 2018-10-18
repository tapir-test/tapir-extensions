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
 package io.tapirtest.featureide.annotation

import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.Test

/**
 * This is a unit test for the {@link FeatureIDEVariantProcessor}.
 * 
 * @author Nils Christian Ehmke
 */
class FeatureIDEVariantProcessorTest {
	
	@Test
	def simpleModelFileShouldBeGeneratedCorrectly() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="Root"/>
			    <feature automatic="selected" name="F1"/>
			</configuration>

		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEVariant.simpleName»('model.xml')
			class MyVariant {
			}
		''', '''
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import io.tapirtest.featureide.annotation.FeatureIDEVariant;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@FeatureIDEVariant("model.xml")
			@Configuration
			@ConditionalOnProperty(name = "variant", havingValue = "MyVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  private final static String NAME = "MyVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
			}
		''')
	}
	
	private def createCompilationTestHelper(String filePath, String fileContent) {
		val compilationTestHelper = XtendInjectorSingleton.INJECTOR.getInstance(CompilationTestHelper)
		compilationTestHelper.javaCompilerClassPath = FeatureIDEFeaturesProcessor.classLoader
		compilationTestHelper.configureFreshWorkspace

		if (filePath !== null && fileContent !== null) {
			compilationTestHelper.copyToWorkspace(filePath, fileContent)
		}

		compilationTestHelper
	}
	
}