package io.tapirtest.featureide.annotation

import org.eclipse.xtend.lib.macro.declaration.AnnotationReference

package class FeatureNameConverter {
	
	def String convertToValidSimpleFeatureName(String rawFeatureName, AnnotationReference annotation) {
		val prefix = annotation.getStringValue('prefix')
		val suffix = annotation.getStringValue('suffix')
		val simpleFeatureName = prefix + rawFeatureName.replaceAll('(\\W)', '') + suffix
		
		simpleFeatureName
	}
	
	def String convertToValidFullQualifiedFeatureName(String rawFeatureName, String packageName, AnnotationReference annotation) {
		val simpleFeatureName = convertToValidSimpleFeatureName(rawFeatureName, annotation)
		'''«packageName».«simpleFeatureName»'''
	} 
	
}