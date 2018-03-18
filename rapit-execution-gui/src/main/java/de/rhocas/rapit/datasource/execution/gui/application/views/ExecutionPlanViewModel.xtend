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
 package de.rhocas.rapit.datasource.execution.gui.application.views

import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.rhocas.rapit.datasource.execution.gui.application.components.ExecutionPlanTreeItem
import java.util.ArrayList
import java.util.List
import javafx.scene.control.CheckBoxTreeItem
import javafx.scene.control.TreeItem

/**
 * The view model for the execution plan GUI.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class ExecutionPlanViewModel {

	ExecutionPlanView executionPlanView

	new(ExecutionPlanView executionPlanView) {
		this.executionPlanView = executionPlanView
	}

	def setExecutionPlan(ExecutionPlan executionPlan) {
		executionPlanView.treeTableView.root = new ExecutionPlanTreeItem(executionPlan)
	}

	def expandExecutionPlan() {
		expandAll(executionPlanView.treeTableView.root)
	}

	private def void expandAll(TreeItem<Identifiable> item) {
		item.expanded = true
		item.children.forEach[child | child.expandAll]
	}

	def selectAll() {
		selectAll(executionPlanView.treeTableView.root as CheckBoxTreeItem<Identifiable>)
	}

	private def void selectAll(CheckBoxTreeItem<Identifiable> item) {
		item.selected = true
		item.children.forEach[child | (child as CheckBoxTreeItem<Identifiable>).selectAll]
	}

	def deselectAll() {
		deselectAll(executionPlanView.treeTableView.root as CheckBoxTreeItem<Identifiable>)
	}

	private def void deselectAll(CheckBoxTreeItem<Identifiable> item) {
		item.selected = false
		item.children.forEach[child | (child as CheckBoxTreeItem<Identifiable>).deselectAll]
	}
	
	def getSelected() {
		getSelected(executionPlanView.treeTableView.root as CheckBoxTreeItem<Identifiable>)
	}
	
	private def List<Identifiable> getSelected(CheckBoxTreeItem<Identifiable> item) {
		val selectedItems = new ArrayList
		if (item.selected) {
			selectedItems.add(item.value)
		}
		
		item.children.map[child | (child as CheckBoxTreeItem<Identifiable>).getSelected].forEach[l | selectedItems.addAll(l)]
		
		selectedItems
	}
	
	def close() {
		val window = executionPlanView.scene.window
		window.hide()
	}
	
}
