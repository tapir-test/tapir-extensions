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
import de.bmiag.tapir.variant.annotation.feature.Feature

/**
 * This is a unit test for the {@link FeatureIDEVariantProcessor}.
 * 
 * @author Nils Christian Ehmke
 */
class FeatureIDEVariantProcessorTest {
	
	@Test
	def notAvailableFeatureModelFileShouldResultInError() {
		val compilationTestHelper = createCompilationTestHelper()

		compilationTestHelper.compile(
		'''
			package io.tapirtest.test
						
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEVariant.simpleName»('nonExistingFile.xml')
			class MyVariant {
			}
		''', [
			assertThat(errorsAndWarnings, hasSize(1))
			assertThat(errorsAndWarnings.get(0).severity, is(Severity.ERROR))
			assertThat(errorsAndWarnings.get(0).message, is('The variant configuration file could not be found.'))
		])
	}
	
	@Test
	def simpleModelFileShouldBeGeneratedCorrectly() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="F1"/>
			</configuration>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»
			import «Feature.name»

			@«Feature.simpleName»			
			class F1Feature {
			}
			
			@«FeatureIDEVariant.simpleName»('model.xml')
			class MyVariant {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/F1Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F1Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F1Feature implements Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyVariant.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import io.tapirtest.test.F1Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@Configuration
			@ConditionalOnProperty(name = "variant", havingValue = "MyVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  public final static String NAME = "MyVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
			  
			  @Bean
			  @ConditionalOnProperty(name = "io.tapirtest.test.F1Feature.active", havingValue = "MyVariant", matchIfMissing = true)
			  public F1Feature f1Feature() {
			    return new F1Feature();
			  }
			}
			
		''')
	}
	
	@Test
	def prefixesShouldBePrepended() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="F1"/>
			</configuration>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»
			import «Feature.name»

			@«Feature.simpleName»			
			class MyPrefixF1Feature {
			}
			
			@«FeatureIDEVariant.simpleName»(value='model.xml', prefix='MyPrefix')
			class MyVariant {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/MyPrefixF1Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.MyPrefixF1Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class MyPrefixF1Feature implements Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyVariant.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import io.tapirtest.test.MyPrefixF1Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@Configuration
			@ConditionalOnProperty(name = "variant", havingValue = "MyVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  public final static String NAME = "MyVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
			  
			  @Bean
			  @ConditionalOnProperty(name = "io.tapirtest.test.MyPrefixF1Feature.active", havingValue = "MyVariant", matchIfMissing = true)
			  public MyPrefixF1Feature myPrefixF1Feature() {
			    return new MyPrefixF1Feature();
			  }
			}
			
		''')
	}
	
	@Test
	def suffixesShouldBeAppended() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="F1"/>
			</configuration>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»
			import «Feature.name»

			@«Feature.simpleName»			
			class F1MySuffix {
			}
			
			@«FeatureIDEVariant.simpleName»(value='model.xml', suffix='MySuffix')
			class MyVariant {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/F1MySuffix.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F1MySuffix.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F1MySuffix implements Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyVariant.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import io.tapirtest.test.F1MySuffix;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@Configuration
			@ConditionalOnProperty(name = "variant", havingValue = "MyVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  public final static String NAME = "MyVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
			  
			  @Bean
			  @ConditionalOnProperty(name = "io.tapirtest.test.F1MySuffix.active", havingValue = "MyVariant", matchIfMissing = true)
			  public F1MySuffix f1MySuffix() {
			    return new F1MySuffix();
			  }
			}
			
		''')
	}
	
	@Test
	def abstractFeaturesShouldBeIgnored() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="F1"/>
			</configuration>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»

			abstract class F1Feature {
			}
			
			@«FeatureIDEVariant.simpleName»('model.xml')
			class MyVariant {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/F1Feature.java
			
			package io.tapirtest.test;
			
			@SuppressWarnings("all")
			public abstract class F1Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyVariant.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@Configuration
			@ConditionalOnProperty(name = "variant", havingValue = "MyVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  public final static String NAME = "MyVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
			}
			
		''')
	}
	
	@Test
	def notSelectedFeaturesShouldBeIgnored() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="unselected" name="F1"/>
			</configuration>
		''')

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»
			import «Feature.name»

			@«Feature.simpleName»			
			class F1Feature {
			}
			
			@«FeatureIDEVariant.simpleName»('model.xml')
			class MyVariant {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/F1Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F1Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F1Feature implements Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyVariant.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@Configuration
			@ConditionalOnProperty(name = "variant", havingValue = "MyVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  public final static String NAME = "MyVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
			}
			
		''')
	}
	
	@Test
	def missingFeatureShouldResultInError() {
		val compilationTestHelper = createCompilationTestHelper('myProject/src/model.xml', '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="F1"/>
			</configuration>
		''')

		compilationTestHelper.compile(
		'''
			package io.tapirtest.test
						
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEVariant.simpleName»('model.xml')
			class MyVariant {
			}
		''', [
			assertThat(errorsAndWarnings, hasSize(1))
			assertThat(errorsAndWarnings.get(0).severity, is(Severity.ERROR))
			assertThat(errorsAndWarnings.get(0).message, is('Feature \'io.tapirtest.test.F1Feature\' could not be found'))
		])
	}
	
	@Test
	def explicitVariantNameShouldOverwriteDefault() {
		val compilationTestHelper = createCompilationTestHelper()

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»

			@«FeatureIDEVariant.simpleName»(value = 'model.xml', name = 'SomeVariant')
			class MyVariant {
			}
		''', '''
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@Configuration
			@ConditionalOnProperty(name = "variant", havingValue = "SomeVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  public final static String NAME = "SomeVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
			}
		''')
	}
	
	@Test
	def explicitpropertyNameShouldOverwriteDefault() {
		val compilationTestHelper = createCompilationTestHelper()

		compilationTestHelper.assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureIDEVariant.name»

			@«FeatureIDEVariant.simpleName»(value = 'model.xml', propertyName = 'customer')
			class MyVariant {
			}
		''', '''
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.Variant;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.context.annotation.Bean;
			import org.springframework.context.annotation.Configuration;
			
			@Configuration
			@ConditionalOnProperty(name = "customer", havingValue = "MyVariant")
			@SuppressWarnings("all")
			public class MyVariant implements Variant {
			  public final static String NAME = "MyVariant";
			  
			  @Bean
			  public String variant() {
			    return MyVariant.NAME;
			  }
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