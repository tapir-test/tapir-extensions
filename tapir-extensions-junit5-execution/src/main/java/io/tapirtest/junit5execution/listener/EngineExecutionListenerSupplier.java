package io.tapirtest.junit5execution.listener;

import java.util.Optional;
import java.util.function.Supplier;

import org.junit.platform.engine.EngineExecutionListener;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

/**
 * The {@code EngineExecutionListenerSupplier} works as a holder for a {@link EngineExecutionListener}. It's registered up-front
 * in the Spring {@link ApplicationContext}, but the {@link EngineExecutionListener} is provided when is available (in the
 * execution phase).
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Component
public class EngineExecutionListenerSupplier implements Supplier<Optional<EngineExecutionListener>> {

    private Optional<EngineExecutionListener> engineExecutionListener = Optional.empty( );

    public void set( EngineExecutionListener engineExecutionListener ) {
        this.engineExecutionListener = Optional.of( engineExecutionListener );
    }

    @Override
    public Optional<EngineExecutionListener> get( ) {
        return engineExecutionListener;
    }

}
