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
import io.tapirtest.featureide.model.configuration.Configuration
import io.tapirtest.featureide.model.configuration.ObjectFactory
import java.util.List
import java.util.Optional
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
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

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		// Find out the name of the variant
		val annotation = annotatedClass.findAnnotation(FeatureIDEVariant.findTypeGlobally)
		var temporaryVariantName = annotation.getStringValue('name')
		if (temporaryVariantName.isNullOrEmpty) {
			temporaryVariantName = annotatedClass.simpleName
		}
		val variantName = temporaryVariantName
		
		// Add the required annotations
		annotatedClass.addAnnotation(org.springframework.context.annotation.Configuration.newAnnotationReference)
		annotatedClass.addAnnotation(ConditionalOnProperty.newAnnotationReference [
			setStringValue('name', 'variant')
			setStringValue('havingValue', variantName)
		])
		
		// Add the interface to mark the class as variant
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[Variant.newTypeReference()]
		
		// Now the basic fields and methods that are always there
		annotatedClass.addField('NAME', [
			final = true
			static = true
			type = String.newTypeReference()
			initializer = '''"«variantName»"'''
		])
		
		annotatedClass.addMethod('variant', [
			addAnnotation(Bean.newAnnotationReference)
			
			returnType = String.newTypeReference()
			body = '''return «annotatedClass.simpleName».NAME;'''
		])
		
		// Now we add the actual features
		val filePath = findFilePath(annotatedClass, annotation, context)
		
		if (filePath.present) {
			// Collect all features and convert them into methods
			val features = collectFeatures(filePath.get, context)
			for (feature : features) {
				val fullyQualifiedFeatureName = getFullQualifiedFeatureName(feature, annotatedClass, annotation)
				val simpleFeaturename = fullyQualifiedFeatureName.substring(fullyQualifiedFeatureName.lastIndexOf('.') + 1).toFirstLower
				val featureType = fullyQualifiedFeatureName.findTypeGlobally
				
				if (featureType === null) {
					annotatedClass.addError('''Feature '«fullyQualifiedFeatureName»' could not be found''')
				} else {
					annotatedClass.addMethod(simpleFeaturename, [
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
	}
	
	private def <C extends FileLocations & FileSystemSupport> findFilePath(ClassDeclaration annotatedClass, AnnotationReference annotation, extension C context) {
		val filePath = annotation.getStringValue('value')
		
		val compilationUnitPath = annotatedClass.compilationUnit.filePath
		val projectSourceFolders = compilationUnitPath.projectSourceFolders
		
		Optional.ofNullable(projectSourceFolders.map[append('/' + filePath)].findFirst[isFile])
	}
	
	private def List<String> collectFeatures(Path filePath, extension FileSystemSupport context) {
		// Parse the feature model from the given XML file
		var Configuration configuration
		val stream = filePath.contentsAsStream
		try {
			val unmarshaller = jaxbContext.createUnmarshaller
			configuration = unmarshaller.unmarshal(stream) as Configuration
		} finally {
			stream.close
		}
		
		configuration.feature.map[name]
	}
	
	private def String getFullQualifiedFeatureName(String feature, ClassDeclaration annotatedClass, AnnotationReference annotation) {
		val prefix = annotation.getStringValue('prefix')
		val suffix = annotation.getStringValue('suffix')
		val simpleFeatureName = prefix + feature.replaceAll('(\\W)', '') + suffix
		var packageName = annotation.getStringValue('featuresPackage')
		if (packageName.empty) {
			packageName = annotatedClass.compilationUnit.packageName
		}
		'''«packageName».«simpleFeatureName»'''
	}

}
