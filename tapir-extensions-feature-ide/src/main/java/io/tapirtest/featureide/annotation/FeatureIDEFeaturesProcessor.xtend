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
import de.bmiag.tapir.variant.feature.Feature
import io.tapirtest.featureide.model.feature.BranchedFeatureType
import io.tapirtest.featureide.model.feature.FeatureModelType
import io.tapirtest.featureide.model.feature.FeatureType
import io.tapirtest.featureide.model.feature.ObjectFactory
import io.tapirtest.featureide.model.feature.StructType
import java.util.List
import java.util.Optional
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend.lib.macro.file.Path
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

/**
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
@AnnotationProcessor(FeatureIDEFeatures)
@Order(-10000)
class FeatureIDEFeaturesProcessor extends AbstractClassProcessor {

	static val jaxbContext = JAXBContext.newInstance(ObjectFactory)

	val extension FeatureNameConverter = new FeatureNameConverter()

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		val annotation = annotatedClass.findAnnotation(FeatureIDEFeatures.findUpstreamType)
		val filePath = findFilePath(annotatedClass, annotation, context)
		
		if (filePath.present) {
			val rawFeatureNames = collectFeatureNames(filePath.get, context)
			val fullQualifiedFeatureNames = rawFeatureNames.map[convertToValidFullQualifiedFeatureName(it, annotatedClass.compilationUnit.packageName, annotation)]
			fullQualifiedFeatureNames.forEach[registerClass]
		}
	}
	
	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {
		val annotation = annotatedClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		val filePath = findFilePath(annotatedClass, annotation, context)
		
		if (!filePath.present) {
			annotatedClass.addError('The feature model file could not be found.')
		}
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotation = annotatedClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		val filePath = findFilePath(annotatedClass, annotation, context)
		
		if (filePath.present) {
			// Find all registered feature classes and transform them
			val rawFeatureNames = collectFeatureNames(filePath.get, context)
			val fullQualifiedFeatureNames = rawFeatureNames.map[convertToValidFullQualifiedFeatureName(it, annotatedClass.compilationUnit.packageName, annotation)]
			val featureClasses = fullQualifiedFeatureNames.map[findClass]
			featureClasses.forEach[doTransformFeature(it, context)]
		}
	}
	
	private def doTransformFeature(MutableClassDeclaration featureClass, extension TransformationContext context) {
		featureClass.implementedInterfaces = #[Feature.findTypeGlobally.newSelfTypeReference]
		
		featureClass.addAnnotation(Component.newAnnotationReference)
		featureClass.addAnnotation(ConditionalOnProperty.newAnnotationReference([
			setStringValue('name', '''«featureClass.qualifiedName».active''')
			setStringValue('havingValue', 'true')
		]))
	}
	
	private def <C extends FileLocations & FileSystemSupport> findFilePath(ClassDeclaration annotatedClass, AnnotationReference annotation, extension C context) {
		val filePath = annotation.getStringValue('value')
		
		val compilationUnitPath = annotatedClass.compilationUnit.filePath
		val projectSourceFolders = compilationUnitPath.projectSourceFolders
		val firstExistingFile = projectSourceFolders.map[append('/' + filePath)].findFirst[isFile]
		
		Optional.ofNullable(firstExistingFile)
	}
	
	private def List<String> collectFeatureNames(Path filePath, extension FileSystemSupport context) {
		val list = newArrayList
		
		val featureModel = parseFeatureModel(filePath, context)
		collectFeatureNames(featureModel, list)
		
		list
	}
	
	private def parseFeatureModel(Path filePath, extension FileSystemSupport context) {
		var FeatureModelType featureModel
		
		val stream = filePath.contentsAsStream
		try {
			val unmarshaller = jaxbContext.createUnmarshaller
			featureModel = unmarshaller.unmarshal(stream) as FeatureModelType
		} finally {
			stream.close
		}
		
		featureModel
	}
	
	private def void collectFeatureNames(FeatureModelType featureModel, List<String> list) {
		collectFeatureNames(featureModel.struct, list)
	}
	
	private def void collectFeatureNames(StructType struct, List<String> list) {
		if (struct.and !== null) {
			collectFeatureNames(struct.and, list)
		}
		
		if (struct.alt !== null) {
			collectFeatureNames(struct.alt, list)
		}
		
		if (struct.or !== null) {
			collectFeatureNames(struct.or, list)
		}
		
		if (struct.feature !== null) {
			collectFeatureNames(struct.feature, list)
		}
	}
	
	private def void collectFeatureNames(BranchedFeatureType branchedFeature, List<String> list) {
		collectFeatureNames(branchedFeature as FeatureType, list)
		
		for (element : branchedFeature.andOrOrOrAlt) {
			val value = element.value
			
			// We use this instanceof just to call the correct method. Xtend performs the cast.
			if (value instanceof BranchedFeatureType) {
				collectFeatureNames(value, list)
			} else {
				collectFeatureNames(value, list)		
			}
		}
	}
	
	private def void collectFeatureNames(FeatureType feature, List<String> list) {
		if (!Boolean.TRUE.equals(feature.abstract)) {
			list += feature.name
		}
	}
	
}
