package de.rhocas.rapit.datasource.excel;

import de.bmiag.tapir.bootstrap.annotation.ModuleConfiguration
import org.springframework.boot.autoconfigure.AutoConfigureOrder

/**
 * The configuration for the excel datasource module.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
@ModuleConfiguration
@AutoConfigureOrder(DatasourceExcelConfiguration.AUTO_CONFIGURE_ORDER)
class DatasourceExcelConfiguration {

	public static final int AUTO_CONFIGURE_ORDER = 0

}
