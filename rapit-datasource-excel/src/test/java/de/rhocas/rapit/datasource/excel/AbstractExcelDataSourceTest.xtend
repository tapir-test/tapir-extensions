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
package de.rhocas.rapit.datasource.excel

import de.bmiag.tapir.data.Immutable
import java.util.Optional
import org.junit.Rule
import org.junit.Test
import org.junit.rules.ExpectedException
import org.springframework.core.io.ClassPathResource

import static org.hamcrest.core.Is.is
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertThat
import static org.junit.Assert.assertTrue

class AbstractExcelDataSourceTest {

	@Rule
	public val expectedException = ExpectedException.none

	@Test
	def void xlsxFilesShouldBeReadable() {
		excelFileShouldBeReadable('user.xlsx')
	}

	@Test
	def void xlsFilesShouldBeReadable() {
		excelFileShouldBeReadable('user.xls')
	}

	@Test
	def void otherFilesShouldNotBeReadable() {
		val resource = new ClassPathResource('user.csv')
		val dataSource = new UserExcelDataSource

		assertFalse(dataSource.canHandle(resource))

		expectedException.expect(IllegalArgumentException)
		expectedException.expectMessage('Unknown extension for excel file. Only xls and xlsx files are supported.')
		dataSource.getData(resource)
	}

	@Test
	def void emptySheetShouldThrowException() {
		val resource = new ClassPathResource('emptysheet.xlsx')
		val dataSource = new UserExcelDataSource

		expectedException.expect(IllegalArgumentException)
		expectedException.expectMessage('The excel sheet contains no rows')
		dataSource.getData(resource)
	}

	private def void excelFileShouldBeReadable(String resourceName) {
		val resource = new ClassPathResource(resourceName)
		val dataSource = new UserExcelDataSource

		assertTrue(dataSource.canHandle(resource))
		val data = dataSource.getData(resource)

		assertThat(data.size, is(3))

		assertThat(data.get(0).username, is('John'))
		assertThat(data.get(0).password.get, is('pass123'))

		assertThat(data.get(1).username, is('Jack'))
		assertFalse(data.get(1).password.present)

		assertThat(data.get(2).username, is('Jim'))
		assertThat(data.get(2).password.get, is('secret123'))
	}
	
	@Test
	def void sheetWithMissingColumnShouldThrowException() {
		val resource = new ClassPathResource('missingcolumn.xlsx')
		val dataSource = new UserExcelDataSource

		expectedException.expect(IllegalArgumentException)
		expectedException.expectMessage('No column named \'password\' specified')
		dataSource.getData(resource)
	}
	
}

@Immutable
class User {

	String username
	Optional<String> password

}

class UserExcelDataSource extends AbstractExcelDataSource<User> {

	override protected mapDataSet(ExcelRecord excelRecord) {
		User.build [
			var cell = excelRecord.get('username')
			username = cell.toString

			cell = excelRecord.get('password')
			if (cell !== null) {
				password = Optional.of(cell.toString)
			}
		]
	}

}
