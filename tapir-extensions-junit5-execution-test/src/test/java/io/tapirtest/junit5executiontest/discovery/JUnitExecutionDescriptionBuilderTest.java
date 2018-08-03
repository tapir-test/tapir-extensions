package io.tapirtest.junit5executiontest.discovery;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.platform.engine.DiscoverySelector;
import org.junit.platform.engine.UniqueId;
import org.junit.platform.engine.discovery.DiscoverySelectors;

import io.tapirtest.junit5execution.discovery.JUnitExecutionDescription;
import io.tapirtest.junit5execution.discovery.JUnitExecutionDescriptionBuilder;
import io.tapirtest.junit5executiontest.data.IteratedTestClass;
import io.tapirtest.junit5executiontest.data.TestClassIteratedParameterizedStep;
import io.tapirtest.junit5executiontest.data.TestClassParameterizedStep;
import io.tapirtest.junit5executiontest.data.TestClassSimpleStep;
import io.tapirtest.junit5executiontest.data.TestClassWithException;

public class JUnitExecutionDescriptionBuilderTest {

    @ParameterizedTest( name = "{0}" )
    @MethodSource( "dataProvider" )
    void testDiscovery( DiscoverySelector discoverySelector, Class<?>[] expectedBootstrapClasses ) {
        final JUnitExecutionDescriptionBuilder jUnitExecutionDescriptionBuilder = new JUnitExecutionDescriptionBuilder( );
        final Set<Class<?>> bootstrapClasses = jUnitExecutionDescriptionBuilder.buildExecutionDescriptionStream( discoverySelector ).map( JUnitExecutionDescription::getBootstrapClass ).collect( Collectors.toSet( ) );
        assertThat( bootstrapClasses ).containsExactlyInAnyOrder( expectedBootstrapClasses );
    }

    static Stream<Arguments> dataProvider( ) {
        return Stream.of(
                Arguments.of( DiscoverySelectors.selectClass( TestClassSimpleStep.class ), toArray( TestClassSimpleStep.class ) ),
                Arguments.of( DiscoverySelectors.selectPackage( TestClassSimpleStep.class.getPackage( ).getName( ) ), toArray( TestClassIteratedParameterizedStep.class, TestClassParameterizedStep.class, TestClassSimpleStep.class, TestClassWithException.class, IteratedTestClass.class ) ),
                Arguments.of( DiscoverySelectors.selectUniqueId( getUniqueId( TestClassSimpleStep.class ) ), toArray( TestClassSimpleStep.class ) ),
                Arguments.of( DiscoverySelectors.selectMethod( TestClassSimpleStep.class, "step1" ), toArray( TestClassSimpleStep.class ) ) );
    }

    private static UniqueId getUniqueId( Class<?> javaClass ) {
        return UniqueId.forEngine( "tapir" ).append( "TestClass", javaClass.getName( ) );
    }

    private static Class<?>[] toArray( Class<?>... testClasses ) {
        return testClasses;
    }

}
