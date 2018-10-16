package io.tapirtest.junit5execution.descriptor

import de.bmiag.tapir.execution.model.ExecutionModelElement
import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import org.junit.platform.engine.UniqueId
import org.springframework.stereotype.Component

/**
 * The {@code UniqueIdCalculator} is responsible for building {@link UniqueId unique ids}. It usually does so by append the
 * simple name of {@link ExecutionModelElement} type and the name of the element. For steps/methods the behaviour is a little
 * bit different as a digest is calculated for the parameters (if present).
 * 
 * @see UniqueId
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Component
class UniqueIdCalculator {

	/**
	 * Returns a {@link UniqueId} for the given {@code executionModelElement}.
	 * 
	 * @param executionModelElement
	 *            The {@link ExecutionModelElement} which's {@link UniqueId} is calculated
	 * @param parentUniqueId
	 *            The parent's {@link UniqueId}
	 * @return The {@link UniqueId} of the given {@code executionModelElement}
	 * 
	 * @since 1.0.0
	 */
	def UniqueId calculateUniqueId(ExecutionModelElement executionModelElement, UniqueId parentUniqueId) {
		executionModelElement.calculateId(parentUniqueId)
	}

	def dispatch UniqueId calculateId(ExecutionPlan executionPlan, UniqueId parentUniqueId) {
		parentUniqueId.append("ExecutionPlan", "ExecutionPlan")
	}

	def dispatch UniqueId calculateId(TestClass testClass, UniqueId parentUniqueId) {
		val testClassUniqueId = parentUniqueId.append("TestClass", testClass.name)
		if (!testClass.parameters.empty) {
			testClassUniqueId.append("TestClassInvocation", '''#«testClass.invocationIndex»''')
		} else {
			testClassUniqueId
		}
	}

	def dispatch UniqueId calculateId(TestSuite testSuite, UniqueId parentUniqueId) {
		parentUniqueId.append("TestSuite", testSuite.name)
	}

	def dispatch UniqueId calculateId(TestStep testStep, UniqueId parentUniqueId) {
		if (testStep.isArtificialStep || !testStep.hasMultipleInvocations) {
			val javaMethod = testStep.javaMethod
			parentUniqueId.append("TestStep", '''«testStep.name»«IF !javaMethod.parameterTypes.empty»(«FOR paramType : javaMethod.parameterTypes SEPARATOR ","»«paramType.name»«ENDFOR»)«ENDIF»''')
		} else {
			parentUniqueId.append("TestStepInvocation", '''#«testStep.invocationIndex»''')
		}
	}
	
	def private getInvocationIndex(TestClass testClass) {
		testClass.parent.children.indexOf(testClass)
	}
	
	def private hasMultipleInvocations(TestStep testStep) {
		testStep.parentTestClass.steps.filter[javaMethod == testStep.javaMethod].size > 1
	}
	
	def private isArtificialStep(TestStep testStep) {
		!testStep.parentTestClass.steps.contains(testStep)
	}
	
	def private getInvocationIndex(TestStep testStep) {
		testStep.parentTestClass.steps.filter[javaMethod == testStep.javaMethod].toList.indexOf(testStep)
	}

}
