package io.tapirtest.junit5executiontest.data


import de.bmiag.tapir.execution.annotations.parameter.Parameter
import de.bmiag.tapir.execution.annotations.step.Step
import de.bmiag.tapir.execution.annotations.testclass.TestClass

@TestClass
class TestClassParameterizedStep {

	@Step
	def void step1(@Parameter String param) {
	}

	@Step
	def void step2(@Parameter String param1, @Parameter String param2) {
	}

	override step1ParamParameter() {
		"value1"
	}
	
	override step2Param1Parameter() {
		"value1"
	}
	
	override step2Param2Parameter() {
		"value2"
	}

}
