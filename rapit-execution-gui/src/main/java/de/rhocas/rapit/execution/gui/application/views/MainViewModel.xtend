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
import de.bmiag.tapir.execution.model.Identifiable
import de.rhocas.rapit.execution.gui.application.components.ExecutionPlanTreeItem
import javafx.application.Application.Parameters
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.control.TreeItem
import org.eclipse.xtend.lib.annotations.Accessors
import org.springframework.context.ConfigurableApplicationContext
import javafx.beans.property.SimpleStringProperty

@Accessors
final class MainViewModel {

	val executionPlanRoot = new SimpleObjectProperty<TreeItem<Identifiable>>()
	val propertiesContent = new SimpleStringProperty()
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
		val properties = propertiesContent.valueSafe
		properties.split('\n').stream //
		.map[trim] //
		.map[split('=')] //
		.filter[it.size == 2] //
		.forEach[System.setProperty(it.get(0), it.get(1))]

		// (Re)start the tapir context
		if (tapirContext !== null) {
			tapirContext.stop
		}
		tapirContext = TapirBootstrapper.bootstrap(testClass)

		// Display the execution plan
		val tapirExecutorFactory = tapirContext.getBean(TapirExecutorFactory)
		val tapirExecutor = tapirExecutorFactory.getExecutorForClass(testClass)
		val executionPlan = tapirExecutor.executionPlan
		executionPlanRoot.set(new ExecutionPlanTreeItem(executionPlan))
	}

	def void performSelectAll() {
	}

	def void performDeselectAll() {
	}

	def void performStartTests() {
	}

	def void performCancel() {
		tapirContext.stop
	}

}
