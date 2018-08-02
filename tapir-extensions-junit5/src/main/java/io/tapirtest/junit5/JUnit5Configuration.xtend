package io.tapirtest.junit5

/*-
 * #%L
 * de.bmiag.tapir:tapir-junit
 * %%
 * Copyright (C) 2018 b+m Informatik AG
 * %%
 * This program is distributed under the License terms for the tapir Community Edition.
 * 
 * You should have received a copy of the License terms for the tapir Community Edition along with this program. If not, see
 * <https://www.tapir-test.io/license-community-edition>.
 * #L%
 */

import de.bmiag.tapir.bootstrap.annotation.ModuleConfiguration
import org.springframework.boot.autoconfigure.AutoConfigureOrder
import org.springframework.stereotype.Component

/** 
 * Provides the configuration for tapir's JUnit 5 module. In this configuration class only beans are registered which are not annotated by {@link Component @Component}.
 * 
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 * 
 * @since 1.0.0
 */
@ModuleConfiguration
@AutoConfigureOrder(JUnit5Configuration.AUTO_CONFIGURE_ORDER)
class JUnit5Configuration {

	/**
	 * @since 1.0.0
	 */
	public static final int AUTO_CONFIGURE_ORDER = -8000

}
