package io.tapirtest.junit5execution.discovery

import de.bmiag.tapir.execution.annotations.step.Step
import java.lang.reflect.Method
import java.util.function.Predicate

import static extension org.junit.platform.commons.support.AnnotationSupport.*
import static extension org.junit.platform.commons.util.ReflectionUtils.*

/**
 * The {@code TestStepPredicate} identifies a Java method as an executable tapir test tsep
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
class TestStepPredicate implements Predicate<Method> {

	public static final Predicate<Method> INSTANCE = new TestStepPredicate

	private new() {
	}

	override test(Method candidate) {
		if(!candidate.public) {
			return false
		}
		candidate.isAnnotated(Step)
	}

}
