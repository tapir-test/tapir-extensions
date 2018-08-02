package io.tapirtest.junit5execution.test.annotations.suite

import de.bmiag.tapir.execution.annotations.suite.TestSuite
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import de.bmiag.tapir.execution.launch.TapirLauncher
import org.junit.platform.commons.annotation.Testable
import org.junit.jupiter.api.Test

class JUnit5TestSuiteProcessorTest {
    
    extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(TestSuite.classLoader)
    
    @Test
    def void testCompiler() {
        '''
			import «TestSuite.name»
			
			@«TestSuite.simpleName»(#[MyTestSuite])
			class MyTestSuite {
			    
			}
		'''.assertCompilesTo(
        '''
			import «TestSuite.name»;
			import «TapirLauncher.name»;
			import «io.tapirtest.junit5execution.annotations.Test.name»;
			import «Testable.name»;
			
			@«TestSuite.simpleName»({ MyTestSuite.class })
			@«Testable.simpleName»
			@SuppressWarnings("all")
			public class MyTestSuite {
			  public static void main(final String[] args) {
			    «TapirLauncher.simpleName».launch(MyTestSuite.class);
			  }
			  
			  @«io.tapirtest.junit5execution.annotations.Test.simpleName»
			  public void _xtendCompliance() {
			    
			  }
			}
		''')

    }
    
}
