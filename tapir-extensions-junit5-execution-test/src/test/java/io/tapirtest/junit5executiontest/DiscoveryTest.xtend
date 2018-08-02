package io.tapirtest.junit5executiontest

import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import io.tapirtest.junit5executiontest.data.TestClassIteratedParameterizedStep
import io.tapirtest.junit5executiontest.data.TestClassParameterizedStep
import io.tapirtest.junit5executiontest.data.TestClassSimpleStep
import io.tapirtest.junit5executiontest.expectation.ComparableTestIdentifier
import io.tapirtest.junit5executiontest.expectation.ComparableTestIdentifier.Builder
import io.tapirtest.junit5executiontest.expectation.TestPlanConverter
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.junit.jupiter.api.Test
import org.junit.platform.engine.TestDescriptor.Type
import org.junit.platform.engine.discovery.DiscoverySelectors
import org.junit.platform.engine.support.descriptor.ClassSource
import org.junit.platform.engine.support.descriptor.MethodSource
import org.junit.platform.launcher.core.LauncherDiscoveryRequestBuilder
import org.junit.platform.launcher.core.LauncherFactory

import static extension io.tapirtest.junit5executiontest.JUnit5TestUtil.*
import static org.assertj.core.api.Assertions.*
import io.tapirtest.junit5executiontest.data.IteratedTestClass
import de.bmiag.tapir.execution.model.TestSuite

class DiscoveryTest {

	def void testDiscovery(Class<?> testClass, ComparableTestIdentifier expectedTestIdentifier) {
		val converter = new TestPlanConverter
		val launcher = LauncherFactory.create
		val request = LauncherDiscoveryRequestBuilder.request.selectors(DiscoverySelectors.selectClass(testClass)).build
		val testPlan = launcher.discover(request)
		val rootTestIdentifier = converter.convert(testPlan)

		assertThat(rootTestIdentifier).isEqualTo(expectedTestIdentifier)
	}

	def private ComparableTestIdentifier getEngineTestIdentifier(Procedure1<Builder> rootTestIdentifierBuilder) {
		ComparableTestIdentifier.build [
			uniqueId = TAPIR_ENGINE_UID
			displayName = "tapir"
			type = Type.CONTAINER
			children = #[ComparableTestIdentifier.build(rootTestIdentifierBuilder)]
		]
	}

