package io.tapirtest.junit5executiontest.expectation

import com.google.common.collect.ImmutableList
import com.google.common.collect.ImmutableList.Builder
import de.bmiag.tapir.executiontest.expectation.execution.ComparableThrowable
import java.util.Optional
import org.junit.platform.engine.TestExecutionResult
import org.junit.platform.engine.UniqueId
import org.junit.platform.launcher.TestExecutionListener
import org.junit.platform.launcher.TestIdentifier
import java.util.function.Supplier
import io.tapirtest.junit5executiontest.JUnit5TestUtil

class EventCatchingExecutionListener implements TestExecutionListener {

	Builder<ComparabaleTestExecutionEvent> eventListBuilder = ImmutableList.builder

	override executionStarted(TestIdentifier testIdentifier) {

		addEvent(testIdentifier) [
			ComparabaleTestExecutionEvent.build [
				uniqueId = UniqueId.parse(testIdentifier.uniqueId)
				type = EventType.STARTED
			]

		]
	}

	override executionFinished(TestIdentifier testIdentifier, TestExecutionResult testExecutionResult) {
		addEvent(testIdentifier) [
			ComparabaleTestExecutionEvent.build [
				uniqueId = UniqueId.parse(testIdentifier.uniqueId)
				type = switch testExecutionResult.status {
					case SUCCESSFUL: EventType.FINISHED
					case FAILED: EventType.FAILED
					case ABORTED: EventType.ABORTED
				}
				comparableThrowable = testExecutionResult.throwable.toComparable
			]

		]
	}

	override executionSkipped(TestIdentifier testIdentifier, String reason) {
		addEvent(testIdentifier) [
			ComparabaleTestExecutionEvent.build [
				uniqueId = UniqueId.parse(testIdentifier.uniqueId)
				type = EventType.SKIPPED
			]
		]
	}

	def private addEvent(TestIdentifier testIdentifier, Supplier<ComparabaleTestExecutionEvent> eventSupplier) {
		if (UniqueId.parse(testIdentifier.uniqueId).engineId == JUnit5TestUtil.TAPIR_ENGINE_UID.engineId) {
			eventListBuilder.add(eventSupplier.get)
		}
	}

	def Optional<ComparableThrowable> toComparable(Optional<Throwable> throwableOptional) {
		throwableOptional.map [ throwable |
			ComparableThrowable.build [
				throwableClass = throwable.class
				message = throwable.message
			]
		]
	}

	def ImmutableList<ComparabaleTestExecutionEvent> getEvents() {
		eventListBuilder.build
	}

}
