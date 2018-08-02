package io.tapirtest.junit5executiontest.expectation

import de.bmiag.tapir.data.Immutable
import java.util.Optional
import org.junit.platform.engine.TestDescriptor.Type
import org.junit.platform.engine.TestSource
import java.util.List
import org.junit.platform.engine.UniqueId

@Immutable
class ComparableTestIdentifier {
	
	UniqueId uniqueId
	String displayName
	Optional<TestSource> source
	Type type
	List<ComparableTestIdentifier> children
	
}