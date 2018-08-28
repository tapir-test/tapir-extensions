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
package io.tapirtest.execution.gui.application.components

import de.bmiag.tapir.execution.model.Identifiable
import io.tapirtest.execution.gui.application.data.ExecutionStatus
import javafx.scene.control.TreeTableRow

/**
 * This is a tree table row which is aware of the execution status of the tree item and uses a corresponding style class for the whole row.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
final class ExecutionStatusStyledTreeTableRow extends TreeTableRow<Identifiable> {

	override protected updateItem(Identifiable identifiable, boolean empty) {
		super.updateItem(identifiable, empty)

		// Remove a potential style class from an earlier run
		styleClass.removeAll('row-failed', 'row-skipped', 'row-succeeded')

		if (treeItem instanceof AbstractCheckBoxTreeItem<?>) {
			// Now add the new style class
			val executionStatus = (treeItem as AbstractCheckBoxTreeItem<?>).executionStatus
			val newStyleClass = findStyleClass(executionStatus)
			if (newStyleClass !== null) {
				styleClass.add(newStyleClass)
			}
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
