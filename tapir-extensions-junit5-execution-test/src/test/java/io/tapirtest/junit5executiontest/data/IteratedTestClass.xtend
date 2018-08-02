package io.tapirtest.junit5executiontest.data

import de.bmiag.tapir.execution.annotations.parameter.IteratedParameter
import de.bmiag.tapir.execution.annotations.step.Step
import de.bmiag.tapir.execution.annotations.testclass.TestClass

@TestClass
class IteratedTestClass {
	
	@IteratedParameter
	String param
	
	override paramParameter() {
		# ["value1", "value2"]
	}
	
	@Step
	def void step1() {
	}
	
	@Step
	def void step2(@IteratedParameter String param) {
		println
	}
	
	override step2ParamParameter() {
		# ["value1", "value2"]
	}
	
}