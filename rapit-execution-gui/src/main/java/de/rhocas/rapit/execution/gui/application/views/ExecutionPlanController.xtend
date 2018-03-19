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

import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.StructuralElement
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import de.rhocas.rapit.execution.gui.application.ExecutionPlanHolder
import java.util.List

import static de.rhocas.rapit.execution.gui.application.ExecutionPlanHolder.*

/**
 * The controller for the execution plan GUI.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class ExecutionPlanController {

	ExecutionPlanViewModel executionPlanViewModel

	new(ExecutionPlanViewModel executionPlanViewModel) {
		this.executionPlanViewModel = executionPlanViewModel
	}

	def void initialize() {
		executionPlanViewModel.setExecutionPlan(ExecutionPlanHolder.executionPlan)
		executionPlanViewModel.expandExecutionPlan()
		executionPlanViewModel.selectAll
	}

	def void performSelectAll() {
		executionPlanViewModel.selectAll()
	}

	def void performDeselectAll() {
		executionPlanViewModel.deselectAll()
	}

	def void performStartTests() {
		val originalExecutionPlan = ExecutionPlanHolder.executionPlan
		val selectedItems = executionPlanViewModel.getSelected()
		val newExecutionPlan = filterExecutionPlan(originalExecutionPlan, selectedItems)
		ExecutionPlanHolder.executionPlan = newExecutionPlan
		
		executionPlanViewModel.close()
	}

	private def ExecutionPlan filterExecutionPlan(ExecutionPlan executionPlan, List<Identifiable> selectedItems) {
		// The clone method doesn't replace lists, but add items to it instead. Therefore we have to perform the copy manually.
		ExecutionPlan.build [
			id = executionPlan.id
			javaClass = executionPlan.javaClass
			children = executionPlan.children.filterStructuralElements(selectedItems)
		]
	}

	private def Iterable<StructuralElement> filterStructuralElements(Iterable<StructuralElement> structuralElements, List<Identifiable> selectedItems) {
		structuralElements.filter[selectedItems.contains(it)].map [ structuralElement |
			// The clone method doesn't replace lists, but add items to it instead. Therefore we have to perform the copy manually.
			if (structuralElement instanceof TestSuite) {
				TestSuite.build [
					id = structuralElement.id
					javaClass = structuralElement.javaClass
					name = structuralElement.name
					artificial = structuralElement.artificial
					description = structuralElement.description
					children = structuralElement.children.filterStructuralElements(selectedItems)
					issues = structuralElement.issues
					parallelized = structuralElement.parallelized
					parent = structuralElement.parent
					proceedOnFailure = structuralElement.proceedOnFailure
					tags = structuralElement.tags
					title = structuralElement.title
				]
			} else if (structuralElement instanceof TestClass) {
				TestClass.build [
					description = structuralElement.description
					id = structuralElement.id
					issues = structuralElement.issues
					javaClass = structuralElement.javaClass
					name = structuralElement.name
					parameters = structuralElement.parameters
					parent = structuralElement.parent
					steps = structuralElement.steps.filterSteps(selectedItems)
					tags = structuralElement.tags
					title = structuralElement.title
				]
			}
		]
	}

	private def Iterable<TestStep> filterSteps(Iterable<TestStep> testSteps, List<Identifiable> selectedItems) {
		testSteps.filter[selectedItems.contains(it)]
	}

	def void performCancel() {
		val originalExecutionPlan = ExecutionPlanHolder.executionPlan

		// Create an (almost) empty execution plan
		ExecutionPlanHolder.executionPlan = ExecutionPlan.build [
			id = originalExecutionPlan.id
			javaClass = originalExecutionPlan.javaClass
		]
		
		executionPlanViewModel.close()
	}

}
