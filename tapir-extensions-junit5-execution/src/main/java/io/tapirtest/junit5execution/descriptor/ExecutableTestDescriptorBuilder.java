package io.tapirtest.junit5execution.descriptor;

import java.util.function.BiPredicate;

import org.junit.platform.engine.UniqueId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;

import de.bmiag.tapir.execution.TapirExecutor;
import de.bmiag.tapir.execution.TapirExecutor.TapirExecutorFactory;
import de.bmiag.tapir.execution.model.ExecutionPlan;
import de.bmiag.tapir.execution.model.TestStep;
import io.tapirtest.junit5execution.descriptor.TestDescriptorBuilder;
import io.tapirtest.junit5execution.discovery.JUnitExecutionDescription;
import io.tapirtest.junit5execution.filter.TestStepFilterPredicateSupplier;

@Component
public class ExecutableTestDescriptorBuilder {

    @Autowired
    private TapirExecutorFactory tapirExecutorFactory;

    @Autowired
    private ConfigurableApplicationContext applicationContext;

    @Autowired
    private TestDescriptorBuilder testDescriptorBuilder;

    public TapirExecutableTestDescriptor buildExecutableTestDescriptor( final JUnitExecutionDescription executionDescription, final UniqueId parentUniqueId ) {
        final TapirExecutor tapirExecutor = tapirExecutorFactory.getExecutorForClass( executionDescription.getBootstrapClass( ) );
        final ExecutionPlan executionPlan = tapirExecutor.getExecutionPlan( );
        final BiPredicate<TestStep, ApplicationContext> testStepFilterPredicate = executionDescription.getTestStepFilterPredicate( );
        TestStepFilterPredicateSupplier testStepFilterPredicateSupplier = applicationContext.getBean( TestStepFilterPredicateSupplier.class );
        testStepFilterPredicateSupplier.set( testStepFilterPredicate );

        return testDescriptorBuilder.buildExecutableTestDescriptor( executionPlan, parentUniqueId, tapirExecutor, applicationContext );
    }
}
