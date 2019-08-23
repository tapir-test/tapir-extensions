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

import com.google.common.io.Resources
import java.nio.charset.StandardCharsets
import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.Test
import org.junit.runners.Parameterized
import org.junit.runner.RunWith
import org.junit.runners.Parameterized.Parameters

/**
 * This is a unit test for the {@link FeatureIDEFeaturesProcessor}.
 * 
 * @author Nils Christian Ehmke
 */
 @RunWith(Parameterized)
class ExtendedFeatureIDEFeaturesProcessorTest {
		 
    val String filePath

	new(String filePath) {
		this.filePath = filePath;
	}
	
	@Parameters(name = '{0}')
	def static data() {
		#['/featureModel.xml', '/extendedFeatureModel.xml']
    }
    
    @Test
	def featureModelShouldBeGeneratedCorrectly() {
		val compilationTestHelper = createCompilationTestHelper(filePath)
		
		compilationTestHelper.assertCompilesTo('''
			package io.tapirtest.test
	
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('«filePath»')
			class Features {
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
			
			File 2 : /myProject/xtend-gen/io/tapirtest/test/F21Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F21Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F21Feature implements Feature {
			}
			
			File 3 : /myProject/xtend-gen/io/tapirtest/test/F22Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F22Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F22Feature implements Feature {
			}
			
			File 4 : /myProject/xtend-gen/io/tapirtest/test/F2Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F2Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F2Feature implements Feature {
			}
			
			File 5 : /myProject/xtend-gen/io/tapirtest/test/F31Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F31Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F31Feature implements Feature {
			}
			
			File 6 : /myProject/xtend-gen/io/tapirtest/test/F32Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F32Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F32Feature implements Feature {
			}
			
			File 7 : /myProject/xtend-gen/io/tapirtest/test/F3Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F3Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F3Feature implements Feature {
			}
			
			File 8 : /myProject/xtend-gen/io/tapirtest/test/F41Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F41Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F41Feature implements Feature {
			}
			
			File 9 : /myProject/xtend-gen/io/tapirtest/test/F42Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F42Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F42Feature implements Feature {
			}
			
			File 10 : /myProject/xtend-gen/io/tapirtest/test/F4Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F4Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F4Feature implements Feature {
			}
			
			File 11 : /myProject/xtend-gen/io/tapirtest/test/F51Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F51Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F51Feature implements Feature {
			}
			
			File 12 : /myProject/xtend-gen/io/tapirtest/test/F52Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F52Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F52Feature implements Feature {
			}
			
			File 13 : /myProject/xtend-gen/io/tapirtest/test/F5Feature.java
			
			package io.tapirtest.test;
			
			import de.bmiag.tapir.variant.feature.Feature;
			import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
			import org.springframework.stereotype.Component;
			
			@Component
			@ConditionalOnProperty(name = "io.tapirtest.test.F5Feature.active", havingValue = "true")
			@SuppressWarnings("all")
			public class F5Feature implements Feature {
			}
			
			File 14 : /myProject/xtend-gen/io/tapirtest/test/Features.java
			
			package io.tapirtest.test;
			
			@SuppressWarnings("all")
			public class Features {
			}
			
			File 15 : /myProject/xtend-gen/io/tapirtest/test/RootFeature.java
			
			package io.tapirtest.test;
			
			@SuppressWarnings("all")
			public abstract class RootFeature {
			}
			
		''')
	}
	
	private def createCompilationTestHelper(String filePath) {
		val compilationTestHelper = XtendInjectorSingleton.INJECTOR.getInstance(CompilationTestHelper)
		compilationTestHelper.javaCompilerClassPath = FeatureIDEFeaturesProcessor.classLoader
		compilationTestHelper.configureFreshWorkspace
		
		val url = class.getResource(filePath)
		val content = Resources.toString(url, StandardCharsets.UTF_8)
		compilationTestHelper.copyToWorkspace('/myProject/src' + filePath, content)
		
		compilationTestHelper
	}
	
}
