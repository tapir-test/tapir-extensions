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

package io.tapirtest.featureide.annotation

import de.bmiag.tapir.annotationprocessing.annotation.AnnotationProcessor
import de.bmiag.tapir.variant.Variant
import de.bmiag.tapir.variant.feature.Feature
import de.rhocas.featuregen.featureide.model.configuration.Configuration
import de.rhocas.featuregen.featureide.model.configuration.ObjectFactory
import java.util.List
import java.util.Optional
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend.lib.macro.file.Path
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Bean
import org.springframework.core.annotation.Order

/**
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
@AnnotationProcessor(FeatureIDEVariant)
@Order(-10000)
class FeatureIDEVariantProcessor extends AbstractClassProcessor {
 
	static val jaxbContext = JAXBContext.newInstance(ObjectFactory)
	
	val extension FeatureNameConverter = new FeatureNameConverter()
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotation = annotatedClass.findAnnotation(FeatureIDEVariant.findTypeGlobally)
		val variantName = getVariantName(annotation, annotatedClass)
		
		addAnnotationAndInterface(annotatedClass, variantName, context)
		addBasicFieldsAndMethods(annotatedClass, variantName, context)
		addFeatures(annotatedClass, annotation, variantName, context)
		
		annotatedClass.removeAnnotation(annotation)
	}
	
	private def void addAnnotationAndInterface(MutableClassDeclaration annotatedClass, String variantName, extension TransformationContext context) {
		annotatedClass.addAnnotation(org.springframework.context.annotation.Configuration.newAnnotationReference)
		annotatedClass.addAnnotation(ConditionalOnProperty.newAnnotationReference [
			setStringValue('name', 'variant')
			setStringValue('havingValue', variantName)
		])
		 
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[Variant.newTypeReference()]
	}
	
	private def void addBasicFieldsAndMethods(MutableClassDeclaration annotatedClass, String variantName, extension TransformationContext context) {
		annotatedClass.addField('NAME', [
			final = true
			static = true
			visibility = Visibility.PUBLIC
			type = String.newTypeReference()
			initializer = '''"«variantName»"'''
		])
		
		annotatedClass.addMethod('variant', [
			addAnnotation(Bean.newAnnotationReference)
			
			returnType = String.newTypeReference()
			body = '''return «annotatedClass.simpleName».NAME;'''
		])
	}
	
	private def void addFeatures(MutableClassDeclaration annotatedClass, AnnotationReference annotationReference, String variantName, extension TransformationContext context) {
		val filePath = findFilePath(annotatedClass, annotationReference, context)
		
		if (filePath.present) {
			val features = collectFeatureNames(filePath.get, context)
			features.forEach[addFeature(it, annotatedClass, annotationReference, variantName, context)]
		} else {
			annotatedClass.addError('The variant configuration file could not be found.')
		}
	}
	
	private def void addFeature(String rawFeatureName, MutableClassDeclaration annotatedClass, AnnotationReference annotationReference, String variantName, extension TransformationContext context) {
		val packageName = getPackageName(annotatedClass, annotationReference)
		
		val fullyQualifiedFeatureName = convertToValidFullQualifiedFeatureName(rawFeatureName, packageName, annotationReference)
		val simpleFeaturename = convertToValidSimpleFeatureName(rawFeatureName, annotationReference)
		val featureType = fullyQualifiedFeatureName.findTypeGlobally
		
		if (featureType === null) {
			annotatedClass.addError('''Feature '«fullyQualifiedFeatureName»' could not be found''')
		} else {
			val isNonAbstractFeature = Feature.findTypeGlobally.isAssignableFrom(featureType)
			
			if (isNonAbstractFeature) {
				annotatedClass.addMethod(simpleFeaturename.toFirstLower, [
					addAnnotation(Bean.newAnnotationReference)
					addAnnotation(ConditionalOnProperty.newAnnotationReference [
						setStringValue('name', '''«fullyQualifiedFeatureName».active''')
						setStringValue('havingValue', variantName)
						setBooleanValue('matchIfMissing', true)
					])
					
					returnType = featureType.newSelfTypeReference
					body = '''
						return new «featureType.newSelfTypeReference»();
					'''
				])
			}
		}
	}
	
	private def <C extends FileLocations & FileSystemSupport> findFilePath(ClassDeclaration annotatedClass, AnnotationReference annotation, extension C context) {
		var tempFilePath = annotation.getStringValue('value')
		if (tempFilePath == '') {
			tempFilePath = annotatedClass.simpleName + '.xml'
		}
		val filePath = tempFilePath
		
		var Path firstExistingFile
		if (filePath.startsWith('/')) {
			val compilationUnitPath = annotatedClass.compilationUnit.filePath
			firstExistingFile = compilationUnitPath.projectSourceFolders.map[append(filePath)].findFirst[isFile]
		} else {
			val compilationUnitPathParent = annotatedClass.compilationUnit.filePath.parent
			val potentialFile = compilationUnitPathParent.append(filePath)
			if (potentialFile.isFile) {
				firstExistingFile = potentialFile
			}
		}
		
		Optional.ofNullable(firstExistingFile)
	}
	
	private def getVariantName(AnnotationReference annotation, ClassDeclaration annotatedClass) {
		var variantName = annotation.getStringValue('name')
		if (variantName.isNullOrEmpty) {
			variantName = annotatedClass.simpleName
		}
		
		variantName
	}
	
	private def List<String> collectFeatureNames(Path filePath, extension FileSystemSupport context) {
		val configuration = parseVariantModel(filePath, context) 
		configuration.feature.filter[automatic == 'selected' || manual == 'selected'].map[name].toList
	}
	
	private def parseVariantModel(Path filePath, extension FileSystemSupport context) {
		var Configuration configuration
		val stream = filePath.contentsAsStream
		try {
			val unmarshaller = jaxbContext.createUnmarshaller
			configuration = unmarshaller.unmarshal(stream) as Configuration
		} finally {
			stream.close
		}
		
		configuration
	}
	
	private def String getPackageName(ClassDeclaration annotatedClass, AnnotationReference annotation) {
		var packageName = annotation.getStringValue('featuresPackage')
		if (packageName.empty) {
			packageName = annotatedClass.compilationUnit.packageName
		}
		
		packageName
	}

}
