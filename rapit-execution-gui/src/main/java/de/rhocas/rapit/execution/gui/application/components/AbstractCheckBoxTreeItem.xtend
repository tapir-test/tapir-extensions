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
package de.rhocas.rapit.execution.gui.application.components

import de.bmiag.tapir.execution.model.Identifiable
import de.rhocas.rapit.execution.gui.application.data.ExecutionStatus
import java.util.List
import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.control.CheckBoxTreeItem
import javafx.scene.control.TreeItem

/**
 * A selectable tree item which holds an instance of {@link Identifiable} and contains the execution status of the test item.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
abstract class AbstractCheckBoxTreeItem<T extends Identifiable> extends CheckBoxTreeItem<Identifiable> {

	ObjectProperty<ExecutionStatus> executionStatus = new SimpleObjectProperty(ExecutionStatus.NONE)

	new(T t) {
		super(t)

		children.all = createChildren
	}

	def abstract List<TreeItem<Identifiable>> createChildren()

	def executionStatusProperty() {
		executionStatus
	}

}
