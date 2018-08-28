package io.tapirtest.allure2

import de.bmiag.tapir.execution.attachment.Attachment
import de.bmiag.tapir.execution.attachment.AttachmentListener
import de.bmiag.tapir.execution.executor.AbstractExecutionListener
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.StructuralElement
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestParameter
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import io.qameta.allure.Allure
import io.qameta.allure.AllureLifecycle
import io.qameta.allure.model.Label
import io.qameta.allure.model.Link
import io.qameta.allure.model.Parameter
import io.qameta.allure.model.Status
import io.qameta.allure.model.StepResult
import io.qameta.allure.model.TestResult
import io.qameta.allure.util.ResultsUtils
import java.util.Optional
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.Logger
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

/**
 * The {@code Allure2ExecutionListener} a adapter which passes the events which occur while executing the tapir execution plan
 * to Allure 2.
 * 
 * @author Oliver Libutzki {@literal <}oliver.libutzki@libutzki.de{@literal >}
 * 
 * @since 1.0.0
 */
@Component("tapirAllure2ExecutionListener")
@Order(7000)
class Allure2ExecutionListener extends AbstractExecutionListener implements AttachmentListener {

	extension AllureLifecycle lifecycle = Allure.lifecycle

	static final Logger LOGGER = LogManager.getLogger(Allure2ExecutionListener)

	override suiteStarted(TestSuite testSuite) {
		LOGGER.debug['''TestSuite «testSuite.name» started''']
	}

	override suiteSucceeded(TestSuite testSuite) {
		LOGGER.debug['''TestSuite «testSuite.name» succeeded''']
	}

	override suiteFailed(TestSuite testSuite, Throwable throwable) {
		LOGGER.debug['''TestSuite «testSuite.name» failed''']
	}

	override suiteSkipped(TestSuite testSuite) {
		LOGGER.debug['''TestSuite «testSuite.name» skipped''']
	}

	override classStarted(TestClass testClass) {
		LOGGER.debug['''TestClass «testClass.name» started''']
		testClassStarted(testClass)

	}

	override classSucceeded(TestClass testClass) {
		LOGGER.debug['''TestClass «testClass.name» succeeded''']
		val uuid = testClass.UUID
		updateTestCase(uuid, [
			status = Status.PASSED
		])
		testClass.testClassFinished
	}

	override classFailed(TestClass testClass, Throwable throwable) {
		LOGGER.debug['''TestClass «testClass.name» failed''']
		val uuid = testClass.UUID
		updateTestCase(uuid, [
			status = ResultsUtils.getStatus(throwable).orElse(null)
			statusDetails = ResultsUtils.getStatusDetails(throwable).orElse(null)

		])
		testClass.testClassFinished
	}

	override classSkipped(TestClass testClass) {
		LOGGER.debug['''TestClass «testClass.name» skipped''']
		val uuid = testClass.UUID
		updateTestCase(uuid, [
			status = Status.SKIPPED

		])
		testClass.testClassFinished
	}

	override stepStarted(TestStep testStep) {
		LOGGER.debug['''TestStep «testStep.name» started''']
		val stepResult = new StepResult
		stepResult.name = testStep.title.orElse(testStep.name)
		testStep.description.ifPresent [
			stepResult.description = it
		]
		stepResult.parameters += testStep.parameters.map[mapParameter]
		startStep(testStep.parentTestClass.UUID, testStep.UUID, stepResult)
	}

	override stepSucceeded(TestStep testStep) {
		LOGGER.debug['''TestStep «testStep.name» succeeded''']
		val uuid = testStep.UUID
		updateStep(uuid, [
			status = Status.PASSED
		])
		testStep.testStepFinished
	}

	override stepFailed(TestStep testStep, Throwable throwable) {
		LOGGER.debug['''TestStep «testStep.name» failed''']
		val uuid = testStep.UUID
		updateStep(uuid, [
			status = ResultsUtils.getStatus(throwable).orElse(null)
			statusDetails = ResultsUtils.getStatusDetails(throwable).orElse(null)

		])
		testStep.testStepFinished
	}

	override stepSkipped(TestStep testStep) {
		LOGGER.debug['''TestStep «testStep.name» skipped''']
		val uuid = testStep.UUID
		updateStep(uuid, [
			status = Status.SKIPPED

		])
		testStep.testStepFinished
	}

	def private Parameter mapParameter(TestParameter testParameter) {
		val parameter = new Parameter()
		parameter.name = testParameter.name
		parameter.value = testParameter.label ?: testParameter.value.toString
		parameter
	}

	def private Link mapIssue(String issueNumber) {
		ResultsUtils.createTmsLink(issueNumber)
	}

	def private void testClassStarted(TestClass testClass) {
		val uuid = testClass.UUID
		val testResult = new TestResult
		testResult.uuid = uuid
		testResult.name = testClass.title.orElse(testClass.name)
		testResult.fullName = testClass.javaClass.name
		testClass.description.ifPresent [
			testResult.description = it
		]

		testResult.parameters += testClass.parameters.map[mapParameter]
		testClass.nextUnartificialParentSuite.ifPresent [ parentSuite1 |
			testResult.labels += createLabel(AllureLabel.SUB_SUITE, parentSuite1.title.orElse(parentSuite1.name))
			parentSuite1.nextUnartificialParentSuite.ifPresent [ parentSuite2 |
				testResult.labels += createLabel(AllureLabel.SUITE, parentSuite2.title.orElse(parentSuite2.name))
				parentSuite2.nextUnartificialParentSuite.ifPresent [ parentSuite3 |
					testResult.labels +=
						createLabel(AllureLabel.PARENT_SUITE, parentSuite3.title.orElse(parentSuite3.name))
				]
			]
		]
		testResult.links += testClass.issues.map[mapIssue]
		testResult.labels += createLabel(AllureLabel.PACKAGE, testClass.javaClass.package.name)
		testResult.labels += createLabel(AllureLabel.TEST_CLASS, testClass.javaClass.name)
		testResult.labels += createLabel(AllureLabel.HOST, ResultsUtils.hostName)
		testResult.labels += createLabel(AllureLabel.THREAD, ResultsUtils.threadName)
		testResult.labels += createLabel(AllureLabel.FRAMEWORK, "tapir")
		testResult.labels += createLabel(AllureLabel.LANGUAGE, "Java")
		testResult.labels += createLabel(AllureLabel.LANGUAGE, "Xtend")
		testResult.labels += testClass.tags.map [ tag |
			createLabel(AllureLabel.TAG, tag)
		]
		scheduleTestCase(testResult)
		startTestCase(uuid)
	}

	def private Label createLabel(AllureLabel label, String value) {
		new Label => [
			name = label.value
			it.value = value
		]
	}

	def private Optional<TestSuite> getNextUnartificialParentSuite(StructuralElement structuralElement) {
		val parent = structuralElement.parent
		switch parent {
			TestSuite: {
				if (parent.artificial) {
					parent.nextUnartificialParentSuite
				} else {
					Optional.of(parent)
				}
			}
			default:
				Optional.empty
		}
	}

	def private testClassFinished(TestClass testClass) {
		val uuid = testClass.UUID

		stopTestCase(uuid)
		writeTestCase(uuid)
	}

	def private testStepFinished(TestStep testStep) {
		val uuid = testStep.UUID
		stopStep(uuid)
	}

	def protected getUUID(Identifiable identifiable) {
		identifiable.id.toString
	}

	override attachmentAdded(TestStep testStep, Attachment attachment) {
		addAttachment(attachment.name, attachment.mimeType.toString, null, attachment.content)
	}

}
