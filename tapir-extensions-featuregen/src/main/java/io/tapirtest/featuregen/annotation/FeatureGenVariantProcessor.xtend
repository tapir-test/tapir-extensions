package io.tapirtest.featuregen.annotation

import de.bmiag.tapir.annotationprocessing.annotation.AnnotationProcessor
import de.bmiag.tapir.variant.Variant
import de.rhocas.featuregen.lib.FeatureGenSelectedFeatures
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import de.rhocas.featuregen.lib.FeatureGenLabel

/**
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
@AnnotationProcessor(FeatureGenVariant)
@Order(-10000)  
class FeatureGenVariantProcessor extends AbstractClassProcessor {
	
	val extension FeatureNameConverter = new FeatureNameConverter
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		addAnnotationAndInterface(annotatedClass, context)
		addBasicFieldsAndMethods(annotatedClass, context)
		addFeatures(annotatedClass, context)
	}
	
	private def void addAnnotationAndInterface(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.addAnnotation(Configuration.newAnnotationReference)
		annotatedClass.addAnnotation(ConditionalOnProperty.newAnnotationReference [
			setStringValue('name', 'variant')
			setStringValue('havingValue', getVariantName(annotatedClass, context))
		])
		 
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[Variant.newTypeReference()]
	}
	
	private def getVariantName(ClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotation = annotatedClass.findAnnotation(FeatureGenVariant.findTypeGlobally)
		var variantName = annotation.getStringValue('name')
		if (variantName.isNullOrEmpty) {
			variantName = annotatedClass.simpleName
		}
		
		variantName
	}
	
	private def void addBasicFieldsAndMethods(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.addField('NAME', [
			final = true
			static = true
			visibility = Visibility.PUBLIC
			type = String.newTypeReference()
			initializer = '''"«getVariantName(annotatedClass, context)»"'''
		])
		
		annotatedClass.addMethod('variant', [
			addAnnotation(Bean.newAnnotationReference)
			
			returnType = String.newTypeReference()
			body = '''return «annotatedClass.simpleName».NAME;'''
		])
	}
	 
	private def void addFeatures(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val featureGenVariant = annotatedClass.findAnnotation(FeatureGenVariant.findTypeGlobally)
		val referencedVariantClass = featureGenVariant.getClassValue('variantClass').type as ClassDeclaration
		val referencedFeaturesClass = featureGenVariant.getClassValue('featuresClass').type as ClassDeclaration
		val featureGenFeatures = referencedFeaturesClass.findAnnotation(FeatureGenFeatures.findTypeGlobally)
		
		val annotations = referencedVariantClass.annotations 
		val selectedFeaturesAnnotation = annotations.findFirst[annotationTypeDeclaration.findAnnotation(FeatureGenSelectedFeatures.findTypeGlobally) !== null]
		                                            
		if (selectedFeaturesAnnotation === null) {
			annotatedClass.addError('SelectedFeatures-Annotation can not be found.')
		} else {
			val selectedFeatures = selectedFeaturesAnnotation.getEnumArrayValue('value')
			selectedFeatures.forEach[ feature |
				val featureGenLabelAnnotation = feature.findAnnotation(FeatureGenLabel.findTypeGlobally)
				annotatedClass.addMethod(getSimpleFeatureName(featureGenFeatures, featureGenLabelAnnotation).toFirstLower) [
					addAnnotation(newAnnotationReference(Bean))
					addAnnotation(newAnnotationReference(ConditionalOnProperty) [
						setStringValue("name", getFullQualifiedFeatureName(referencedFeaturesClass, featureGenFeatures, featureGenLabelAnnotation) + ".active")
						setStringValue("havingValue", "true")
						setBooleanValue("matchIfMissing", true)
					])
					
					val featureType = getFullQualifiedFeatureName(referencedFeaturesClass, featureGenFeatures, featureGenLabelAnnotation).findTypeGlobally
					returnType = featureType.newTypeReference()
					
					body = '''
						return new «featureType.newTypeReference()»();
					'''
				]
			]
		}
	}
	
	private def String getSimpleFeatureName(AnnotationReference featureGenFeaturesAnnotation, AnnotationReference featureGenLabelAnnotation) {
		val featureName = featureGenLabelAnnotation.getStringValue('value')

		convertToValidSimpleFeatureName(featureName, featureGenFeaturesAnnotation)
	}
	
	
	private def String getFullQualifiedFeatureName(ClassDeclaration annotatedClass, AnnotationReference featureGenFeaturesAnnotation, AnnotationReference featureGenLabelAnnotation) {
		val featureName = featureGenLabelAnnotation.getStringValue('value')

	    // We cannot use the package of the compilation unit as this leads to wrong results in this case.
		val qualifiedName = annotatedClass.qualifiedName
		val simpleName = annotatedClass.simpleName
		val packageName = qualifiedName.substring(0, qualifiedName.length - simpleName.length - 1)
		
		convertToValidFullQualifiedFeatureName(featureName, packageName, featureGenFeaturesAnnotation)
	}
	
}
