package io.tapirtest.junit5execution.test.annotations.testclass

import de.bmiag.tapir.coreassertion.CoreAssertions
import de.bmiag.tapir.execution.annotations.testclass.TestClass
import de.bmiag.tapir.execution.launch.TapirLauncher
import de.bmiag.tapir.util.extensions.TapirAssertions
import io.tapirtest.junit5execution.annotations.Test
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.platform.commons.annotation.Testable
import org.springframework.beans.factory.annotation.Autowired

class JUnit5TestClassProcessorTest {
    
    
    extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(TestClass.classLoader)
    
    @org.junit.jupiter.api.Test
    def void testCompiler() {
        '''
			import «TestClass.name»
			
			@«TestClass.simpleName»
			class MyTest {
			    
			}
		'''.assertCompilesTo(
        '''
			import «CoreAssertions.name»;
			import «TestClass.name»;
			import «TapirLauncher.name»;
			import «TapirAssertions.name»;
			import «Test.name»;
			import «Extension.name»;
			import «Testable.name»;
			import «Autowired.name»;
			
			@«TestClass.simpleName»
			@«Testable.simpleName»
			@SuppressWarnings("all")
			public class MyTest {
			  @«Extension.simpleName»
			  @«Autowired.simpleName»
			  private «TapirAssertions.simpleName» _«TapirAssertions.simpleName.toLowerCase»;
			  
			  @«Extension.simpleName»
			  @«Autowired.simpleName»
			  private «CoreAssertions.simpleName» _«CoreAssertions.simpleName.toLowerCase»;
			  
			  public static void main(final String[] args) {
			    «TapirLauncher.simpleName».launch(MyTest.class);
			  }
			  
			  @«Test.simpleName»
			  public void _xtendCompliance() {
			    
			  }
			}
		''')

    }
    
}
