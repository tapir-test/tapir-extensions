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

import de.bmiag.tapir.execution.model.Identifiable
import de.rhocas.rapit.execution.gui.application.components.DescriptionCellValueFactory
import de.rhocas.rapit.execution.gui.application.components.ExecutionStatusStyledTreeTableRow
import de.rhocas.rapit.execution.gui.application.components.ParametersCellValueFactory
import de.rhocas.rapit.execution.gui.application.data.Property
import javafx.geometry.Insets
import javafx.scene.control.Button
import javafx.scene.control.CheckBoxTreeItem
import javafx.scene.control.Label
import javafx.scene.control.Separator
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TreeTableColumn
import javafx.scene.control.TreeTableView
import javafx.scene.control.cell.CheckBoxTreeTableCell
import javafx.scene.control.cell.PropertyValueFactory
import javafx.scene.control.cell.TextFieldTableCell
import javafx.scene.control.cell.TreeItemPropertyValueFactory
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox

/**
 * The view of the main page.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0 
 */
class MainView extends VBox {
	
	new(MainViewModel mainViewModel) {
		padding = new Insets(10)
		disableProperty.bind(mainViewModel.readOnlyMode)

		stylesheets.add(MainView.canonicalName.replace('.', '/') + '.css')

		children.add(new HBox() => [
			margin = new Insets(0.0, 0.0, 10, 0.0)
			spacing = 10

			children.add(new Button() => [
				minWidth = 180
				text = 'Select All'
				
				onAction = [mainViewModel.performSelectAll]
			])

			children.add(new Button() => [
				minWidth = 180
				text = 'Deselect All'
				
				onAction = [mainViewModel.performDeselectAll]
			])
			
			children.add(new Button() => [
				minWidth = 180
				text = 'Reinitialize Execution Plan'

				HBox.setMargin(it, new Insets(0.0, 0.0, 0.0, 20.0))
				
				onAction = [mainViewModel.performReinitializeExecutionPlan]
			])
			
			children.add(new Button() => [
				minWidth = 180
				text = 'Start Tests'

				HBox.setMargin(it, new Insets(0.0, 0.0, 0.0, 20.0))
				
				onAction = [mainViewModel.performStartTests]
			])
		])
		
		children.add(new Separator() => [
			margin = new Insets(10.0, 0.0, 0.0, 0.0)
		])

		children.add(new Label() => [
			margin = new Insets(10.0, 0.0, 0.0, 0.0)
			text = 'Execution Plan'
		])
		
		children.add(new TreeTableView<Identifiable>() => [
			VBox.setVgrow(it, Priority.ALWAYS)
			margin = new Insets(5.0, 0.0, 0.0, 0.0)
			 
			rootProperty.bind(mainViewModel.executionPlanRoot)
			rowFactory = [ treeTableView | new ExecutionStatusStyledTreeTableRow()]
			
			mainViewModel.refreshTableObservable.addListener[
				observableValue, oldValue, newValue|
				refresh
			]
			
			tableMenuButtonVisible = true
			showRoot = false
			editable = true
			placeholder = new Label() => [
				text = 'No Execution Plan available'
			]

			columns.add(new TreeTableColumn<Identifiable, Boolean>() => [
				text = 'Execute'
				
				cellFactory = CheckBoxTreeTableCell.forTreeTableColumn(it)
				cellValueFactory = [cellDataFeature | (cellDataFeature.value as CheckBoxTreeItem<Identifiable>).selectedProperty]
			])

			columns.add(new TreeTableColumn<Identifiable, String>() => [
				text = 'Name'

				cellValueFactory = new TreeItemPropertyValueFactory('name')
			])

			columns.add(new TreeTableColumn<Identifiable, String>() => [
				text = 'Description'
				
				cellValueFactory = new DescriptionCellValueFactory()
			])

			columns.add(new TreeTableColumn<Identifiable, String>() => [
				text = 'Parameters'
				 
				cellValueFactory = new ParametersCellValueFactory()
			])
			
			// Distribute the columns evenly 
			columns.forEach[column|column.prefWidthProperty.bind(widthProperty.divide(columns.size))]
		])

		children.add(new Label() => [
			margin = new Insets(10.0, 0.0, 0.0, 0.0)
			text = 'Spring Properties'
		])
		
		children.add(new HBox() => [
			margin = new Insets(10.0, 0.0, 0.0, 0.0)
			spacing = 10
			
			children.add(new Button() => [
				text = 'Add Property'
				minWidth = 120
				
				onAction = [mainViewModel.performAddProperty]
			])
			
			children.add(new Button() => [
				text = 'Delete Property'
				minWidth = 120
				
				onAction = [mainViewModel.performDeleteProperty]
			])
		])
		
		children.add(new TableView<Property>() => [
			margin = new Insets(10.0, 0.0, 0.0, 0.0)
			editable = true
			placeholder = new Label() => [
				text = 'No Properties available'
			]
			 
			itemsProperty.bindBidirectional(mainViewModel.propertiesContent)
			mainViewModel.selectedProperty.bind(selectionModel.selectedItemProperty) 
			
			columns.add(new TableColumn<Property, String>() => [
				text = 'Key'
				
				cellValueFactory = new PropertyValueFactory('key')
				cellFactory = TextFieldTableCell.forTableColumn()
				onEditCommit = [event |
					val property = event.tableView.items.get(event.tablePosition.row)
					property.key = event.newValue
				]
			])
			
			columns.add(new TableColumn<Property, String>() => [
				text = 'Value'
				
				cellValueFactory = new PropertyValueFactory('value')
				cellFactory = TextFieldTableCell.forTableColumn()
				onEditCommit = [event |
					val property = event.tableView.items.get(event.tablePosition.row)
					property.value = event.newValue
				]
			])
			
			// Distribute the columns evenly 
			columns.forEach[column|column.prefWidthProperty.bind(widthProperty.divide(columns.size))]
		])
	}
	
}