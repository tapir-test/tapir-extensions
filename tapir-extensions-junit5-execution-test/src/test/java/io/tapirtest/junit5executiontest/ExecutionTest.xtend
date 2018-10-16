package io.tapirtest.junit5executiontest

import com.google.common.collect.ImmutableList
import com.google.common.collect.ImmutableList.Builder
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.executiontest.expectation.execution.ComparableThrowable
import io.tapirtest.junit5executiontest.data.TestClassIteratedParameterizedStep
import io.tapirtest.junit5executiontest.data.TestClassParameterizedStep
import io.tapirtest.junit5executiontest.data.TestClassSimpleStep
import io.tapirtest.junit5executiontest.data.TestClassWithException
import io.tapirtest.junit5executiontest.expectation.ComparabaleTestExecutionEvent
import io.tapirtest.junit5executiontest.expectation.EventCatchingExecutionListener
import java.util.List
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.junit.jupiter.api.Test
import org.junit.platform.engine.UniqueId
import org.junit.platform.engine.discovery.DiscoverySelectors
import org.junit.platform.launcher.core.LauncherDiscoveryRequestBuilder
import org.junit.platform.launcher.core.LauncherFactory

import static io.tapirtest.junit5executiontest.expectation.EventType.*
import static org.assertj.core.api.Assertions.*

import static extension io.tapirtest.junit5executiontest.JUnit5TestUtil.*
import io.tapirtest.junit5executiontest.data.IteratedTestClass
import de.bmiag.tapir.execution.model.TestSuite

class ExecutionTest {

	def void executionTest(Class<?> testClass, List<ComparabaleTestExecutionEvent> expectedEvents) {

		val launcher = LauncherFactory.create
		val request = LauncherDiscoveryRequestBuilder.request.selectors(DiscoverySelectors.selectClass(testClass)).build

		val listener = new EventCatchingExecutionListener

		launcher.execute(request, listener)
		assertThat(expectedEvents).containsExactly(listener.events)

	}

	def private ImmutableList<ComparabaleTestExecutionEvent> buildEvents(
		Procedure1<ImmutableList.Builder<ComparabaleTestExecutionEvent>> eventListBuilder) {
		val builder = ImmutableList.builder
		builder.add(ComparabaleTestExecutionEvent.build [
			uniqueId = TAPIR_ENGINE_UID
			type = STARTED
		])
		eventListBuilder.apply(builder)
		builder.add(ComparabaleTestExecutionEvent.build [
			uniqueId = TAPIR_ENGINE_UID
			type = FINISHED
		])
		builder.build
	}

