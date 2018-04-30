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
import javafx.beans.value.ObservableValue
import javafx.scene.control.TreeTableColumn.CellDataFeatures
import javafx.util.Callback
import de.bmiag.tapir.execution.model.Parameterized
import javafx.beans.property.SimpleStringProperty

/**
 * A cell value factory which extracts the parameters from {@link Parameterized} elements.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class ParametersCellValueFactory implements Callback<CellDataFeatures<Identifiable, String>, ObservableValue<String>> {

	override call(CellDataFeatures<Identifiable, String> cellDataFeatures) {
		val value = cellDataFeatures.value.value

		if (value instanceof Parameterized) {
			val parameters = value.parameters

			return new SimpleStringProperty(parameters.join(',', [parameter|'''«parameter.name» = «parameter.label»''']))
		}
	}

}
