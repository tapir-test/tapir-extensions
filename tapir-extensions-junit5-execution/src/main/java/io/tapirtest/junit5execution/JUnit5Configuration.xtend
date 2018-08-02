package io.tapirtest.junit5execution;

import de.bmiag.tapir.bootstrap.annotation.ModuleConfiguration
import org.springframework.boot.autoconfigure.AutoConfigureOrder

@ModuleConfiguration
@AutoConfigureOrder(JUnit5Configuration.AUTO_CONFIGURE_ORDER)
public class JUnit5Configuration {

	public static final int AUTO_CONFIGURE_ORDER = 0
}
