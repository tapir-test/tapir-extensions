/*
 * MIT License
 * 
 * Copyright (c) 2018 Nils Christian Ehmke
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
package io.tapirtest.datasource.excel.annotation

import de.bmiag.tapir.annotationprocessing.annotation.AnnotationProcessor
import de.bmiag.tapir.data.Immutable
import io.tapirtest.datasource.excel.AbstractExcelDataSource
import io.tapirtest.datasource.excel.ExcelRecord
import java.util.Optional
import org.apache.poi.ss.usermodel.Cell
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.core.convert.ConversionService
import org.springframework.stereotype.Component
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.services.GlobalTypeLookup

/**
 * This is the default annotation processor for the {@link ExcelDataSource} annotation. It adds an implementation of {@link AbstractExcelDataSource} and
 * converts an excel row into data container elements.
 * 
 * @see ExcelDataSource
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */ 
@AnnotationProcessor(#[ExcelDataSource])
class ExcelDataSourceProcessor extends AbstractClassProcessor {
	
	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {
		// Make sure that the data container is also annotated with immutable.
		if (!annotatedClass.annotations.exists[annotationTypeDeclaration == Immutable.findTypeGlobally]) {
			val annotation = annotatedClass.annotations.findFirst[annotationTypeDeclaration == ExcelDataSource.findTypeGlobally]
			annotation.addError('''The annotation can only be used in conjunction with «Immutable».''')
		} 
		
		// Make also sure that none of the fields uses a generic type (except Optional)
		for (field : annotatedClass.declaredFields) {
			if (!field.getRealType(context).actualTypeArguments.empty) {
				field.addError('''The field type must not have any generics. Only «Optional.simpleName»<...> may be used.''')
			}
		}
	}
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		// Register the new excel data source class
		annotatedClass.fullQualifiedDataSourceName.registerClass
	}
	 
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val dataSourceClass = annotatedClass.fullQualifiedDataSourceName.findClass
		dataSourceClass.extendedClass = AbstractExcelDataSource.newTypeReference(annotatedClass.newSelfTypeReference)
		
		// Make sure that the data source can be found in the Spring context
		dataSourceClass.addAnnotation(Component.newAnnotationReference)
		
		// The conversion service is injected by Spring and used to map the fields
		dataSourceClass.addField('conversionService') [
			type = ConversionService.newTypeReference()
			addAnnotation(Autowired.newAnnotationReference)
		]
		
		// Now we only have to implement the "mapDataSet" method to map the excel rows to the data type
		dataSourceClass.addMethod('mapDataSet') [
			addAnnotation(Override.newAnnotationReference)
			
			addParameter('excelRecord', ExcelRecord.newTypeReference)
			returnType = annotatedClass.newSelfTypeReference
			
			body = '''
				return «annotatedClass.newSelfTypeReference».build(it -> {
					«Cell» cell;
					«FOR field : annotatedClass.declaredFields»
						«val excelColumn = field.annotations.findFirst[annotationTypeDeclaration == ExcelColumn.findTypeGlobally]»
						«val columnName = if (excelColumn !== null) excelColumn.getStringValue('value') else field.simpleName»
						
						cell = excelRecord.get("«columnName»");
						
						if (cell != null) {
							final String cellContentString = cell.toString();
							final «field.getRealType(context)» cellContent = conversionService.convert(cellContentString, «field.getRealType(context)».class);
							
							it.set«field.simpleName.toFirstUpper»(cellContent);
						}
					«ENDFOR»
				}
				);
			'''
		]
	}
	
	private def String getFullQualifiedDataSourceName(ClassDeclaration annotatedClass) {
		'''«annotatedClass.qualifiedName»ExcelDataSource'''
	}
	
	private def getRealType(FieldDeclaration field, extension GlobalTypeLookup context) {
		if (field.isOptional(context)) {
			field.type.actualTypeArguments.get(0)
		} else {
			field.type
		}
	}
	
	private def isOptional(FieldDeclaration field, extension GlobalTypeLookup context) {
		Optional.findTypeGlobally.isAssignableFrom(field.type.type)
	}
	
}
