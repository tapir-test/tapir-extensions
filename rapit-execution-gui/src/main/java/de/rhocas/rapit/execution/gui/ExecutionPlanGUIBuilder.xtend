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
package de.rhocas.rapit.execution.gui

import de.bmiag.tapir.execution.plan.ExecutionPlanBuilder
import de.rhocas.rapit.execution.gui.application.ExecutionApplication
import de.rhocas.rapit.execution.gui.application.ExecutionPlanHolder
import javafx.application.Application

import static de.rhocas.rapit.execution.gui.application.ExecutionPlanHolder.*

/**
 * This is the implementation of an {@link ExecutionPlanBuilder} which starts a GUI to choose which elements should be executed.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0 
 */
final class ExecutionPlanGUIBuilder extends ExecutionPlanBuilder {

	override buildExecutionPlan(Class<?> javaClass) {
		// Get the original execution plan from the super class
		ExecutionPlanHolder.executionPlan = super.buildExecutionPlan(javaClass)

		// Now fire up the GUI and return its result as new execution plan
		Application.launch(ExecutionApplication, #[])
		ExecutionPlanHolder.executionPlan
	}

}
