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
import de.bmiag.tapir.execution.model.TestSuite
import de.rhocas.rapit.execution.gui.application.components.ExecutionPlanTreeItem
import de.rhocas.rapit.execution.gui.application.data.Property
import javafx.application.Application.Parameters
import javafx.beans.property.SimpleListProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.control.CheckBoxTreeItem
import javafx.scene.control.TreeItem
import org.eclipse.xtend.lib.annotations.Accessors
import org.springframework.context.ConfigurableApplicationContext
import javafx.collections.FXCollections

@Accessors
final class MainViewModel {

	val executionPlanRoot = new SimpleObjectProperty<TreeItem<Identifiable>>()
	val propertiesContent = new SimpleListProperty<Property>(FXCollections.observableArrayList())
	val selectedProperty = new SimpleObjectProperty<Property>
	val Class<?> testClass
	var ConfigurableApplicationContext tapirContext

	new(Parameters parameters) {
		val rawParameters = parameters.raw
		val firstParameter = rawParameters.get(0)
		testClass = Class.forName(firstParameter)

		performReinitializeExecutionPlan()
	}

	def void performReinitializeExecutionPlan() {
		// Set the given properties
		propertiesContent.value.filter[key !== null].forEach[System.setProperty(key, value)]

		// Restart the tapir context and show the execution plan
		val tapirExecutor = restartTapirContext()
		val executionPlan = tapirExecutor.executionPlan
		val executionPlanItem = new ExecutionPlanTreeItem(executionPlan)
		executionPlanRoot.set(executionPlanItem)
		selectAllNodes(executionPlanItem)
		expandNodes(executionPlanItem)
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
		}
	}

	def void performSelectAll() {
		selectAllNodes(executionPlanRoot.get)
	}

	private def void selectAllNodes(TreeItem<Identifiable> treeItem) {
		(treeItem as CheckBoxTreeItem<Identifiable>).selected = true
		treeItem.children.forEach[selectAllNodes]
	}

	def void performDeselectAll() {
		deselectAllNodes(executionPlanRoot.get)
	}

	private def void deselectAllNodes(TreeItem<Identifiable> treeItem) {
		(treeItem as CheckBoxTreeItem<Identifiable>).selected = false
		treeItem.children.forEach[deselectAllNodes]
	}

	def void performStartTests() {
		val tapirExecutor = restartTapirContext()
		tapirExecutor.execute
	}

	def void performCancel() {
		tapirContext.stop
	}
	
	def performAddProperty() {
		propertiesContent.add(new Property())
	}
	
	def performDeleteProperty() {
		val selectedProperty = selectedProperty.get
		if (selectedProperty !== null) {
			propertiesContent.remove(selectedProperty)
		}
	}

}
