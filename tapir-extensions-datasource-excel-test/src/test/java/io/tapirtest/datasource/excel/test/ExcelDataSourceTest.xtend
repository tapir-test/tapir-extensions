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
 package io.tapirtest.datasource.excel.test

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
