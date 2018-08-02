package io.tapirtest.junit5execution.annotations

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.junit.platform.commons.annotation.Testable

/**
 * Provides convenience methods which might be used by multiple annotation processors.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 * 
 */
class TapirJUnit5AnnotationProcessorUtil {

	/**
	 * Adds JUnit's {@link Testable} annotation to the given annotatedClass.
	 * 
	 * @param annotatedClass
	 *            the class which should be annotated
	 * @param context
	 *            the transformation context
	 * @since 1.0.0
	 */
	def void addTestableAnnotation(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val testableType = Testable.findTypeGlobally
		val testableAnnotation = annotatedClass.findAnnotation(testableType)
		if(testableAnnotation === null) {
			annotatedClass.addAnnotation(newAnnotationReference(testableType))
		}
	}
	
	/**
	 * Adds a method called _xtendCompliance to the given annotatedClass and annotates it with {@link Test}. This is just a workaround for the issue described in <a href="https://github.com/eclipse/xtext-xtend/issues/519">Xtend #519</a>.
	 * 
	 * @param annotatedClass
	 *            the class which should be annotated
	 * @param context
	 *            the transformation context
	 * @since 1.0.0
	 * @see <a href="https://github.com/eclipse/xtext-xtend/issues/519">Xtend #519</a>
	 */
	def void addTestAnnotatedMethod(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.addMethod("_xtendCompliance") [
			val testType = Test.findTypeGlobally
			addAnnotation(newAnnotationReference(testType))
			body = ['''''']
		]
	}

}
