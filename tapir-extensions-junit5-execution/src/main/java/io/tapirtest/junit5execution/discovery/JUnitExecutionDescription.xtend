package io.tapirtest.junit5execution.discovery

import de.bmiag.tapir.data.Immutable
import de.bmiag.tapir.execution.model.TestStep
import java.util.function.BiPredicate
import org.springframework.context.ApplicationContext

/**
 * The {@code JUnitExecutionDescription} is an immutable type contains the information which is required to bootstrap a single
 * tapir test run. Beside the {@link #bootstrapClass} a {@link #testStepFilterPredicate} is included.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Immutable
class JUnitExecutionDescription {
	/**
	 * The Java class which is used for bootstrapping the execution.
	 */
	Class<?> bootstrapClass

    /**
     * Based on the given {@code TestStep} and {@link ApplicationContext}, test steps can be skipped. Notice that whenever a
     * test step is executed all subsequent test steps are executed as well.
     */
	BiPredicate<TestStep, ApplicationContext> testStepFilterPredicate = [true]

}
