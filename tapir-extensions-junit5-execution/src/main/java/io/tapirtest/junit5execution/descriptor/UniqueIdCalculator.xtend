package io.tapirtest.junit5execution.descriptor

import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import de.bmiag.tapir.execution.model.TestParameter
import de.bmiag.tapir.execution.model.ExecutionModelElement
import org.springframework.util.DigestUtils
import org.junit.platform.engine.UniqueId
import de.bmiag.tapir.execution.model.ExecutionPlan
import org.springframework.stereotype.Component
import java.io.Serializable
import org.springframework.util.SerializationUtils

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
		parentUniqueId.append(executionModelElement.class.simpleName, executionModelElement.id)
	}

	def dispatch String getId(ExecutionPlan executionPlan) {
		"ExecutionPlan"
	}

	def dispatch String getId(TestClass testClass) {
		'''«testClass.name»«IF !testClass.parameters.empty»(«FOR param :  testClass.parameters SEPARATOR ","»«param.digest»«ENDFOR»)«ENDIF»'''
	}

	def dispatch String getId(TestSuite testSuite) {
		testSuite.name
	}

	def dispatch String getId(TestStep testStep) {
		'''«testStep.name»«IF !testStep.parameters.empty»(«FOR param :  testStep.parameters SEPARATOR ","»«param.digest»«ENDFOR»)«ENDIF»'''
	}

	def dispatch String getId(TestParameter testParameter) {
		testParameter.value.toString;
	}

	def private String getDigest(TestParameter testParameter) {
		val parameterValue = testParameter.value
		val bytes = switch parameterValue {
			String : parameterValue.getBytes("UTF-8")
			Serializable: SerializationUtils.serialize(parameterValue)
			default: parameterValue.toString.getBytes("UTF-8")
		}
		DigestUtils.md5DigestAsHex(bytes)
	}

}
