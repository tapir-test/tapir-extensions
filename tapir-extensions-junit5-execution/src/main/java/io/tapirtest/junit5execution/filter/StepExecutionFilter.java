package io.tapirtest.junit5execution.filter;

import java.util.HashSet;
import java.util.Set;
import java.util.function.BiPredicate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import de.bmiag.tapir.execution.executor.StepExecutionInvocationHandler;
import de.bmiag.tapir.execution.model.TestClass;
import de.bmiag.tapir.execution.model.TestStep;

/**
 * The {@code StepExecutionFilter} skips a {@link TestStep} execution if the predicate supplied by
 * {@link TestStepFilterPredicateSupplier} returns false.
 * 
 * Notice: Whenever at least on e step in a test class is proceeded all subsequent test steps are proceeded as well.
 * 
 * @see TestStepFilterPredicateSupplier
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Component
public class StepExecutionFilter implements StepExecutionInvocationHandler {

    @Autowired
    private TestStepFilterPredicateSupplier filterPredicateSupplier;

    @Autowired
    private ApplicationContext applicationContext;

    private Set<TestClass> handledTestClasses = new HashSet<>( );

    @Override
    public Result handlePreInvoke( TestStep testStep, Object testInstance ) {

        final BiPredicate<TestStep, ApplicationContext> filterPredicate = filterPredicateSupplier.get( );
        final TestClass testClass = testStep.getParentTestClass( );
        if ( handledTestClasses.contains( testClass ) ) {
            return Result.PROCEED;
        }
        if ( filterPredicate.test( testStep, applicationContext ) ) {
            handledTestClasses.add( testClass );
            return Result.PROCEED;
        } else {
            return Result.SKIP;
        }
    }

    @Override
    public void handlePostInvoke( TestStep testStep, Object testInstance ) {
        // do nothing
    }

}