	@Test
	def void testSimpleStep() {
		val testClassUID = TAPIR_ENGINE_UID.append(TestClass.simpleName, TestClassSimpleStep.name)
		val step1UID = testClassUID.append(TestStep.simpleName, "step1")
		val expectedEvents = buildEvents[
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = STARTED
			])
			addFinishedStep(step1UID)
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = FINISHED
			])

		]
		executionTest(TestClassSimpleStep, expectedEvents)
	}

	@Test
	def void testParameterizedStep() {
		val testClassUID = TAPIR_ENGINE_UID.append(TestClass.simpleName, TestClassParameterizedStep.name)
		val step1UID = testClassUID.append(TestStep.simpleName, '''step1(«String.name»)''')
		val step2UID = testClassUID.append(TestStep.simpleName, '''step2(«String.name»,«String.name»)''')
		val expectedEvents = buildEvents[
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = STARTED
			])
			addFinishedStep(step1UID)
			addFinishedStep(step2UID)
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = FINISHED
			])

		]
		executionTest(TestClassParameterizedStep, expectedEvents)
	}

	@Test
	def void testIteratedParameterizedStep() {
		val testClassUID = TAPIR_ENGINE_UID.append(TestClass.simpleName, TestClassIteratedParameterizedStep.name)
		val step1UID = testClassUID.append(TestStep.simpleName, '''step1(«String.name»)''')
		val step2UID = testClassUID.append(TestStep.simpleName, '''step2(«String.name»,«String.name»)''')
		val expectedEvents = buildEvents[
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = STARTED
			])
			addFinishedStep(step1UID.append("TestStepInvocation", "#0"))
			addFinishedStep(step1UID.append("TestStepInvocation", "#1"))
			addFinishedStep(step2UID.append("TestStepInvocation", "#0"))
			addFinishedStep(step2UID.append("TestStepInvocation", "#1"))
			addFinishedStep(step2UID.append("TestStepInvocation", "#2"))
			addFinishedStep(step2UID.append("TestStepInvocation", "#3"))
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = FINISHED
			])

		]
		executionTest(TestClassIteratedParameterizedStep, expectedEvents)
	}

	@Test
	def void testStepWithException() {
		val testClassUID = TAPIR_ENGINE_UID.append(TestClass.simpleName, TestClassWithException.name)
		val step1UID = testClassUID.append(TestStep.simpleName, "step1")
		val step2UID = testClassUID.append(TestStep.simpleName, "step2")
		val expectedEvents = buildEvents[
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = STARTED
			])
			val throwable = ComparableThrowable.build [
				throwableClass = AssertionError
				message = "step1 failed"
			]
			addFailedStep(step1UID, throwable)
			addSkippedStep(step2UID)

			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = FAILED
				it.comparableThrowable = throwable
			])

		]
		executionTest(TestClassWithException, expectedEvents)
	}

	@Test
	def void testIteratedClass() {
		val testClassUID = TAPIR_ENGINE_UID.append(TestSuite.simpleName, IteratedTestClass.name)
		val value1UID = testClassUID.append(TestClass.simpleName, IteratedTestClass.name).append("TestClassInvocation", "#0")
		val value2UID = testClassUID.append(TestClass.simpleName, IteratedTestClass.name).append("TestClassInvocation", "#1")
		val value1Step2UID = value1UID.append(TestStep.simpleName, '''step2(«String.name»)''')
		val value2Step2UID = value2UID.append(TestStep.simpleName, '''step2(«String.name»)''')
		val expectedEvents = buildEvents[
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = STARTED
			])
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = value1UID
				type = STARTED
			])
			addFinishedStep(value1UID.append(TestStep.simpleName, '''step1'''))
			addFinishedStep(value1Step2UID.append("TestStepInvocation", "#0"))
			addFinishedStep(value1Step2UID.append("TestStepInvocation", "#1"))
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = value1UID
				type = FINISHED
			])
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = value2UID
				type = STARTED
			])
			addFinishedStep(value2UID.append(TestStep.simpleName, '''step1'''))
			addFinishedStep(value2Step2UID.append("TestStepInvocation", "#0"))
			addFinishedStep(value2Step2UID.append("TestStepInvocation", "#1"))
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = value2UID
				type = FINISHED
			])
			add(ComparabaleTestExecutionEvent.build [
				uniqueId = testClassUID
				type = FINISHED
			])

		]
		executionTest(IteratedTestClass, expectedEvents)
	}

	def private addFinishedStep(Builder<ComparabaleTestExecutionEvent> listBuilder, UniqueId uniqueId) {
		listBuilder.add(ComparabaleTestExecutionEvent.build [
			it.uniqueId = uniqueId
			type = STARTED
		])
		listBuilder.add(ComparabaleTestExecutionEvent.build [
			it.uniqueId = uniqueId
			type = FINISHED
		])
	}

	def private addSkippedStep(Builder<ComparabaleTestExecutionEvent> listBuilder, UniqueId uniqueId) {
		listBuilder.add(ComparabaleTestExecutionEvent.build [
			it.uniqueId = uniqueId
			type = SKIPPED
		])
	}

	def private addFailedStep(Builder<ComparabaleTestExecutionEvent> listBuilder, UniqueId uniqueId,
		ComparableThrowable comparableThrowable) {
		listBuilder.add(ComparabaleTestExecutionEvent.build [
			it.uniqueId = uniqueId
			type = STARTED
		])
		listBuilder.add(ComparabaleTestExecutionEvent.build [
			it.uniqueId = uniqueId
			type = FAILED
			it.comparableThrowable = comparableThrowable
		])
	}

}
