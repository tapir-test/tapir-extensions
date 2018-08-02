package io.tapirtest.junit5executiontest.expectation

import de.bmiag.tapir.data.Immutable
import de.bmiag.tapir.executiontest.expectation.execution.ComparableThrowable
import java.util.Optional
import org.junit.platform.engine.UniqueId

@Immutable
class ComparabaleTestExecutionEvent {

	UniqueId uniqueId
	
	EventType type
	
	Optional<ComparableThrowable> comparableThrowable

}
