package io.tapirtest.junit5execution;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.platform.engine.DiscoverySelector;
import org.junit.platform.engine.EngineDiscoveryRequest;
import org.junit.platform.engine.EngineExecutionListener;
import org.junit.platform.engine.ExecutionRequest;
import org.junit.platform.engine.TestDescriptor;
import org.junit.platform.engine.TestEngine;
import org.junit.platform.engine.TestExecutionResult;
import org.junit.platform.engine.UniqueId;
import org.junit.platform.engine.support.descriptor.EngineDescriptor;

import de.bmiag.tapir.bootstrap.TapirBootstrapper;
import de.bmiag.tapir.execution.TapirExecutor;
import de.bmiag.tapir.execution.plan.ExecutionPlanBuilder;
import io.tapirtest.junit5execution.descriptor.ExecutableTestDescriptorBuilder;
import io.tapirtest.junit5execution.descriptor.TapirExecutableTestDescriptor;
import io.tapirtest.junit5execution.discovery.JUnitExecutionDescriptionBuilder;

/**
 * Main JUnit5 entry point. The {@code TapirJUnit5TestEngine} offers the possibility to discover and execute tapir tests. It's
 * more or less a mapping from the JUnit5 API to the tapir API. The discovery relies on the execution plan which is built by
 * {@link ExecutionPlanBuilder} and the execution is delegated to {@link TapirExecutor}.
 * 
 * @see ExecutionPlanBuilder
 * @see TapirExecutor
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 * 
 */
public class TapirJUnit5TestEngine implements TestEngine {

    private static final String TAPIR_ENGINE_NAME = "tapir";

    private static final Logger LOGGER = LogManager.getLogger( TapirJUnit5TestEngine.class );

    @Override
    public String getId( ) {
        return TAPIR_ENGINE_NAME;
    }

    @Override
    public TestDescriptor discover( EngineDiscoveryRequest discoveryRequest, UniqueId uniqueId ) {
        EngineDescriptor engineDescriptor = new EngineDescriptor( uniqueId, TAPIR_ENGINE_NAME );
        final JUnitExecutionDescriptionBuilder executionDescriptionBuilder = new JUnitExecutionDescriptionBuilder( );

        discoveryRequest.getSelectorsByType( DiscoverySelector.class ).stream( )
                .flatMap( executionDescriptionBuilder::buildExecutionDescriptionStream )
                .map( executionDescription -> TapirBootstrapper.bootstrap( executionDescription.getBootstrapClass( ) ).getBean( ExecutableTestDescriptorBuilder.class ).buildExecutableTestDescriptor( executionDescription, engineDescriptor.getUniqueId( ) ) )
                .forEach( engineDescriptor::addChild );

        return engineDescriptor;
    }

    @Override
    public void execute( ExecutionRequest request ) {
        TestDescriptor engineDescriptor = request.getRootTestDescriptor( );
        EngineExecutionListener engineExecutionListener = request.getEngineExecutionListener( );

        engineExecutionListener.executionStarted( engineDescriptor );
        for ( TestDescriptor testDescriptor : engineDescriptor.getChildren( ) ) {
            if ( testDescriptor instanceof TapirExecutableTestDescriptor ) {
                ( ( TapirExecutableTestDescriptor ) testDescriptor ).execute( engineExecutionListener );
            } else {
                LOGGER.warn( ( ) -> "The TestDescriptor is not an instance of " + TapirExecutableTestDescriptor.class.getName( ) + ": ignored!" );
            }
        }
        engineExecutionListener.executionFinished( engineDescriptor, TestExecutionResult.successful( ) );
    }

}
