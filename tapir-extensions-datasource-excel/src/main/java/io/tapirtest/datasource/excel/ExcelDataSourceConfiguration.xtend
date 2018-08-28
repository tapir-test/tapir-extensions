package io.tapirtest.datasource.excel

import de.bmiag.tapir.bootstrap.annotation.ModuleConfiguration
import org.springframework.boot.autoconfigure.AutoConfigureOrder

/** 
 * Provides the configuration for the tapir extensions Excel DataSource module. In this configuration class only beans are registered which are not annotated by Component.
 * 
 * @author Oliver Libutzki {@literal <}oliver.libutzki@libutzki.de{@literal >}
 * 
 * @since 1.0.0
 */
@ModuleConfiguration
@AutoConfigureOrder(ExcelDataSourceConfiguration.AUTO_CONFIGURE_ORDER)
class ExcelDataSourceConfiguration {
	
	public static final int AUTO_CONFIGURE_ORDER = 7000
	
}