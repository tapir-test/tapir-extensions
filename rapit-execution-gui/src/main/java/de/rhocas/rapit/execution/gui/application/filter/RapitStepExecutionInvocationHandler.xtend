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
package de.rhocas.rapit.execution.gui.application.filter

import de.bmiag.tapir.execution.executor.StepExecutionInvocationHandler
import de.bmiag.tapir.execution.model.TestStep
import java.util.List
import org.springframework.stereotype.Component

/**
 * This invocation handler is called by tapir before each test step. In the case of the rapit launcher it makes sure that the test steps, which
 * have not been selected by the user, are simply skipped. As this invocation handler is active in each tapir test case once it is part of the 
 * classpath, it does not filter anything, if it has not been configured by the rapit launcher.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
@Component
class RapitStepExecutionInvocationHandler implements StepExecutionInvocationHandler {

	List<TestStep> selectedTestSteps

	def void setSelectedTestSteps(List<TestStep> selectedTestSteps) {
		this.selectedTestSteps = selectedTestSteps
	}

	override handlePreInvoke(TestStep testStep, Object testInstance) {
		// If the component has not been configured, it should not filter anything
		if (selectedTestSteps === null) {
			return Result.PROCEED
		}

		if (selectedTestSteps.contains(testStep)) {
			return Result.PROCEED
		} else {
			return Result.SKIP
		}
	}

	override handlePostInvoke(TestStep testStep, Object testInstance) {
		// Nothing to do here
	}

}
