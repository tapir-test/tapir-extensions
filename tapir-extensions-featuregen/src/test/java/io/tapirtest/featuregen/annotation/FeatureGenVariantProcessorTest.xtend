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
 package io.tapirtest.featuregen.annotation

import io.tapirtest.featuregen.test.featuregen.feature.FeatureGenTestFeature
import io.tapirtest.featuregen.test.featuregen.variant.Variant1
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import static org.junit.Assert.assertEquals

/**
 * This is a unit test for the {@link FeatureGenVariantProcessor}.
 * 
 * @author Nils Christian Ehmke
 */
class FeatureGenVariantProcessorTest {
	
	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(FeatureGenFeatures.classLoader)
	
	@Test
	def simpleFeatureModelShouldBeGeneratedCorrectly() {
		compile(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenVariant.name»
			import «Variant1.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(«FeatureGenTestFeature.simpleName»)
			class Features {
			}
			
			@«FeatureGenVariant.simpleName»(featuresClass = Features, variantClass = «Variant1.simpleName»)
			class TapirVariant1 {
			}
		''', [
			val String expected = '''
				package io.tapirtest.test;
				
				import de.bmiag.tapir.variant.Variant;
				import io.tapirtest.featuregen.annotation.FeatureGenVariant;
				import io.tapirtest.featuregen.test.featuregen.variant.Variant1;
				import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
				import org.springframework.context.annotation.Bean;
				import org.springframework.context.annotation.Configuration;
				
				@FeatureGenVariant(featuresClass = Features.class, variantClass = Variant1.class)
				@Configuration
				@ConditionalOnProperty(name = "variant", havingValue = "TapirVariant1")
				@SuppressWarnings("all")
				public class TapirVariant1 implements Variant {
				  public static final String NAME = "TapirVariant1";
				
				  @Bean
				  public String variant() {
				    return TapirVariant1.NAME;
				  }
				
				  @Bean
				  @ConditionalOnProperty(name = "io.tapirtest.test.F1Feature.active", havingValue = "true", matchIfMissing = true)
				  public F1Feature f1Feature() {
				    return new F1Feature();
				  }
				}
			'''
			val String actual = allGeneratedResources.get('/myProject/xtend-gen/io/tapirtest/test/TapirVariant1.java').toString
			assertEquals(expected, actual)
		])
	}
	
	@Test
	def prefixesShouldBePrepended() {
		compile(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenVariant.name»
			import «Variant1.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(value = «FeatureGenTestFeature.simpleName», prefix = 'MyPrefix')
			class Features {
			}
			
			@«FeatureGenVariant.simpleName»(featuresClass = Features, variantClass = «Variant1.simpleName»)
			class TapirVariant1 {
			}
		''', [
			val String expected = '''
				package io.tapirtest.test;
				
				import de.bmiag.tapir.variant.Variant;
				import io.tapirtest.featuregen.annotation.FeatureGenVariant;
				import io.tapirtest.featuregen.test.featuregen.variant.Variant1;
				import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
				import org.springframework.context.annotation.Bean;
				import org.springframework.context.annotation.Configuration;
				
				@FeatureGenVariant(featuresClass = Features.class, variantClass = Variant1.class)
				@Configuration
				@ConditionalOnProperty(name = "variant", havingValue = "TapirVariant1")
				@SuppressWarnings("all")
				public class TapirVariant1 implements Variant {
				  public static final String NAME = "TapirVariant1";
				
				  @Bean
				  public String variant() {
				    return TapirVariant1.NAME;
				  }
				
				  @Bean
				  @ConditionalOnProperty(name = "io.tapirtest.test.MyPrefixF1Feature.active", havingValue = "true", matchIfMissing = true)
				  public MyPrefixF1Feature myPrefixF1Feature() {
				    return new MyPrefixF1Feature();
				  }
				}
			'''
			val String actual = allGeneratedResources.get('/myProject/xtend-gen/io/tapirtest/test/TapirVariant1.java').toString
			assertEquals(expected, actual)
		])
	}
	
