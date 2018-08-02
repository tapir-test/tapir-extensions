package io.tapirtest.junit5executiontest.data

import de.bmiag.tapir.execution.annotations.step.Step
import de.bmiag.tapir.execution.annotations.testclass.TestClass

@TestClass
class TestClassSimpleStep {
	
	@Step
	def void step1() {
		
	}
}
