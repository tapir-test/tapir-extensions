package io.tapirtest.junit5executiontest.expectation

import org.junit.platform.launcher.TestIdentifier
import org.junit.platform.launcher.TestPlan
import org.junit.platform.engine.UniqueId

class TestPlanConverter {

	def ComparableTestIdentifier convert(TestPlan testPlan) {
		testPlan.roots.head.convert(testPlan)
	}

	def private ComparableTestIdentifier convert(TestIdentifier testIdentifier, TestPlan testPlan) {
		ComparableTestIdentifier.build [
			uniqueId = UniqueId.parse(testIdentifier.uniqueId)
			displayName = testIdentifier.displayName
			source = testIdentifier.source
			type = testIdentifier.type
			val testIdentifierChildren = testPlan.getChildren(testIdentifier)
			children = (testIdentifierChildren).map[it.convert(testPlan)]
		]
	}

}
