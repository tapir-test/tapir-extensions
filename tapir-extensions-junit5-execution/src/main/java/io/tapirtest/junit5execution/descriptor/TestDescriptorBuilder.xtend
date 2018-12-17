package io.tapirtest.junit5execution.descriptor

import com.google.common.collect.Multimaps
import de.bmiag.tapir.core.label.LabelProvider
import de.bmiag.tapir.execution.TapirExecutor
import de.bmiag.tapir.execution.model.ExecutionModelElement
import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.JavaClassBased
import de.bmiag.tapir.execution.model.StructuralElementContainer
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import java.util.List
import org.junit.platform.engine.TestDescriptor
import org.junit.platform.engine.TestDescriptor.Type
import org.junit.platform.engine.UniqueId
import org.junit.platform.engine.support.descriptor.ClassSource
import org.junit.platform.engine.support.descriptor.MethodSource
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.ConfigurableApplicationContext
import org.springframework.stereotype.Component
import de.bmiag.tapir.execution.model.StructuralElement

/**
 * The {@code TestDescriptorBuilder} is responsible for building the {@link TestDescriptor} hierarchy. The creation relies on
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 */
@Component
class TestDescriptorBuilder {

	@Autowired
	LabelProvider labelProvider

	@Autowired
	TestDescriptorRegistry testDescriptorRegistry

	@Autowired
	extension UniqueIdCalculator uniqueIdCalculator

	/**
	 * Creates a {@link TapirExecutableTestDescriptor} which's
	 * {@link TapirExecutableTestDescriptor#execute(org.junit.platform.engine.EngineExecutionListener) execute} method is the
	 * main entry point for executing tapir tests. The created JUnit test descriptors are structured hierarchically.
	 * 
	 * @param executionPlan
	 *            The underlying tapir execution plan
	 * @param parentUniqueId
	 *            The parent unique Id (usually the unique id of the engine)
	 * @param tapirExecutor
	 *            The executor which is used to execute tapir tests
	 * @param applicationContext
	 *            The Spring application context
	 * @return the executable test descriptor
	 */
	def TapirExecutableTestDescriptor buildExecutableTestDescriptor(ExecutionPlan executionPlan, UniqueId parentUniqueId,
		TapirExecutor tapirExecutor, ConfigurableApplicationContext applicationContext) {

		val javaClassBasedChildren = executionPlan.children.toList
		val rootElement = if(javaClassBasedChildren.size == 1) {
				javaClassBasedChildren.head
			} else {
				executionPlan as JavaClassBased
			}



		val executableTestDescriptor = (rootElement as ExecutionModelElement).createAndRegister [
			new TapirExecutableTestDescriptor(calculateUniqueId(parentUniqueId), rootElement.displayText,
				ClassSource.from(rootElement.javaClass), tapirExecutor, applicationContext)
		]
		switch rootElement {
			TestClass:
				processSteps(executableTestDescriptor, rootElement.steps)
			StructuralElementContainer:
				processChildren(executableTestDescriptor, rootElement.children)
		}
		executableTestDescriptor
	}

	

	def protected TestDescriptor buildTestDescriptor(ExecutionModelElement executionModelElement, UniqueId parentUniqueId, boolean shrinkName) {
		switch executionModelElement {
			TestSuite: executionModelElement.buildTestDescriptor(parentUniqueId)
			TestClass: executionModelElement.buildTestDescriptor(parentUniqueId, shrinkName)
			TestStep: executionModelElement.buildTestDescriptor(parentUniqueId)
			default: throw new IllegalArgumentException('''getDescription: Unhandled parameter type: «executionModelElement.class.name»''')
		}
	}

	def protected TestDescriptor buildTestDescriptor(ExecutionModelElement executionModelElement, UniqueId parentUniqueId) {
		buildTestDescriptor(executionModelElement, parentUniqueId, false)
	}

	def protected TestDescriptor buildTestDescriptor(TestSuite testSuite, UniqueId parentUniqueId) {
		val testSuiteDescriptor = testSuite.createAndRegister [
			new TapirTestDescriptor(calculateUniqueId(parentUniqueId), testSuite.title.orElse(testSuite.name),
				ClassSource.from(testSuite.javaClass), Type.CONTAINER)
		]
		testSuiteDescriptor.processChildren(testSuite.children)
		testSuiteDescriptor
	}

	def protected TestDescriptor buildTestDescriptor(TestClass testClass, UniqueId parentUniqueId, boolean shrinkName) {
		val testClassDescriptor = testClass.createAndRegister [
			new TapirTestDescriptor(calculateUniqueId(parentUniqueId), testClass.getDisplayText(shrinkName), ClassSource.from(testClass.javaClass),
				Type.CONTAINER)
		]

		processSteps(testClassDescriptor, testClass.steps)
		testClassDescriptor
	}

