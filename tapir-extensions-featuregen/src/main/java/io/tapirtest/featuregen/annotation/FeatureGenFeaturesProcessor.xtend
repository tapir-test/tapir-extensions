/*
 * MIT License
 * 
 * Copyright (c) 2018 b+m Informatik AG
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package io.tapirtest.featuregen.annotation

import de.bmiag.tapir.annotationprocessing.annotation.AnnotationProcessor
import de.bmiag.tapir.variant.feature.Feature
import de.rhocas.featuregen.lib.FeatureGenLabel
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

/**
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
@AnnotationProcessor(FeatureGenFeatures)
@Order(-10000)
class FeatureGenFeaturesProcessor extends AbstractClassProcessor {

	val extension FeatureNameConverter = new FeatureNameConverter

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		val annotation = annotatedClass.findAnnotation(FeatureGenFeatures.findUpstreamType)
		val classValue = annotation.getClassValue('value')
		val enumerationClass = classValue.type as EnumerationTypeDeclaration
		val features = enumerationClass.declaredValues
		features.forEach [ feature |
			val featureGenLabelAnnotation = feature.findAnnotation(FeatureGenLabel.findUpstreamType)
			val fullQualifiedName = getFullQualifiedFeatureName(annotatedClass, annotation, featureGenLabelAnnotation)
			fullQualifiedName.registerClass
		]
	}
	
	private def String getFullQualifiedFeatureName(ClassDeclaration annotatedClass, AnnotationReference featureGenFeaturesAnnotation, AnnotationReference featureGenLabelAnnotation) {
		var featureName = featureGenLabelAnnotation.getStringValue('value')
		convertToValidFullQualifiedFeatureName(featureName, annotatedClass.compilationUnit.packageName, featureGenFeaturesAnnotation)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotation = annotatedClass.findAnnotation(FeatureGenFeatures.findTypeGlobally)
		val enumerationClass = annotation.getClassValue('value').type as EnumerationTypeDeclaration
		val features = enumerationClass.declaredValues
		features.forEach [ feature | 
			val featureGenLabelAnnotation = feature.findAnnotation(FeatureGenLabel.findTypeGlobally)
			val fullQualifiedName = getFullQualifiedFeatureName(annotatedClass, annotation, featureGenLabelAnnotation)

			val featureClass = fullQualifiedName.findClass
			doTransformFeature(featureClass, context)
		]
	}
	
	private def doTransformFeature(MutableClassDeclaration featureClass, extension TransformationContext context) {
		featureClass.final = true
		featureClass.implementedInterfaces = #[Feature.findTypeGlobally.newSelfTypeReference]
			
		featureClass.addAnnotation(Component.newAnnotationReference)
		featureClass.addAnnotation(ConditionalOnProperty.newAnnotationReference([
			setStringValue('name', '''«featureClass.qualifiedName».active''')
			setStringValue('havingValue', 'true')
		]))
	}
	
}
