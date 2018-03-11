package de.rhocas.rapit.datasource.excel.test

import de.bmiag.tapir.datasource.resource.annotations.Resource
import de.bmiag.tapir.execution.annotations.parameter.IteratedParameter
import de.bmiag.tapir.execution.annotations.step.Step
import de.bmiag.tapir.execution.annotations.testclass.TestClass
import java.util.Date
import java.util.List
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.core.convert.ConversionService

import static org.junit.Assert.assertEquals

@TestClass
class ExcelDataSourceTest {

	@Autowired
	ConversionService conversionService

	val List<User> users = newArrayList

	@Step
	def rememberUserContent(@IteratedParameter @Resource('users.xlsx') User user) {
		users.add(user)
	}

	@Step
	def compareUserContent() {
		assertEquals(#[
			User.build [
				id = 1
				username = 'John'
				password = 'pass123'
			],
			User.build [
				id = 42
				username = 'Jack'
				password = 'password'
				dateOfBirth = conversionService.convert('01.01.1980', Date)
			],
			User.build [
				id = 999
				username = 'Jim'
				password = 'secret123'
			]
		], users)
	}

}
