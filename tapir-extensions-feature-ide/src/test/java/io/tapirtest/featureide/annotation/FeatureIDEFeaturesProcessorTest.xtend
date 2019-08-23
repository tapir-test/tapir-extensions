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
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.Test

import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import static org.hamcrest.core.Is.is
import static org.junit.Assert.assertThat

/**
 * This is a unit test for the {@link FeatureIDEFeaturesProcessor}.
 * 
 * @author Nils Christian Ehmke
 */
class FeatureIDEFeaturesProcessorTest {

	@Test
	def notAvailableFeatureModelFileShouldResultInError() {
		val compilationTestHelper = createCompilationTestHelper()

		compilationTestHelper.compile(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('nonExistingFile.xml')
			class Features {
			}
		''', [
			assertThat(errorsAndWarnings, hasSize(1))
			assertThat(errorsAndWarnings.get(0).severity, is(Severity.ERROR))
			assertThat(errorsAndWarnings.get(0).message, is('The feature model file could not be found.'))
		])
	}
	
	@Test
	def simpleModelFileShouldBeGeneratedCorrectly() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<feature name="MyFeature"/>
			    </struct>
			 </featureModel>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('model.xml')
			class Features {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			@SuppressWarnings("all")
			public class Features {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyFeatureFeature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.MyFeatureFeature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class MyFeatureFeature implements Feature {
			}
			
		''')
	}
	
	@Test
	def prefixesShouldBePrepended() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<feature name="MyFeature"/>
			    </struct>
			 </featureModel>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»(value = 'model.xml', prefix = 'MyPrefix')
			class Features {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			@SuppressWarnings("all")
			public class Features {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyPrefixMyFeatureFeature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.MyPrefixMyFeatureFeature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class MyPrefixMyFeatureFeature implements Feature {
			}
			
		''')
	}
	
	@Test
	def suffixesShouldBeAppended() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<feature name="MyFeature"/>
			    </struct>
			 </featureModel>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»(value = 'model.xml', suffix = 'MySuffix')
			class Features {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			@SuppressWarnings("all")
			public class Features {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyFeatureMySuffix.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.MyFeatureMySuffix.active", havingValue = "true")
			@SuppressWarnings("all")
			public class MyFeatureMySuffix implements Feature {
			}
			
		''')
	}
	
	@Test
	def modelFileWithNonWordCharactersShouldBeHandledCorrectly() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<feature name="A?BC.12$3"/>
			    </struct>
			 </featureModel>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('model.xml')
			class Features {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/ABC123Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.ABC123Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class ABC123Feature implements Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			@SuppressWarnings("all")
			public class Features {
			}
			
		''')
	}

	private def createCompilationTestHelper() {
		createCompilationTestHelper(null, null)
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