	@Test
	def void testSimpleStep() {
		val expected = getEngineTestIdentifier[
			val testClassUID = TAPIR_ENGINE_UID.append(TestClass.simpleName, TestClassSimpleStep.name)
			uniqueId = testClassUID
			displayName = TestClassSimpleStep.name
			source = ClassSource.from(TestClassSimpleStep)
			type = Type.CONTAINER
			children = #[
				ComparableTestIdentifier.build [
					uniqueId = testClassUID.append(TestStep.simpleName, "step1")
					displayName = '''step1'''
					source = MethodSource.from(TestClassSimpleStep.name, "step1", "")
					type = Type.TEST
				]
			]
		]
		testDiscovery(TestClassSimpleStep, expected)
	}

	@Test
	def void testParameterizedStep() {
		val expected = getEngineTestIdentifier[
			val testClassUID = TAPIR_ENGINE_UID.append(TestClass.simpleName, TestClassParameterizedStep.name)
			uniqueId = testClassUID
			displayName = TestClassParameterizedStep.name
			source = ClassSource.from(TestClassParameterizedStep)
			type = Type.CONTAINER
			children = #[
				ComparableTestIdentifier.build [
					uniqueId = testClassUID.append(TestStep.simpleName, '''step1(«"value1".digist»)''')
					displayName = '''step1 [value1]'''
					source = MethodSource.from(TestClassParameterizedStep.name, "step1", String.name)
					type = Type.TEST
				],
				ComparableTestIdentifier.build [
					uniqueId = testClassUID.append(TestStep.simpleName, '''step2(«"value1".digist»,«"value2".digist»)''')
					displayName = '''step2 [value1, value2]'''
					source = MethodSource.from(TestClassParameterizedStep.name, "step2", '''«String.name», «String.name»''')
					type = Type.TEST
				]
			]
		]
		testDiscovery(TestClassParameterizedStep, expected)
	}

	@Test
	def void testIteratedParameterizedStep() {
		val expected = getEngineTestIdentifier[
			val testClassUID = TAPIR_ENGINE_UID.append(TestClass.simpleName, TestClassIteratedParameterizedStep.name)
			uniqueId = testClassUID
			displayName = TestClassIteratedParameterizedStep.name
			source = ClassSource.from(TestClassIteratedParameterizedStep)
			type = Type.CONTAINER
			val step1UID = testClassUID.append(TestStep.simpleName, "step1")
			val step2UID = testClassUID.append(TestStep.simpleName, "step2")
			children = #[
				ComparableTestIdentifier.build [
					uniqueId = step1UID
					displayName = '''step1'''
					source = MethodSource.from(TestClassIteratedParameterizedStep.name, "step1", String.name)
					type = Type.CONTAINER
					children = #[
						ComparableTestIdentifier.build [
							uniqueId = step1UID.append(TestStep.simpleName, '''step1(«"value1".digist»)''')
							displayName = '''[value1]'''
							source = MethodSource.from(TestClassIteratedParameterizedStep.name, "step1", String.name)
							type = Type.TEST
						],
						ComparableTestIdentifier.build [
							uniqueId = step1UID.append(TestStep.simpleName, '''step1(«"value2".digist»)''')
							displayName = '''[value2]'''
							source = MethodSource.from(TestClassIteratedParameterizedStep.name, "step1", String.name)
							type = Type.TEST
						]
					]
				],
				ComparableTestIdentifier.build [
					uniqueId = step2UID
					displayName = '''step2'''
					source = MethodSource.from(TestClassIteratedParameterizedStep.name, "step2", '''«String.name», «String.name»''')
					type = Type.CONTAINER
					children = #[
						ComparableTestIdentifier.build [
							uniqueId = step2UID.append(
								TestStep.simpleName, '''step2(«"param1value1".digist»,«"param2value1".digist»)''')
							displayName = '''[param1value1, param2value1]'''
							source = MethodSource.from(TestClassIteratedParameterizedStep.name,
								"step2", '''«String.name», «String.name»''')
							type = Type.TEST
						],
						ComparableTestIdentifier.build [
							uniqueId = step2UID.append(
								TestStep.simpleName, '''step2(«"param1value1".digist»,«"param2value2".digist»)''')
							displayName = '''[param1value1, param2value2]'''
							source = MethodSource.from(TestClassIteratedParameterizedStep.name,
								"step2", '''«String.name», «String.name»''')
							type = Type.TEST
						],
						ComparableTestIdentifier.build [
							uniqueId = step2UID.append(
								TestStep.simpleName, '''step2(«"param1value2".digist»,«"param2value1".digist»)''')
							displayName = '''[param1value2, param2value1]'''
							source = MethodSource.from(TestClassIteratedParameterizedStep.name,
								"step2", '''«String.name», «String.name»''')
							type = Type.TEST
						],
						ComparableTestIdentifier.build [
							uniqueId = step2UID.append(
								TestStep.simpleName, '''step2(«"param1value2".digist»,«"param2value2".digist»)''')
							displayName = '''[param1value2, param2value2]'''
							source = MethodSource.from(TestClassIteratedParameterizedStep.name,
								"step2", '''«String.name», «String.name»''')
							type = Type.TEST
						]
					]
				]
			]
		]
		testDiscovery(TestClassIteratedParameterizedStep, expected)
	}

	@Test
	def void testIteratedClass() {
		val expected = getEngineTestIdentifier[
			val testClassUID = TAPIR_ENGINE_UID.append(TestSuite.simpleName, IteratedTestClass.name)
			uniqueId = testClassUID
			displayName = IteratedTestClass.name
			source = ClassSource.from(IteratedTestClass)
			type = Type.CONTAINER
			val value1UID = testClassUID.append(TestClass.simpleName, '''«IteratedTestClass.name»(«"value1".digist»)''')
			val value2UID = testClassUID.append(TestClass.simpleName, '''«IteratedTestClass.name»(«"value2".digist»)''')
			children = #[
				ComparableTestIdentifier.build [
					uniqueId = value1UID
					displayName = '''[value1]'''
					source = ClassSource.from(IteratedTestClass)
					type = Type.CONTAINER
					val value1Step2UID = value1UID.append(TestStep.simpleName, '''step2''')
					children = #[
						ComparableTestIdentifier.build [
							uniqueId = value1UID.append(TestStep.simpleName, '''step1''')
							displayName = '''step1'''
							source = MethodSource.from(IteratedTestClass.name, "step1", "")
							type = Type.TEST
						],
						ComparableTestIdentifier.build [
							uniqueId = value1Step2UID
							displayName = '''step2'''
							source = MethodSource.from(IteratedTestClass.name, "step2", String.name)
							type = Type.CONTAINER
							children = #[
								ComparableTestIdentifier.build [
									uniqueId = value1Step2UID.append(TestStep.simpleName, '''step2(«"value1".digist»)''')
									displayName = '''[value1]'''
									source = MethodSource.from(IteratedTestClass.name, "step2", String.name)
									type = Type.TEST
								],
								ComparableTestIdentifier.build [
									uniqueId = value1Step2UID.append(TestStep.simpleName, '''step2(«"value2".digist»)''')
									displayName = '''[value2]'''
									source = MethodSource.from(IteratedTestClass.name, "step2", String.name)
									type = Type.TEST
								]
							]
						]
					]
				],
				ComparableTestIdentifier.build [
					uniqueId = value2UID
					displayName = '''[value2]'''
					source = ClassSource.from(IteratedTestClass)
					type = Type.CONTAINER
					val value2Step2UID = value2UID.append(TestStep.simpleName, '''step2''')
					children = #[
						ComparableTestIdentifier.build [
							uniqueId = value2UID.append(TestStep.simpleName, '''step1''')
							displayName = '''step1'''
							source = MethodSource.from(IteratedTestClass.name, "step1", "")
							type = Type.TEST
						],
						ComparableTestIdentifier.build [
							uniqueId = value2Step2UID
							displayName = '''step2'''
							source = MethodSource.from(IteratedTestClass.name, "step2", String.name)
							type = Type.CONTAINER
							children = #[
								ComparableTestIdentifier.build [
									uniqueId = value2Step2UID.append(TestStep.simpleName, '''step2(«"value1".digist»)''')
									displayName = '''[value1]'''
									source = MethodSource.from(IteratedTestClass.name, "step2", String.name)
									type = Type.TEST
								],
								ComparableTestIdentifier.build [
									uniqueId = value2Step2UID.append(TestStep.simpleName, '''step2(«"value2".digist»)''')
									displayName = '''[value2]'''
									source = MethodSource.from(IteratedTestClass.name, "step2", String.name)
									type = Type.TEST
								]
							]
						]
					]
				]
			]
		]
		testDiscovery(IteratedTestClass, expected)
	}

}