	@Test
	def suffixesShouldBeAppended() {
		compile(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenVariant.name»
			import «Variant1.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(value = «FeatureGenTestFeature.simpleName», suffix = 'MySuffix')
			class Features {
			}
			
			@«FeatureGenVariant.simpleName»(featuresClass = Features, variantClass = «Variant1.simpleName»)
			class TapirVariant1 {
			}
		''', [
			val String expected = '''
				package io.tapirtest.test;
				
				import de.bmiag.tapir.variant.Variant;
				import io.tapirtest.featuregen.annotation.FeatureGenVariant;
				import io.tapirtest.featuregen.test.featuregen.variant.Variant1;
				import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
				import org.springframework.context.annotation.Bean;
				import org.springframework.context.annotation.Configuration;
				
				@FeatureGenVariant(featuresClass = Features.class, variantClass = Variant1.class)
				@Configuration
				@ConditionalOnProperty(name = "variant", havingValue = "TapirVariant1")
				@SuppressWarnings("all")
				public class TapirVariant1 implements Variant {
				  public static final String NAME = "TapirVariant1";
				
				  @Bean
				  public String variant() {
				    return TapirVariant1.NAME;
				  }
				
				  @Bean
				  @ConditionalOnProperty(name = "io.tapirtest.test.F1MySuffix.active", havingValue = "true", matchIfMissing = true)
				  public F1MySuffix f1MySuffix() {
				    return new F1MySuffix();
				  }
				}
			'''
			val String actual = allGeneratedResources.get('/myProject/xtend-gen/io/tapirtest/test/TapirVariant1.java').toString
			assertEquals(expected, actual)
		])
	}
	
	@Test
	def explicitVariantNameShouldOverwriteDefault() {
		compile(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenVariant.name»
			import «Variant1.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(«FeatureGenTestFeature.simpleName»)
			class Features {
			}
			
			@«FeatureGenVariant.simpleName»(featuresClass = Features, variantClass = «Variant1.simpleName», name = 'SomeVariant')
			class TapirVariant1 {
			}
		''', [
			val String expected = '''
				package io.tapirtest.test;
				
				import de.bmiag.tapir.variant.Variant;
				import io.tapirtest.featuregen.annotation.FeatureGenVariant;
				import io.tapirtest.featuregen.test.featuregen.variant.Variant1;
				import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
				import org.springframework.context.annotation.Bean;
				import org.springframework.context.annotation.Configuration;
				
				@FeatureGenVariant(featuresClass = Features.class, variantClass = Variant1.class, name = "SomeVariant")
				@Configuration
				@ConditionalOnProperty(name = "variant", havingValue = "SomeVariant")
				@SuppressWarnings("all")
				public class TapirVariant1 implements Variant {
				  public static final String NAME = "SomeVariant";
				
				  @Bean
				  public String variant() {
				    return TapirVariant1.NAME;
				  }
				
				  @Bean
				  @ConditionalOnProperty(name = "io.tapirtest.test.F1Feature.active", havingValue = "true", matchIfMissing = true)
				  public F1Feature f1Feature() {
				    return new F1Feature();
				  }
				}
			'''
			val String actual = allGeneratedResources.get('/myProject/xtend-gen/io/tapirtest/test/TapirVariant1.java').toString
			assertEquals(expected, actual)
		])
	}
	
	@Test
	def explicitPropertyNameShouldOverwriteDefault() {
		compile(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenVariant.name»
			import «Variant1.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(«FeatureGenTestFeature.simpleName»)
			class Features {
			}
			
			@«FeatureGenVariant.simpleName»(featuresClass = Features, variantClass = «Variant1.simpleName», propertyName = 'customer')
			class TapirVariant1 {
			}
		''', [
			val String expected = '''
				package io.tapirtest.test;
				
				import de.bmiag.tapir.variant.Variant;
				import io.tapirtest.featuregen.annotation.FeatureGenVariant;
				import io.tapirtest.featuregen.test.featuregen.variant.Variant1;
				import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
				import org.springframework.context.annotation.Bean;
				import org.springframework.context.annotation.Configuration;
				
				@FeatureGenVariant(featuresClass = Features.class, variantClass = Variant1.class, propertyName = "customer")
				@Configuration
				@ConditionalOnProperty(name = "customer", havingValue = "TapirVariant1")
				@SuppressWarnings("all")
				public class TapirVariant1 implements Variant {
				  public static final String NAME = "TapirVariant1";
				
				  @Bean
				  public String variant() {
				    return TapirVariant1.NAME;
				  }
				
				  @Bean
				  @ConditionalOnProperty(name = "io.tapirtest.test.F1Feature.active", havingValue = "true", matchIfMissing = true)
				  public F1Feature f1Feature() {
				    return new F1Feature();
				  }
				}
			'''
			val String actual = allGeneratedResources.get('/myProject/xtend-gen/io/tapirtest/test/TapirVariant1.java').toString
			assertEquals(expected, actual)
		])
	}
	
}