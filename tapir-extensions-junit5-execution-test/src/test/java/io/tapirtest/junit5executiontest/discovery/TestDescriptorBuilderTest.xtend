package io.tapirtest.junit5executiontest.discovery

import de.bmiag.tapir.execution.TapirExecutor.TapirExecutorFactory
import de.bmiag.tapir.execution.model.ExecutionPlan
import io.tapirtest.junit5execution.descriptor.TestDescriptorBuilder
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.platform.engine.UniqueId
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.ConfigurableApplicationContext
import org.springframework.test.context.junit.jupiter.SpringExtension

import static org.assertj.core.api.Assertions.*

@SpringBootTest
@ExtendWith(SpringExtension)
class TestDescriptorBuilderTest {

	@Autowired
	ConfigurableApplicationContext applicationContext

	@Autowired
	TestDescriptorBuilder testDescriptorBuilder

	@Autowired
	TapirExecutorFactory tapirExecutorFactory

	@Test
	def void testEmptyExecutionPlan() {
		val testDescriptor = testDescriptorBuilder.buildExecutableTestDescriptor(
			ExecutionPlan.build [
				id = 1
				javaClass = TestClass
			],
			UniqueId.forEngine("tapir"),
			tapirExecutorFactory.getExecutorForClass(TestClass),
			applicationContext
		)
		assertThat(testDescriptor.displayName).isEqualTo(TestClass.name)
	}

	static class TestClass {
	}

}
