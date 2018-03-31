package de.rhocas.rapit.execution.gui.application.listener

import de.bmiag.tapir.execution.executor.AbstractExecutionListener
import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import de.rhocas.rapit.execution.gui.application.components.AbstractCheckBoxTreeItem
import de.rhocas.rapit.execution.gui.application.data.ExecutionStatus
import javafx.scene.control.TreeItem
import org.apache.logging.log4j.LogManager
import org.springframework.stereotype.Component
import javafx.application.Platform

@Component
class RapitExecutionListener extends AbstractExecutionListener {
	
	static val logger = LogManager.getLogger(RapitExecutionListener)
	
	var AbstractCheckBoxTreeItem<ExecutionPlan> executionPlanRoot 
		
	override classSucceeded(TestClass testClass) {
		setStatus(testClass, ExecutionStatus.SUCCEEDED)
	}
	
	override classFailed(TestClass testClass, Throwable throwable) {
		setStatus(testClass, ExecutionStatus.FAILED)
	}
	
	override classSkipped(TestClass testClass) {
		setStatus(testClass, ExecutionStatus.SKIPPED)
	}
	
	override executionFailed(ExecutionPlan executionPlan, Throwable throwable) {
		setStatus(executionPlan, ExecutionStatus.FAILED)
	}
	
	override executionSucceeded(ExecutionPlan executionPlan) {
		setStatus(executionPlan, ExecutionStatus.SUCCEEDED)
	}
	
	override stepFailed(TestStep testStep, Throwable throwable) {
		setStatus(testStep, ExecutionStatus.FAILED)
	}
	
	override stepSkipped(TestStep testStep) {
		setStatus(testStep, ExecutionStatus.SKIPPED)
	}
	
	override stepSucceeded(TestStep testStep) {
		setStatus(testStep, ExecutionStatus.SUCCEEDED)
	}
	
	override suiteFailed(TestSuite testSuite, Throwable throwable) {
		setStatus(testSuite, ExecutionStatus.FAILED)
	}
	
	override suiteSkipped(TestSuite testSuite) {
		setStatus(testSuite, ExecutionStatus.SKIPPED)
	}
	
	override suiteSucceeded(TestSuite testSuite) {
		setStatus(testSuite, ExecutionStatus.SUCCEEDED)
	}
	
	private def setStatus(Identifiable testItem, ExecutionStatus executionStatus) {
		// If the component has not been configured, it should not do anything
		if (executionPlanRoot === null) {
			return
		}
		
		// Otherwise we search for the test item in our execution plan items
		val item = search(executionPlanRoot, testItem)
		if (item instanceof AbstractCheckBoxTreeItem<?>) {
			// And set its status
			Platform.runLater[item.executionStatusProperty.set(executionStatus)]
		} else {
			logger.warn('''Test item with «testItem.id» could not be found in the execution plan''')
		}
	}
	
	private def TreeItem<Identifiable> search(TreeItem<Identifiable> treeItem, Identifiable testItem) {
		if (treeItem.value == testItem) {
			return treeItem
		} else {
			for (child : treeItem.children) {
				val result = search(child, testItem)
				if (result !== null) {
					return result
				}
			}
		}
		
		return null
	}
	
	def setExecutionPlanRoot(AbstractCheckBoxTreeItem<ExecutionPlan> executionPlanRoot) {
		this.executionPlanRoot = executionPlanRoot
	}
	
	
}