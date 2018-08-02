package io.tapirtest.junit5execution.discovery

import io.tapirtest.junit5execution.descriptor.TestDescriptorRegistry
import java.util.Optional
import java.util.stream.Stream
import java.util.stream.StreamSupport
import org.junit.platform.commons.util.ClassFilter
import org.junit.platform.engine.DiscoverySelector
import org.junit.platform.engine.UniqueId
import org.junit.platform.engine.discovery.ClassSelector
import org.junit.platform.engine.discovery.ClasspathRootSelector
import org.junit.platform.engine.discovery.MethodSelector
import org.junit.platform.engine.discovery.ModuleSelector
import org.junit.platform.engine.discovery.PackageSelector
import org.junit.platform.engine.discovery.UniqueIdSelector

import static java.util.Collections.singletonList

import static extension org.junit.platform.commons.util.ReflectionUtils.*

/**
 * The {@code JUnitExecutionDescriptionBuilder} is responsible for discovering tapir tests based on different
 * {@link DiscoverySelector discovery selectors}.
 * 
 * Currently the following selectors are supported:
 * <ul>
 * <li>{@link PackageSelector}</li>
 * <li>{@link ClassSelector}</li>
 * <li>{@link MethodSelector}</li>
 * <li>{@link UniqueIdSelector}</li>
 * </ul>
 * 
 * @see JUnitExecutionDescription
 * @see DiscoverySelector
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
class JUnitExecutionDescriptionBuilder {

	/**
	 * Returns a {@link Stream} of {@link JUnitExecutionDescription} for a given {@link DiscoverySelector}.
	 * 
	 * @param discoverySelector
	 *            the {@link DiscoverySelector}
	 * @return the stream
	 * @since 1.0.0
	 */
	def Stream<JUnitExecutionDescription> buildExecutionDescriptionStream(DiscoverySelector discoverySelector) {
		val descriptionIterable = discoverySelector.dispatchBuildExecutionDescriptions
		StreamSupport.stream(descriptionIterable.spliterator, false)
	}

	/**
	 * Returns an {@link Iterable} of {@link JUnitExecutionDescription} for a given {@link DiscoverySelector}.
	 * 
	 * @param discoverySelector
	 *            the {@link DiscoverySelector}
	 * @return the iterable
	 * @since 1.0.0
	 */
	def Iterable<JUnitExecutionDescription> buildExecutionDescriptions(DiscoverySelector discoverySelector) {
		discoverySelector.dispatchBuildExecutionDescriptions
	}

	def private dispatch Iterable<JUnitExecutionDescription> dispatchBuildExecutionDescriptions(PackageSelector packageSelector) {
		val classes = packageSelector.packageName.findAllClassesInPackage(ClassFilter.of(TestContainerPredicate.INSTANCE))
		classes.map[buildExecutionDescriptionForClass]
	}

	def private dispatch Iterable<JUnitExecutionDescription> dispatchBuildExecutionDescriptions(ClassSelector classSelector) {
		Optional.of(classSelector.javaClass).filter(TestContainerPredicate.INSTANCE).map [ javaClass |
			singletonList(
				JUnitExecutionDescription.build [
					bootstrapClass = javaClass
				]
			)
		].orElse(emptyList)
	}

	def private dispatch Iterable<JUnitExecutionDescription> dispatchBuildExecutionDescriptions(
		ClasspathRootSelector classpathResourceSelector) {
		val classes = classpathResourceSelector.classpathRoot.findAllClassesInClasspathRoot(
			ClassFilter.of(TestContainerPredicate.INSTANCE))
		classes.map[buildExecutionDescriptionForClass]
	}

	def private dispatch Iterable<JUnitExecutionDescription> dispatchBuildExecutionDescriptions(ModuleSelector moduleSelector) {
		val classes = moduleSelector.moduleName.findAllClassesInModule(ClassFilter.of(TestContainerPredicate.INSTANCE))
		classes.map[buildExecutionDescriptionForClass]
	}

	def private dispatch Iterable<JUnitExecutionDescription> dispatchBuildExecutionDescriptions(MethodSelector methodSelector) {
		Optional.of(methodSelector.javaMethod).filter(TestStepPredicate.INSTANCE).map [ javaMethod |
			singletonList(
				JUnitExecutionDescription.build [
					bootstrapClass = methodSelector.javaClass
					testStepFilterPredicate = [ testStep, applicationContext |
						javaMethod == testStep.javaMethod
					]
				]
			)
		].orElse(emptyList)
	}

	def private dispatch Iterable<JUnitExecutionDescription> dispatchBuildExecutionDescriptions(UniqueIdSelector uniqueIdSelector) {
		val uniqueId = uniqueIdSelector.uniqueId
		uniqueId.firstTestContainer.filter(TestContainerPredicate.INSTANCE).map [ rootClass |
			singletonList(
				JUnitExecutionDescription.build [
					bootstrapClass = rootClass
					testStepFilterPredicate = [ testStep, applicationContext |
						val testDescriptorRegistry = applicationContext.getBean(TestDescriptorRegistry)
						val testDescriptor = testDescriptorRegistry.getTestDescriptor(testStep)
						testDescriptor.filter[uniqueId.hasPrefix(uniqueId)].present
					]
				]
			)
		].orElse(emptyList)
	}

	def private Optional<Class<?>> getFirstTestContainer(UniqueId uniqueId) {
		for (segment : uniqueId.segments) {
			val classOptional = segment.value.loadClass.filter(TestContainerPredicate.INSTANCE)
			if(classOptional.present) {
				return classOptional
			}
		}
		Optional.empty
	}

	def private buildExecutionDescriptionForClass(Class<?> bootstrapClass) {
		JUnitExecutionDescription.build [
			it.bootstrapClass = bootstrapClass
		]
	}

}
