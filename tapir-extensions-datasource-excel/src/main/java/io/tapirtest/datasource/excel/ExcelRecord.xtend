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
package io.tapirtest.datasource.excel

import java.util.Map
import de.bmiag.tapir.data.Immutable
import org.apache.poi.ss.usermodel.Row

/**
 * A data container which encapsulates a single excel row.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
@Immutable
class ExcelRecord {

	Map<String, Integer> columnMapping
	Row row

	/**
	 * Delivers the cell in the given column.
	 * 
	 * @param columnName
	 * 		The name of the column
	 * 
	 * @return The cell.
	 */
	def get(String columnName) {
		val columnIndex = columnMapping.get(columnName)

		if (columnIndex === null) {
			throw new IllegalArgumentException('''No column named '«columnName»' specified''')
		}

		row.getCell(columnIndex)
	}

}
