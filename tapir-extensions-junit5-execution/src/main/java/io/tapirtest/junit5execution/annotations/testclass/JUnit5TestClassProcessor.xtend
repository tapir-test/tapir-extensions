package io.tapirtest.junit5execution.annotations.testclass

import de.bmiag.tapir.annotationprocessing.annotation.AnnotationProcessor
import de.bmiag.tapir.execution.annotations.testclass.TestClass
import de.bmiag.tapir.execution.annotations.testclass.TestClassProcessor
import io.tapirtest.junit5execution.annotations.TapirJUnit5AnnotationProcessorUtil
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.junit.platform.commons.annotation.Testable
import org.springframework.core.annotation.Order

/**
 * In contrast to {@link TestClassProcessor} this processor additional adds the {@link Testable} annotation in order to assist the IDE in finding the test.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 * 
 */
@AnnotationProcessor(TestClass)
@Order(-8000)
class JUnit5TestClassProcessor extends TestClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		super.doTransform(annotatedClass, context)
		val extension tapirJUnitAnnotationProcessorUtil = new TapirJUnit5AnnotationProcessorUtil
		addTestableAnnotation(annotatedClass, context)
		addTestAnnotatedMethod(annotatedClass, context)
	}

}
