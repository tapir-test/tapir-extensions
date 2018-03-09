package de.rhocas.uitestextensions.datasource.excel.annotation

import java.lang.annotation.Target

/**
 * This annotation can only be used in conjunction with {@link ExcelDataSource}. It can be used to specify the mapping between the column header and the field name.
 * 
 * @see ExcelDataSource
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
@Target(FIELD)
annotation ExcelColumn {

	String value

}
