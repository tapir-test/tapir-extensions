package io.tapirtest.junit5executiontest.data

import de.bmiag.tapir.execution.annotations.parameter.IteratedParameter
import de.bmiag.tapir.execution.annotations.step.Step
import de.bmiag.tapir.execution.annotations.testclass.TestClass

@TestClass 
class TestClassIteratedParameterizedStep {

	@Step
	def void step1(@IteratedParameter String param) {
	}

	@Step
	def void step2(@IteratedParameter String param1, @IteratedParameter String param2) {
	}

	override step1ParamParameter() {
		# ["value1", "value2"]
	}
	
	override step2Param1Parameter() {
		# ["param1value1", "param1value2"]
	}
	
	override step2Param2Parameter() {
		# ["param2value1", "param2value2"]
	}

}