	def protected void processChildren(TestDescriptor testClassDescriptor, List<StructuralElement> structuralElements) {
		val parentIsRoot = testClassDescriptor instanceof TapirExecutableTestDescriptor
		
		val classMap = Multimaps.index(structuralElements, [javaClass])
		
		classMap.asMap.forEach [ javaClass, children |
			if(children.size > 1) {
				val firstChild = children.head as TestClass
				val parentDescriptor = 
					if (!parentIsRoot) {
						val artificialSuite = TestClass.build [
							id = firstChild.id
							name = firstChild.name
							it.javaClass = firstChild.javaClass
							description = firstChild.description
							title = firstChild.title
							parent = firstChild.parent
						]
						val artificialDescriptor = new TapirTestDescriptor(artificialSuite.calculateUniqueId(testClassDescriptor.uniqueId),
							artificialSuite.title.orElse(artificialSuite.name), ClassSource.from(javaClass), Type.CONTAINER)
						testClassDescriptor.addChild(artificialDescriptor)
						artificialDescriptor
					} else {
						testClassDescriptor
					}
				children.forEach [
					parentDescriptor.addChild(buildTestDescriptor(parentDescriptor.uniqueId, true))
				]
			} else {
				children.forEach [
					testClassDescriptor.addChild(buildTestDescriptor(testClassDescriptor.uniqueId))
				]
			}
		]
	}

	def protected void processSteps(TestDescriptor testClassDescriptor, List<TestStep> testSteps) {
		val methodMap = Multimaps.index(testSteps, [javaMethod])
		methodMap.asMap.forEach [ javaMethod, steps |
			val artificialStepNeeded = steps.size > 1
			if(artificialStepNeeded) {
				val firstStep = steps.head
				val artificialStep = TestStep.build [
					id = firstStep.id
					name = firstStep.name
					it.javaMethod = firstStep.javaMethod
					description = firstStep.description
					title = firstStep.title
					parentTestClass = firstStep.parentTestClass
				]
				val artificialDescriptor = new TapirTestDescriptor(artificialStep.calculateUniqueId(testClassDescriptor.uniqueId),
					artificialStep.title.orElse(artificialStep.name), MethodSource.from(javaMethod), Type.CONTAINER)
				testClassDescriptor.addChild(artificialDescriptor)
				steps.forEach [
					artificialDescriptor.addChild(buildTestDescriptor(artificialDescriptor.uniqueId, true))
				]
			} else {
				steps.forEach [
					testClassDescriptor.addChild(buildTestDescriptor(testClassDescriptor.uniqueId))
				]
			}
		]
	}

	def protected TestDescriptor buildTestDescriptor(TestStep testStep, UniqueId parentUniqueId) {

		buildTestDescriptor(testStep, parentUniqueId, false)
	}

	def protected TestDescriptor buildTestDescriptor(TestStep testStep, UniqueId parentUniqueId, boolean shrinkName) {

		testStep.createAndRegister [
			new TapirTestDescriptor(calculateUniqueId(parentUniqueId), testStep.getDisplayText(shrinkName),
				MethodSource.from(testStep.javaMethod), Type.TEST)
		]
	}

	def protected <E extends ExecutionModelElement, T extends TestDescriptor> T createAndRegister(E executionModelElement,
		(E)=>T testDescriptorSupplier) {
		val testDescriptor = testDescriptorSupplier.apply(executionModelElement)
		testDescriptorRegistry.registerTestDescriptor(executionModelElement, testDescriptor)
		testDescriptor
	}

	def protected String getDisplayText(JavaClassBased javaClassBased) {
		switch javaClassBased {
			TestSuite: javaClassBased.displayText
			TestClass: javaClassBased.getDisplayText(false)
			ExecutionPlan : javaClassBased.displayText
			default: throw new IllegalArgumentException('''getDisplayText: Unhandled parameter type: «javaClassBased.class.name»''')
		}
	}

	def protected String getDisplayText(TestStep testStep, boolean shrinkStepName) {
		if(testStep.parameters.empty) {
			testStep.title.orElse(testStep.name)
		} else {
			'''«IF !shrinkStepName»«testStep.title.orElse(testStep.name)» «ENDIF»[«FOR parameter : testStep.parameters SEPARATOR ", "»«labelProvider.getLabel(parameter.value)»«ENDFOR»]'''
		}
	}

	def protected String getDisplayText(TestSuite testSuite) {
		testSuite.title.orElse(testSuite.name)
	}

	def protected String getDisplayText(TestClass testClass, boolean shrinkName) {
		if(testClass.parameters.empty) {
			testClass.title.orElse(testClass.name)
		} else {
			'''«IF !shrinkName»«testClass.title.orElse(testClass.name)» «ENDIF»[«FOR parameter : testClass.parameters SEPARATOR ", "»«labelProvider.getLabel(parameter.value)»«ENDFOR»]'''
		}
	}

	def protected String getDisplayText(ExecutionPlan executionPlan) {
		executionPlan.javaClass.name
	}

}
