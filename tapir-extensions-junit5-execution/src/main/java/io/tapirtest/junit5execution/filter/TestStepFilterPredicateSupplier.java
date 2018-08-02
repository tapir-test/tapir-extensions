package io.tapirtest.junit5execution.filter;

import java.util.function.BiPredicate;
import java.util.function.Supplier;

import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import de.bmiag.tapir.execution.model.TestStep;

/**
 * The {@code TestStepFilterPredicateSupplier} works as a holder for a filter predicate. It's registered up-front in the Spring
 * {@link ApplicationContext}, but the predicate is provided when is available (after the discovery phase).
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Component
public class TestStepFilterPredicateSupplier implements Supplier<BiPredicate<TestStep, ApplicationContext>> {

    private BiPredicate<TestStep, ApplicationContext> testStepFilterPredicate = ( x, y ) -> true;

    public void set( BiPredicate<TestStep, ApplicationContext> testStepFilterPredicate ) {
        this.testStepFilterPredicate = testStepFilterPredicate;
    }

    @Override
    public BiPredicate<TestStep, ApplicationContext> get( ) {
        return testStepFilterPredicate;
    }

}
