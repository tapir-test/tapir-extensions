package io.tapirtest.junit5execution.listener;

import org.junit.platform.engine.EngineExecutionListener;
import org.junit.platform.engine.TestExecutionResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import de.bmiag.tapir.execution.executor.ExecutionListener;
import de.bmiag.tapir.execution.model.ExecutionModelElement;
import de.bmiag.tapir.execution.model.ExecutionPlan;
import de.bmiag.tapir.execution.model.TestClass;
import de.bmiag.tapir.execution.model.TestStep;
import de.bmiag.tapir.execution.model.TestSuite;
import io.tapirtest.junit5execution.descriptor.TestDescriptorRegistry;

/**
 * The {@code JUnit5ExecutionListener} is an adapter for tapir's {@link ExecutionListener} and JUnit's
 * {@link EngineExecutionListener}.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Component
public class JUnit5ExecutionListener implements ExecutionListener {

    @Autowired
    private EngineExecutionListenerSupplier engineExecutionListenerSupplier;

    @Autowired
    private TestDescriptorRegistry testDescriptorRegistry;

    @Override
    public void executionStarted( ExecutionPlan executionPlan ) {
        notifyStarted( executionPlan );
    }

    @Override
    public void executionSucceeded( ExecutionPlan executionPlan ) {
        notifySucceeded( executionPlan );
    }

    @Override
    public void executionFailed( ExecutionPlan executionPlan, Throwable throwable ) {
        notifyFailed( executionPlan, throwable );
    }

    @Override
    public void suiteStarted( TestSuite testSuite ) {
        notifyStarted( testSuite );

    }

    @Override
    public void suiteSucceeded( TestSuite testSuite ) {
        notifySucceeded( testSuite );

    }

    @Override
    public void suiteFailed( TestSuite testSuite, Throwable throwable ) {
        notifyFailed( testSuite, throwable );
    }

    @Override
    public void suiteSkipped( TestSuite testSuite ) {
        notifySkipped( testSuite );

    }

    @Override
    public void classStarted( TestClass testClass ) {
        notifyStarted( testClass );
    }

    @Override
    public void classSucceeded( TestClass testClass ) {
        notifySucceeded( testClass );
    }

    @Override
    public void classFailed( TestClass testClass, Throwable throwable ) {
        notifyFailed( testClass, throwable );
    }

    @Override
    public void classSkipped( TestClass testClass ) {
        notifySkipped( testClass );
    }

    @Override
    public void stepStarted( TestStep testStep ) {
        notifyStarted( testStep );
    }

    @Override
    public void stepSucceeded( TestStep testStep ) {
        notifySucceeded( testStep );
    }

    @Override
    public void stepFailed( TestStep testStep, Throwable throwable ) {
        notifyFailed( testStep, throwable );
    }

    @Override
    public void stepSkipped( TestStep testStep ) {
        notifySkipped( testStep );
    }

    private void notifyStarted( ExecutionModelElement executionModelElement ) {
        engineExecutionListenerSupplier.get( ).ifPresent( listener -> testDescriptorRegistry.getTestDescriptor( executionModelElement ).ifPresent( listener::executionStarted ) );
    }

    private void notifySucceeded( ExecutionModelElement executionModelElement ) {
        engineExecutionListenerSupplier.get( ).ifPresent( listener -> {
            testDescriptorRegistry.getTestDescriptor( executionModelElement ).ifPresent( testDescriptor -> listener.executionFinished( testDescriptor, TestExecutionResult.successful( ) ) );
        } );
    }

    private void notifyFailed( ExecutionModelElement executionModelElement, Throwable throwable ) {
        engineExecutionListenerSupplier.get( ).ifPresent( listener -> {
            testDescriptorRegistry.getTestDescriptor( executionModelElement ).ifPresent( testDescriptor -> listener.executionFinished( testDescriptor, TestExecutionResult.failed( throwable ) ) );
        } );
    }

    private void notifySkipped( ExecutionModelElement executionModelElement ) {
        engineExecutionListenerSupplier.get( ).ifPresent( listener -> {
            testDescriptorRegistry.getTestDescriptor( executionModelElement ).ifPresent( testDescriptor -> listener.executionSkipped( testDescriptor, null ) );
        } );
    }
}
