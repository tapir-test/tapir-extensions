package de.rhocas.rapit.datasource.excel.annotation

import de.bmiag.tapir.annotationprocessing.annotation.DynamicActive
import de.rhocas.rapit.datasource.excel.AbstractExcelDataSource
import java.lang.annotation.Target

/**
 * A dynamic active annotation which generates a suitable implementation of an {@link AbstractExcelDataSource} for the annotated data container.
 * The annotated class must also be annotated with tapir's Immutable annotation. The mapping between columns and fields is performed based on the
 * column's headers and the field's name. If more control is required, the column header can be specified by using {@link ExcelColumn}.
 * 
 * @see ExcelDataSourceProcessor
 * @see ExcelColumn
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
@Target(TYPE)
@DynamicActive
annotation ExcelDataSource {
}
