package io.tapirtest.junit5execution.discovery

import de.bmiag.tapir.execution.annotations.suite.TestSuite
import de.bmiag.tapir.execution.annotations.testclass.TestClass
import java.util.function.Predicate

import static extension org.junit.platform.commons.support.AnnotationSupport.*
import static extension org.junit.platform.commons.util.ReflectionUtils.*

/**
 * The {@code TestContainerPredicate} identifies a Java class as an executable tapir test class or suite.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
class TestContainerPredicate implements Predicate<Class<?>> {

	public static final Predicate<Class<?>> INSTANCE = new TestContainerPredicate

	private new() {
	}

	override test(Class<?> candidate) {
		if(candidate.abstract || !candidate.public) {
			return false
		}
		candidate.isAnnotated(TestSuite) || candidate.isAnnotated(TestClass)
	}

}
