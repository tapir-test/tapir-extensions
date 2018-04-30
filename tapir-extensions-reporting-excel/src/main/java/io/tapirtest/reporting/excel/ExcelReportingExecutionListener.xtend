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
package io.tapirtest.reporting.excel

import de.bmiag.tapir.execution.model.ExecutionModelElement
import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import io.tapirtest.reporting.base.AbstractBaseReportingListener
import io.tapirtest.reporting.base.model.ExecutionReport
import io.tapirtest.reporting.base.model.ExecutionResult
import java.awt.Color
import java.io.File
import java.io.FileOutputStream
import java.util.Map
import org.apache.commons.io.FileUtils
import org.apache.poi.ss.usermodel.FillPatternType
import org.apache.poi.ss.usermodel.Workbook
import org.apache.poi.xssf.usermodel.XSSFColor
import org.apache.poi.xssf.usermodel.XSSFRichTextString
import org.apache.poi.xssf.usermodel.XSSFRow
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import org.springframework.beans.factory.annotation.Value
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

/**
 * The listener for the excel reporting module.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
@Component
@Order(7000)
class ExcelReportingExecutionListener extends AbstractBaseReportingListener {

	@Value("${rapid.reporting.excel.outputDirectory:.}")
	String outputDirectory
	
	@Value("${rapid.reporting.excel.displayStepParameters:false}")
	boolean displayStepParameters

	override finalizeReport(ExecutionPlan executionPlan, Map<Identifiable, ExecutionReport> reportMap) {
		val workbook = new XSSFWorkbook

		fillWorkbook(executionPlan, reportMap, workbook)
		writeWorkbook(executionPlan, workbook)
	}

	private def dispatch void fillWorkbook(ExecutionPlan executionPlan, Map<Identifiable, ExecutionReport> reportMap, XSSFWorkbook workbook) {
		executionPlan.children.forEach [ child |
			fillWorkbook(child, reportMap, workbook)
		]
	}

	private def dispatch void fillWorkbook(TestSuite element, Map<Identifiable, ExecutionReport> reportMap, XSSFWorkbook workbook) {
		val sheet = workbook.createSheet('''«element.id»-«element.name.className»''')

		var rowCounter = 0
		
		// Create a first row for the test suite itself
		var row = sheet.createRow(rowCounter++)
		writeIntoRow(element, reportMap, row, workbook, true)

		for (child : element.children) {
			// Write the element into the current sheet
			row = sheet.createRow(rowCounter++)
			writeIntoRow(child, reportMap, row, workbook, false)
			 
			// As this is a test suite, we also have to create sheets for the elements within the test suite
			fillWorkbook(child, reportMap, workbook)
		}
		
		for (column : 0..3) {
			sheet.autoSizeColumn(column)
		}
	}

	private def dispatch void fillWorkbook(TestClass element, Map<Identifiable, ExecutionReport> reportMap, XSSFWorkbook workbook) {
		val sheet = workbook.createSheet('''«element.id»-«element.name.className»''')
		
		var rowCounter = 0
		
		// Create a first row for the test class itself
		var row = sheet.createRow(rowCounter++)
		writeIntoRow(element, reportMap, row, workbook, true)
		
		for (step : element.steps) {
			// Write the steps into the current sheet
			row = sheet.createRow(rowCounter++)
			writeIntoRow(step, reportMap, row, workbook, false)
		}
		
		for (column : 0..3) {
			sheet.autoSizeColumn(column)
		}
	}

	private def void writeIntoRow(ExecutionModelElement element, Map<Identifiable, ExecutionReport> reportMap, XSSFRow row, XSSFWorkbook workbook, boolean bold) {
		val report = reportMap.get(element)

	  	val font = if (bold) createBoldFont(workbook) else createNormalFont(workbook)

		var style = workbook.createCellStyle
		style.font = font
		var cell = row.createCell(0)
		cell.cellValue = new XSSFRichTextString(element.name)
		cell.cellStyle = style
		
		style = workbook.createCellStyle
		style.font = font
		cell = row.createCell(1)
		cell.cellValue = new XSSFRichTextString(report.result.toReadableName)
		cell.cellStyle = style

		style = workbook.createCellStyle
		style.fillForegroundColor = new XSSFColor(report.result.toColor)
		style.fillPattern = FillPatternType.SOLID_FOREGROUND
		style.font = font
		cell.cellStyle = style
		
		style = workbook.createCellStyle
		cell = row.createCell(2)
		cell.cellValue = new XSSFRichTextString('''«report.stop - report.start» ms''')
		cell.cellStyle = style
		
		if (report.throwable.isPresent) {
			style = workbook.createCellStyle
			cell = row.createCell(3)
			cell.cellValue = new XSSFRichTextString(report.throwable.get.toString)
			cell.cellStyle = style
		}
	}
	
	private def createNormalFont(XSSFWorkbook workbook) {
		val font = workbook.createFont
	
	    font.fontHeightInPoints = 12 as short
	    font.fontName = 'Arial'
	    
	    font 
	}
	
	private def createBoldFont(XSSFWorkbook workbook) {
		val font = createNormalFont(workbook)
		
		font.bold = true
		
		font
	}
	
	private def dispatch getName(TestSuite element) {
		element.name
	}

	private def dispatch getName(TestClass element) {
		element.name
	}
	
	private def dispatch String getName(TestStep element) {
		if (element.parameters.empty || !displayStepParameters) {
			element.name
		} else {
			'''«element.name» [«FOR parameter : element.parameters SEPARATOR ', '»«parameter.name» = «parameter.label»«ENDFOR»]'''
		}
	}

	private def toReadableName(ExecutionResult result) {
		switch (result) {
			case SUCCEEDED: 'Succeeded'
			case FAILED: 'Failed'
			case SKIPPED: 'Skipped'
		}
	}

	private def toColor(ExecutionResult result) {
		switch (result) {
			case SUCCEEDED: Color.GREEN
			case FAILED: Color.RED
			case SKIPPED: Color.GRAY
		}
	}

	private def getClassName(String fullQualifiedName) {
		fullQualifiedName.substring(fullQualifiedName.lastIndexOf('.') + 1)
	}

	private def writeWorkbook(ExecutionPlan executionPlan, Workbook workbook) {
		val outputFile = new File(outputDirectory, '''rapit-report-excel-execution-«executionPlan.id».xlsx''')
		FileUtils.forceMkdirParent(outputFile)
	
		val outputStream = new FileOutputStream(outputFile)
		try {
			workbook.write(outputStream)
		} finally {
			outputStream.close
		}
	}

}
