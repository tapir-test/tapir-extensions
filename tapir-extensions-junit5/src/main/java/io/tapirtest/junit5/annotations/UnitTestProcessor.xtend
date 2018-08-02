package io.tapirtest.junit5.annotations

/*-
 * #%L
 * de.bmiag.tapir:tapir-junit
 * %%
 * Copyright (C) 2018 b+m Informatik AG
 * %%
 * This program is distributed under the License terms for the tapir Community Edition.
 * 
 * You should have received a copy of the License terms for the tapir Community Edition along with this program. If not, see
 * <https://www.tapir-test.io/license-community-edition>.
 * #L%
 */

import de.bmiag.tapir.annotationprocessing.annotation.AnnotationProcessor
import de.bmiag.tapir.core.annotation.useextension.ExtensionService
import de.bmiag.tapir.coreassertion.CoreAssertions
import de.bmiag.tapir.util.extensions.TapirAssertions
import de.bmiag.tapir.xunit.annotations.UnitTest
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.junit.jupiter.api.^extension.ExtendWith
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.core.annotation.Order
import org.springframework.test.context.junit.jupiter.SpringExtension

@AnnotationProcessor(UnitTest)
@Order(-9000)
class UnitTestProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		addSpringBootTestAnnotation(annotatedClass, context)
		addExtendWithAnnotation(annotatedClass, context)
		registerCoreAssertionsExtension(annotatedClass, context)
	}

	def protected void addExtendWithAnnotation(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val extendWithType = ExtendWith.findTypeGlobally
		val extendWithAnnotation = annotatedClass.findAnnotation(extendWithType)
		if(extendWithAnnotation === null) {
			annotatedClass.addAnnotation(newAnnotationReference(extendWithType) [
				setClassValue("value", SpringExtension.newTypeReference)
			])
		}
	}

	def protected void addSpringBootTestAnnotation(MutableClassDeclaration annotatedClass,
		extension TransformationContext context) {
		val springBootTestType = SpringBootTest.findTypeGlobally
		val springBootTestAnnotation = annotatedClass.findAnnotation(springBootTestType)
		if(springBootTestAnnotation === null) {
			val unitTestAnnotation = annotatedClass.findAnnotation(UnitTest.findTypeGlobally)
			val properties = unitTestAnnotation.getStringArrayValue("value")
			annotatedClass.addAnnotation(newAnnotationReference(springBootTestType) [
				setStringValue("properties", properties)
			])
		}
	}

	def protected registerCoreAssertionsExtension(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val coreAssertionsTypeRef = CoreAssertions.newTypeReference
		val extensionService = new ExtensionService
		extensionService.registerExtension(annotatedClass, #[coreAssertionsTypeRef], Visibility.PRIVATE, context)
	}

}
