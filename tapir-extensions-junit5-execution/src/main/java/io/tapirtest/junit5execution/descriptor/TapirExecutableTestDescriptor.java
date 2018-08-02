package io.tapirtest.junit5execution.descriptor;

import org.junit.platform.engine.EngineExecutionListener;
import org.junit.platform.engine.TestDescriptor;
import org.junit.platform.engine.TestSource;
import org.junit.platform.engine.UniqueId;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;

import de.bmiag.tapir.execution.TapirExecutor;
import io.tapirtest.junit5execution.listener.EngineExecutionListenerSupplier;

/**
 * The {@code TapirExecutableTestDescriptor} is a {@link TestDescriptor} which holds the {@link TapirExecutor} and Spring's
 * {@link ApplicationContext}. It fulfills the JUnit API as {@code TapirExecutableTestDescriptor} contains all the information
 * which is required in order to execute tapir tests.
 * 
 * @see TapirExecutor
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
public class TapirExecutableTestDescriptor extends TapirTestDescriptor {

    private final TapirExecutor tapirExecutor;
    private final ConfigurableApplicationContext applicationContext;

    public TapirExecutableTestDescriptor( UniqueId uniqueId, String displayName, TestSource source, TapirExecutor tapirExecutor, ConfigurableApplicationContext applicationContext ) {
        super( uniqueId, displayName, source, Type.CONTAINER );
        this.tapirExecutor = tapirExecutor;
        this.applicationContext = applicationContext;
    }

    /**
     * Executes the tests by calling {@link TapirExecutor#execute()}. The given {@code engineExecutionListener} is passed to the
     * {@link EngineExecutionListenerSupplier} in order to report the test results to JUnit.
     * 
     * @param engineExecutionListener
     *            The {@link EngineExecutionListener} to which tapir should report its results.
     */
    public void execute( final EngineExecutionListener engineExecutionListener ) {
        final EngineExecutionListenerSupplier engineExecutionListenerSupplier = applicationContext.getBean( EngineExecutionListenerSupplier.class );
        engineExecutionListenerSupplier.set( engineExecutionListener );
        try {
            tapirExecutor.execute( );
        } finally {
            applicationContext.close( );
        }
    }

}
