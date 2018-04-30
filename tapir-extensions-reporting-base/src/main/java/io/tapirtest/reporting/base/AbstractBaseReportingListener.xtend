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
 package io.tapirtest.reporting.base

import de.bmiag.tapir.execution.executor.ExecutionListener
import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import io.tapirtest.reporting.base.model.ExecutionReport
import io.tapirtest.reporting.base.model.ExecutionResult
import java.util.Map
import java.util.Optional
import java.util.concurrent.ConcurrentHashMap

/**
 * This is an abstract base for reporting listeners. It collects information about the actual execution and delegates afterwards to the concrete
 * implementation in order to create the actual report.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
abstract class AbstractBaseReportingListener implements ExecutionListener {

	var reportMap = new ConcurrentHashMap<Identifiable, ExecutionReport>

	override executionStarted(ExecutionPlan executionPlan) {
		started(executionPlan)
	}

	override executionSucceeded(ExecutionPlan executionPlan) {
		stopped(executionPlan, ExecutionResult.SUCCEEDED)
		finalizeReport(executionPlan, reportMap)
	}

	override executionFailed(ExecutionPlan executionPlan, Throwable throwable) {
		stopped(executionPlan, ExecutionResult.FAILED, throwable)
		finalizeReport(executionPlan, reportMap)
	}

	override suiteStarted(TestSuite testSuite) {
		started(testSuite)
	}

	override suiteSucceeded(TestSuite testSuite) {
		stopped(testSuite, ExecutionResult.SUCCEEDED)
	}

	override suiteFailed(TestSuite testSuite, Throwable throwable) {
		stopped(testSuite, ExecutionResult.FAILED, throwable)
	}

	override suiteSkipped(TestSuite testSuite) {
		stopped(testSuite, ExecutionResult.SKIPPED)
	}

	override classStarted(TestClass testClass) {
		started(testClass)
	}

	override classSucceeded(TestClass testClass) {
		stopped(testClass, ExecutionResult.SUCCEEDED)
	}

	override classFailed(TestClass testClass, Throwable throwable) {
		stopped(testClass, ExecutionResult.FAILED, throwable)
	}

	override classSkipped(TestClass testClass) {
		stopped(testClass, ExecutionResult.SKIPPED)
	}

	override stepStarted(TestStep testStep) {
		started(testStep)
	}

	override stepSucceeded(TestStep testStep) {
		stopped(testStep, ExecutionResult.SUCCEEDED)
	}

	override stepFailed(TestStep testStep, Throwable throwable) {
		stopped(testStep, ExecutionResult.FAILED, throwable)
	}

	override stepSkipped(TestStep testStep) {
		stopped(testStep, ExecutionResult.SKIPPED)
	}

	private def void started(Identifiable element) {
		val report = new ExecutionReport
		report.start = System.currentTimeMillis

		reportMap.put(element, report)
	}

	private def void stopped(Identifiable element, ExecutionResult result) {
		stopped(element, result, null)
	}

	private def void stopped(Identifiable element, ExecutionResult result, Throwable throwable) {
		val report = reportMap.get(element)

		report.result = result
		report.stop = System.currentTimeMillis
		report.throwable = Optional.ofNullable(throwable)
	}

	/**
	 * This is the method called by the base class after the execution is finished. The concrete implementation can convert the model to an arbitrary output.
	 * 
	 * @param executionPlan
	 * 		The execution plan from tapir.
	 * @param reportMap
	 * 		A mapping from the model elements within the execution plan to instances of {@link ExecutionReport}, which hold information about the
	 *      actual execution. Each element ({@link ExecutionPlan}, {@link TestSuite}, {@link TestClass}, {@link TestStep}) is mapped to a report
	 *      container.
	 */
	def void finalizeReport(ExecutionPlan executionPlan, Map<Identifiable, ExecutionReport> reportMap)

}
