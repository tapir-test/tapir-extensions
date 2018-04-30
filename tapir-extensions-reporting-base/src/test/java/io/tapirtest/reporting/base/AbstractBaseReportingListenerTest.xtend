package de.rhocas.rapit.reporting.base

import de.bmiag.tapir.execution.model.ExecutionPlan
import de.bmiag.tapir.execution.model.Identifiable
import de.bmiag.tapir.execution.model.TestClass
import de.bmiag.tapir.execution.model.TestStep
import de.bmiag.tapir.execution.model.TestSuite
import de.rhocas.rapit.reporting.base.model.ExecutionReport
import de.rhocas.rapit.reporting.base.model.ExecutionResult
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.Test

import static org.hamcrest.core.Is.is
import static org.junit.Assert.assertThat
import static org.junit.Assert.assertTrue
import static org.hamcrest.core.IsNot.not

class AbstractBaseReportingListenerTest {

	@Test
	def void positiveExecutionShouldBeHandledCorrectly() {
		val executionPlan = createExecutionPlan()

		val reportingListener = new ReportingListener()
		executeForListener(executionPlan, reportingListener, ExecutionResult.SUCCEEDED)

		val reportMap = reportingListener.reportMap
		
		for (n : 0..3) {
			val report = reportMap.get(getNthChild(executionPlan, n))
			
			assertThat(report.result, is(ExecutionResult.SUCCEEDED))
			assertThat(report.start, is(not(0L)))
			assertThat(report.stop, is(not(0L)))
		}
	}

	@Test
	def void failedExecutionShouldBeHandledCorrectly() {
		val executionPlan = createExecutionPlan()

		val reportingListener = new ReportingListener()
		executeForListener(executionPlan, reportingListener, ExecutionResult.FAILED)

		val reportMap = reportingListener.reportMap
		
		for (n : 0..3) {
			val report = reportMap.get(getNthChild(executionPlan, n))
			
			assertThat(report.result, is(ExecutionResult.FAILED))
			assertTrue(report.throwable.present)
			assertThat(report.start, is(not(0L)))
			assertThat(report.stop, is(not(0L)))
		}
	}
	
	@Test
	def void skippedExecutionShouldBeHandledCorrectly() {
		val executionPlan = createExecutionPlan()

		val reportingListener = new ReportingListener()
		executeForListener(executionPlan, reportingListener, ExecutionResult.SKIPPED)

		val reportMap = reportingListener.reportMap
		
		assertThat(reportMap.get(getNthChild(executionPlan, 0)).result, is(ExecutionResult.SUCCEEDED))
		for (n : 1..3) {
			val report = reportMap.get(getNthChild(executionPlan, n))
			
			assertThat(report.result, is(ExecutionResult.SKIPPED))
			assertThat(report.start, is(not(0L)))
			assertThat(report.stop, is(not(0L)))
		}
	}
	
	private def createExecutionPlan() {
		val executionPlan = ExecutionPlan.build [
			id = 1
			javaClass = AbstractBaseReportingListenerTest
		]

		val testSuite = TestSuite.build [
			id = 2
			javaClass = AbstractBaseReportingListenerTest
			parent = executionPlan
			proceedOnFailure = true
			artificial = false
			parallelized = false
			name = 'TestSuite'
		]
		executionPlan.children = #[testSuite]

		val testClass = TestClass.build [
			id = 3
			javaClass = AbstractBaseReportingListenerTest
			name = 'TestClass'
			parent = testSuite
		]
		testSuite.children = #[testClass]

		val testStep = TestStep.build [
			id = 4
			javaMethod = AbstractBaseReportingListener.methods.get(0)
			name = 'TestStep'
			parentTestClass = testClass
		]
		testClass.steps = #[testStep]

		executionPlan
	}

	private def dispatch Identifiable getNthChild(ExecutionPlan executionPlan, int n) {
		if (n == 0) {
			executionPlan
		} else {
			getNthChild(executionPlan.children.get(0), n - 1)
		}
	}

	private def dispatch Identifiable getNthChild(TestSuite testSuite, int n) {
		if (n == 0) {
			testSuite
		} else {
			getNthChild(testSuite.children.get(0), n - 1)
		}
	}

	private def dispatch Identifiable getNthChild(TestClass testClass, int n) {
		if (n == 0) {
			testClass
		} else {
			testClass.steps.get(0)
		}
	}

	private def dispatch void executeForListener(ExecutionPlan executionPlan, ReportingListener reportingListener, ExecutionResult executionResult) {
		reportingListener.executionStarted(executionPlan)
		executionPlan.children.forEach[executeForListener(it, reportingListener, executionResult)]

		switch (executionResult) {
			case SUCCEEDED: {
				reportingListener.executionSucceeded(executionPlan)
			}
			case FAILED: {
				reportingListener.executionFailed(executionPlan, new NullPointerException)
			}
			case SKIPPED: {
				reportingListener.executionSucceeded(executionPlan)
			}
		}
	}

	private def dispatch void executeForListener(TestSuite testSuite, ReportingListener reportingListener, ExecutionResult executionResult) {
		reportingListener.suiteStarted(testSuite)
		testSuite.children.forEach[executeForListener(it, reportingListener, executionResult)]
		
		switch (executionResult) {
			case SUCCEEDED: {
				reportingListener.suiteSucceeded(testSuite)
			}
			case FAILED: {
				reportingListener.suiteFailed(testSuite, new NullPointerException)
			}
			case SKIPPED: {
				reportingListener.suiteSkipped(testSuite)
			}
		}		
	}

	private def dispatch void executeForListener(TestClass testClass, ReportingListener reportingListener, ExecutionResult executionResult) {
		reportingListener.classStarted(testClass)
		testClass.steps.forEach[executeForListener(it, reportingListener, executionResult)]
		
		switch (executionResult) {
			case SUCCEEDED: {
				reportingListener.classSucceeded(testClass)
			}
			case FAILED: {
				reportingListener.classFailed(testClass, new NullPointerException)
			}
			case SKIPPED: {
				reportingListener.classSkipped(testClass)
			}
		}			
	}

	private def dispatch void executeForListener(TestStep testStep, ReportingListener reportingListener, ExecutionResult executionResult) {
		reportingListener.stepStarted(testStep)
		
		switch (executionResult) {
			case SUCCEEDED: {
				reportingListener.stepSucceeded(testStep)
			}
			case FAILED: {
				reportingListener.stepFailed(testStep, new NullPointerException)
			}
			case SKIPPED: {
				reportingListener.stepSkipped(testStep)
			}
		}	
	}

}

@Accessors
class ReportingListener extends AbstractBaseReportingListener {

	Map<Identifiable, ExecutionReport> reportMap

	override finalizeReport(ExecutionPlan executionPlan, Map<Identifiable, ExecutionReport> reportMap) {
		this.reportMap = reportMap
	}

}
