package de.rhocas.rapit.datasource.excel

import de.bmiag.tapir.data.Immutable
import java.util.Optional
import org.junit.Test
import org.springframework.core.io.ClassPathResource

import static org.hamcrest.core.Is.is
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertThat
import static org.junit.Assert.assertTrue

class AbstractExcelDataSourceTest {

	@Test
	def void xlsxFilesShouldBeReadable() {
		excelFileShouldBeReadable('user.xlsx')
	}

	@Test
	def void xlsFilesShouldBeReadable() {
		excelFileShouldBeReadable('user.xls')
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
