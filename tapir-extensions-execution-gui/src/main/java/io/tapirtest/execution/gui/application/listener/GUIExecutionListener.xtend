/*
 * MIT License
 * 
 * Copyright (c) 2018 b+m Informatik AG
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 package io.tapirtest.execution.gui.application.listener

import de.bmiag.tapir.execution.executor.AbstractExecutionListener
import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import io.tapirtest.execution.gui.application.components.AbstractCheckBoxTreeItem
import io.tapirtest.execution.gui.application.data.ExecutionStatus
import javafx.application.Platform
import javafx.beans.property.ObjectProperty
import javafx.scene.control.TreeItem
import org.apache.logging.log4j.LogManager
import org.springframework.stereotype.Component

/**
 * This is the listener responsible for updating the view model during the execution of the tapir test cases.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
@Component
class GUIExecutionListener extends AbstractExecutionListener {
	
	static val logger = LogManager.getLogger(GUIExecutionListener)
	
	var AbstractCheckBoxTreeItem<ExecutionPlan> executionPlanRoot 
	var ObjectProperty<Object> refreshTableObservable
		
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
			Platform.runLater[
				item.executionStatus = executionStatus
				refreshTableObservable.value = new Object
			]
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
	
	def setRefreshTableObservable(ObjectProperty<Object> refreshTableObservable) {
		this.refreshTableObservable = refreshTableObservable
	}
	
	
}