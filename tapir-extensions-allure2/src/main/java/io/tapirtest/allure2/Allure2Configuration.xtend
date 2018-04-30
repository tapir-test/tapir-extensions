package io.tapirtest.allure2;

import de.bmiag.tapir.bootstrap.annotation.ModuleConfiguration
import org.springframework.boot.autoconfigure.AutoConfigureOrder

@ModuleConfiguration
@AutoConfigureOrder(Allure2Configuration.AUTO_CONFIGURE_ORDER)
public class Allure2Configuration {

	public static final int AUTO_CONFIGURE_ORDER = 7000
	
}
