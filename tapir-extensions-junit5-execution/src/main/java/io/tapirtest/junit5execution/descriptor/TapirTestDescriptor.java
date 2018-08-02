package io.tapirtest.junit5execution.descriptor;

import org.junit.platform.engine.TestSource;
import org.junit.platform.engine.UniqueId;
import org.junit.platform.engine.support.descriptor.AbstractTestDescriptor;

/**
 * The {@code TapirTestDescriptor} describes a container or a test which is discovered by the test engine.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
public class TapirTestDescriptor extends AbstractTestDescriptor {

    private final Type type;

    public TapirTestDescriptor( UniqueId uniqueId, String displayName, TestSource source, Type type ) {
        super( uniqueId, displayName, source );
        this.type = type;
    }

    @Override
    public Type getType( ) {
        return type;
    }

}
