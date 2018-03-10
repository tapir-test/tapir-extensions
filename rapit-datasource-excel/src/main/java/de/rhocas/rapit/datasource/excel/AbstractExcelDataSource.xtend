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
package de.rhocas.rapit.datasource.excel

import de.bmiag.tapir.datasource.api.AbstractDataSource
import org.apache.poi.xssf.usermodel.XSSFRow
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import org.springframework.core.io.Resource

/**
 * This is an abstract base extending the {@link AbstractDataSource} which is suitable for reading excel sheets. The concrete classes only have to
 * specify the mapping between an {@link ExcelRecord} and the concrete data type.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
abstract class AbstractExcelDataSource<T> extends AbstractDataSource<Resource, ExcelRecord, T> {

	override protected getIterator(Resource resource) {
		val workbook = new XSSFWorkbook(resource.inputStream)

		val firstSheet = workbook.getSheetAt(0)
		if (firstSheet === null) {
			throw new IllegalArgumentException('The excel file contains no sheets')
		}

		val firstRow = firstSheet.getRow(0)
		if (firstRow === null) {
			throw new IllegalArgumentException('The excel sheet contains no rows')
		}

		val mapping = getMapping(firstRow)

		val rows = firstSheet.rowIterator
		// Remove the header row
		rows.next

		val rowsWithMapping = newArrayList

		while (rows.hasNext) {
			val row = rows.next

			rowsWithMapping.add(ExcelRecord.build [
				it.row = row
				it.columnMapping = mapping
			])
		}

		rowsWithMapping.iterator
	}

	def getMapping(XSSFRow row) {
		val mapping = newHashMap

		val cells = row.cellIterator
		while (cells.hasNext) {
			val cell = cells.next

			mapping.put(cell.stringCellValue, cell.columnIndex)
		}

		mapping
	}

	override canHandle(Resource resource) {
		val filename = resource.filename.toLowerCase
		filename.endsWith('xlsx')
	}

	override getSelectorType() {
		Resource
	}

}
