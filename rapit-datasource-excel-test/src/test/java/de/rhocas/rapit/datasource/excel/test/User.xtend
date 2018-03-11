package de.rhocas.rapit.datasource.excel.test

import de.bmiag.tapir.data.Immutable
import de.rhocas.rapit.datasource.excel.annotation.ExcelColumn
import de.rhocas.rapit.datasource.excel.annotation.ExcelDataSource
import java.util.Date
import java.util.Optional

@ExcelDataSource
@Immutable
class User {

	@ExcelColumn('User Id')
	int id
	
	String username
	String password

	@ExcelColumn('Birthdate')
	Optional<Date> dateOfBirth

}
