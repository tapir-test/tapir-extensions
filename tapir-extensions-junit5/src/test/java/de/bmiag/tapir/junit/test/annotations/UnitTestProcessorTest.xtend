package de.bmiag.tapir.junit.test.annotations

/*-
 * #%L
 * de.bmiag.tapir:tapir-junit
 * %%
 * Copyright (C) 2018 b+m Informatik AG
 * %%
 * This program is distributed under the License terms for the tapir Community Edition.
 * 
 * You should have received a copy of the License terms for the tapir Community Edition along with this program. If not, see
 * <https://www.tapir-test.io/license-community-edition>.
 * #L%
 */

import de.bmiag.tapir.coreassertion.CoreAssertions
import de.bmiag.tapir.xunit.annotations.UnitTest
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.junit.jupiter.SpringExtension

class UnitTestProcessorTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(UnitTest.classLoader)

	@Test
	def void testCompiler() {
		'''
			import «UnitTest.name»
			
			@«UnitTest.simpleName»("browser=htmlunit")
			class MyUnitTestClass {
			    
			}
		'''.assertCompilesTo(
        '''
			import «CoreAssertions.name»;
			import «UnitTest.name»;
			import «Extension.name»;
			import «ExtendWith.name»;
			import «Autowired.name»;
			import «SpringBootTest.name»;
			import «SpringExtension.name»;
			
			@«UnitTest.simpleName»("browser=htmlunit")
			@«SpringBootTest.simpleName»(properties = "browser=htmlunit")
			@«ExtendWith.simpleName»(value = «SpringExtension.simpleName».class)
			@SuppressWarnings("all")
			public class MyUnitTestClass {
			  @«Extension.simpleName»
			  @«Autowired.simpleName»
			  private «CoreAssertions.simpleName» _coreassertions;
			}
		''')

	}

}
