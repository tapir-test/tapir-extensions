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
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

/**
 * This is a unit test for the {@link FeatureGenFeaturesProcessor}.
 * 
 * @author Nils Christian Ehmke
 */
class FeatureGenFeaturesProcessorTest {
	
	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(FeatureGenFeatures.classLoader)
	
	@Test
	def simpleFeatureModelShouldBeGeneratedCorrectly() {
		assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(«FeatureGenTestFeature.simpleName»)
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
			public final class ABC123Feature implements Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/F1Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F1Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class F1Feature implements Feature {
			}
			
			File 3 : /myProject/xtend-gen/io/tapirtest/test/F2Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F2Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class F2Feature implements Feature {
			}
			
			File 4 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			import io.tapirtest.featuregen.annotation.FeatureGenFeatures;
			import io.tapirtest.featuregen.test.featuregen.feature.FeatureGenTestFeature;
			
			@FeatureGenFeatures(FeatureGenTestFeature.class)
			@SuppressWarnings("all")
			public class Features {
			}
			
		''')
	}
	
	@Test
	def prefixesShouldBePrepended() {
		assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(value = «FeatureGenTestFeature.simpleName», prefix = 'MyPrefix')
			class Features {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			import io.tapirtest.featuregen.annotation.FeatureGenFeatures;
			import io.tapirtest.featuregen.test.featuregen.feature.FeatureGenTestFeature;
			
			@FeatureGenFeatures(value = FeatureGenTestFeature.class, prefix = "MyPrefix")
			@SuppressWarnings("all")
			public class Features {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/MyPrefixABC123Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.MyPrefixABC123Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class MyPrefixABC123Feature implements Feature {
			}
			
			File 3 : /myProject/xtend-gen/io/tapirtest/test/MyPrefixF1Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.MyPrefixF1Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class MyPrefixF1Feature implements Feature {
			}
			
			File 4 : /myProject/xtend-gen/io/tapirtest/test/MyPrefixF2Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.MyPrefixF2Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class MyPrefixF2Feature implements Feature {
			}
			
		''')
	}
	
	@Test
	def suffixesShouldBeAppended() {
		assertCompilesTo(
		'''
			package io.tapirtest.test
			
			import «FeatureGenFeatures.name»
			import «FeatureGenTestFeature.name»
			
			@«FeatureGenFeatures.simpleName»(value = «FeatureGenTestFeature.simpleName», suffix = 'MySuffix')
			class Features {
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/io/tapirtest/test/ABC123MySuffix.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.ABC123MySuffix.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class ABC123MySuffix implements Feature {
			}
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/F1MySuffix.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F1MySuffix.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class F1MySuffix implements Feature {
			}
			
			File 3 : /myProject/xtend-gen/io/tapirtest/test/F2MySuffix.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F2MySuffix.active", havingValue = "true")
			@SuppressWarnings("all")
			public final class F2MySuffix implements Feature {
			}
			
			File 4 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			import io.tapirtest.featuregen.annotation.FeatureGenFeatures;
			import io.tapirtest.featuregen.test.featuregen.feature.FeatureGenTestFeature;
			
			@FeatureGenFeatures(value = FeatureGenTestFeature.class, suffix = "MySuffix")
			@SuppressWarnings("all")
			public class Features {
			}
			
		''')
	}
	
}