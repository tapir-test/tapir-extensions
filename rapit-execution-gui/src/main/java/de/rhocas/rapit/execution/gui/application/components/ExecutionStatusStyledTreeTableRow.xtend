package de.rhocas.rapit.execution.gui.application.components

import de.bmiag.tapir.execution.model.Identifiable
import de.rhocas.rapit.execution.gui.application.data.ExecutionStatus
import javafx.beans.value.WeakChangeListener
import javafx.scene.control.TreeTableRow

final class ExecutionStatusStyledTreeTableRow extends TreeTableRow<Identifiable> {

	override protected updateItem(Identifiable identifiable, boolean empty) {
		super.updateItem(identifiable, empty)

		// Remove a potential style class from an earlier run
		styleClass.removeAll('row-failed', 'row-skipped', 'row-succeeded')

		if (treeItem instanceof AbstractCheckBoxTreeItem<?>) {
			val executionStatusProperty = (treeItem as AbstractCheckBoxTreeItem<?>).executionStatusProperty
			executionStatusProperty.addListener(new WeakChangeListener[observableValue, oldValue, newValue| treeTableView.refresh])

			val executionStatus = executionStatusProperty.get
			val newStyleClass = findStyleClass(executionStatus)
			styleClass.add(newStyleClass)
		}
	}

	private def findStyleClass(ExecutionStatus executionStatus) {
		switch (executionStatus) {
			case FAILED: 'row-failed'
			case SUCCEEDED: 'row-succeeded'
			case SKIPPED: 'row-skipped'
			case NONE: null
			default: null
		}
	}

}
