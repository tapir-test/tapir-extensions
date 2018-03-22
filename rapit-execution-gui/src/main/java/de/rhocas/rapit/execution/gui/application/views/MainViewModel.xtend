/*
 * MIT License
 * 
 * Copyright (c) 2018 Nils Christian Ehmke
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
package de.rhocas.rapit.execution.gui.application.views

import de.bmiag.tapir.bootstrap.TapirBootstrapper
import de.bmiag.tapir.execution.TapirExecutor.TapirExecutorFactory
import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import de.rhocas.rapit.execution.gui.application.components.ExecutionPlanTreeItem
import de.rhocas.rapit.execution.gui.application.components.TestStepTreeItem
import de.rhocas.rapit.execution.gui.application.data.Property
import de.rhocas.rapit.execution.gui.application.filter.RapitStepExecutionInvocationHandler
import java.util.List
import javafx.application.Application.Parameters
import javafx.beans.property.SimpleListProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.collections.FXCollections
import javafx.scene.control.CheckBoxTreeItem
import javafx.scene.control.TreeItem
import org.eclipse.xtend.lib.annotations.Accessors
import org.springframework.context.ConfigurableApplicationContext
import org.slf4j.LoggerFactory
import javafx.scene.control.Alert
import javafx.scene.control.Alert.AlertType
import de.bmiag.tapir.execution.model.TestClass

/**
 * The view model of the main page.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0 
 */
@Accessors
class MainViewModel {

	static val logger = LoggerFactory.getLogger(MainViewModel)

	val executionPlanRoot = new SimpleObjectProperty<TreeItem<Identifiable>>()
	val propertiesContent = new SimpleListProperty<Property>(FXCollections.observableArrayList())
	val selectedProperty = new SimpleObjectProperty<Property>
	val Class<?> testClass
	var ConfigurableApplicationContext tapirContext

	new(Parameters parameters) {
		val rawParameters = parameters.raw
		if (rawParameters.size < 1) {
			throw new IllegalArgumentException('The rapit launcher requires the test class or test suite as first parameter')
		}

		val firstParameter = rawParameters.get(0)
		try {
			testClass = Class.forName(firstParameter)
		} catch (ClassNotFoundException ex) {
			throw new IllegalArgumentException('''The class '«firstParameter»' can not be found''')
		}
	}

	/**
	 * This method is executed once everything else of the application is initialized.
	 */
	def void start() {
		performReinitializeExecutionPlan()
	}

	/**
	 * This method is performed when the user wants to reinitialize the execution plan.
	 */
	def void performReinitializeExecutionPlan() {
		try {
			// Set the given properties
			propertiesContent.value.filter[key !== null].forEach[System.setProperty(key, value)]

			// Restart the tapir context and show the execution plan
			val tapirExecutor = restartTapirContext()
			val executionPlan = tapirExecutor.executionPlan
			val executionPlanItem = new ExecutionPlanTreeItem(executionPlan)
			executionPlanRoot.set(executionPlanItem)
			selectAllNodes(executionPlanItem)
			expandNodes(executionPlanItem)
		} catch (Exception ex) {
			handleException(ex)
		}
	}

	private def restartTapirContext() {
		if (tapirContext !== null) {
			tapirContext.stop
		}
		tapirContext = TapirBootstrapper.bootstrap(testClass)

		val tapirExecutorFactory = tapirContext.getBean(TapirExecutorFactory)
		tapirExecutorFactory.getExecutorForClass(testClass)
	}

	private def void expandNodes(TreeItem<Identifiable> treeItem) {
		treeItem.expanded = true

		val value = treeItem.value
		if (value instanceof ExecutionPlan || value instanceof TestSuite) {
			treeItem.children.forEach[expandNodes]
		} else if (value instanceof TestClass) {
			treeItem.expanded = false
		}
	}

	/**
	 * This method is performed when the user wants to select all items.
	 */
	def void performSelectAll() {
		try {
			selectAllNodes(executionPlanRoot.get)
		} catch (Exception ex) {
			handleException(ex)
		}
	}

	private def void selectAllNodes(TreeItem<Identifiable> treeItem) {
		(treeItem as CheckBoxTreeItem<Identifiable>).selected = true
		treeItem.children.forEach[selectAllNodes]
	}
	
	/**
	 * This method is performed when the user wants to deselect all items.
	 */
	def void performDeselectAll() {
		try {
			deselectAllNodes(executionPlanRoot.get)
		} catch (Exception ex) {
			handleException(ex)
		}
	}

	private def void deselectAllNodes(TreeItem<Identifiable> treeItem) {
		(treeItem as CheckBoxTreeItem<Identifiable>).selected = false
		treeItem.children.forEach[deselectAllNodes]
	}
	
	/**
	 * This method is performed when the user wants to start the tests.
	 */
	def void performStartTests() {
		try {
			val tapirExecutor = restartTapirContext()

			// Configure our own invocation handler, which skips the tests if necessary
			val selectedSteps = getSelectedSteps(executionPlanRoot.get)
			val stepExecutionInvocationHandler = tapirContext.getBean(RapitStepExecutionInvocationHandler)
			stepExecutionInvocationHandler.selectedTestSteps = selectedSteps

			tapirExecutor.execute
		} catch (Exception ex) {
			handleException(ex)
		}
	}

	private def List<TestStep> getSelectedSteps(TreeItem<Identifiable> treeItem) {
		if (treeItem instanceof TestStepTreeItem) {
			if ((treeItem as CheckBoxTreeItem<Identifiable>).selected) {
				#[treeItem.value as TestStep]
			} else {
				#[]
			}
		} else {
			// All other tree items are no leafs, which means that we have to search them as well
			treeItem.children.map[selectedSteps] //
			.flatten //
			.toList
		}
	}
	
	/**
	 * This method is performed when the user wants to add a property entry.
	 */
	def performAddProperty() {
		try {
			propertiesContent.add(new Property())
		} catch (Exception ex) {
			handleException(ex)
		}
	}
	
	/**
	 * This method is performed when the user wants to delete a property entry.
	 */
	def performDeleteProperty() {
		try {
			val selectedProperty = selectedProperty.get
			if (selectedProperty !== null) {
				propertiesContent.remove(selectedProperty)
			}
		} catch (Exception ex) {
			handleException(ex)
		}
	}

	private def handleException(Exception exception) {
		logger.error('An exception occurred', exception)

		val alert = new Alert(AlertType.ERROR)
		alert.title = 'Error'
		alert.headerText = exception.localizedMessage
		alert.showAndWait
	}

}
