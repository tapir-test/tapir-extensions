package de.rhocas.rapit.datasource.excel

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
