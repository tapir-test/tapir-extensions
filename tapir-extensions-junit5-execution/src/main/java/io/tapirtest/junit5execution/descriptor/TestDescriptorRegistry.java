package io.tapirtest.junit5execution.descriptor;

import java.util.Map;
import java.util.Optional;

import org.junit.platform.engine.TestDescriptor;
import org.springframework.stereotype.Component;

import com.google.common.collect.Maps;

import de.bmiag.tapir.execution.model.ExecutionModelElement;

/**
 * The {@code TestDescriptorRegistry} holds a mapping from {@link ExecutionModelElement} to {@link TestDescriptor}. Mappings are
 * registered via {@link #registerTestDescriptor(ExecutionModelElement, TestDescriptor)} and read via
 * {@link #getTestDescriptor(ExecutionModelElement)}.
 * 
 * As there might be artificial {@link TestDescriptor test descriptors} which are not reported to JUnit,
 * {@link #getTestDescriptor(ExecutionModelElement)} returns an {@link Optional}.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Component
public class TestDescriptorRegistry {

    private final Map<ExecutionModelElement, TestDescriptor> map = Maps.newIdentityHashMap( );

    /**
     * Registers a mapping between the given {@code executionModelElement} and the given {@code testDescriptor}.
     * 
     * @param executionModelElement
     *            The execution model element
     * @param testDescriptor
     *            The test descriptor
     * 
     * @since 1.0.0
     */
    public void registerTestDescriptor( ExecutionModelElement executionModelElement, TestDescriptor testDescriptor ) {
        map.put( executionModelElement, testDescriptor );
    }

    /**
     * Returns the {@link TestDescriptor} for the given {@link ExecutionModelElement}. This might be not present.
     * 
     * @param executionModelElement
     *            The execution model element
     * @return The mapped test descriptor
     * 
     * @since 1.0.0
     */
    public Optional<TestDescriptor> getTestDescriptor( ExecutionModelElement executionModelElement ) {
        return Optional.ofNullable( map.get( executionModelElement ) );
    }

}
