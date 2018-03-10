# rapit
The rapit project contains various unofficial extensions for the tapir Test framework.

## How do I use it?

### rapit Datasource Excel

Note that this module uses the Apache Poi library, which means that the licenses of Apache Poi apply, when you use them.

The rapit Datasource Excel module is an adapter for tapir's datasource module. It allows you to fill your test data containers with data from Excel files. It works similar as the official CSV datasource module. To use it, you simply need to add it as Maven dependency. As all tapir modules, it contains an auto configuration.

	<dependency>
		<groupId>de.rhocas.rapit</groupId>
		<artifactId>rapit-datasource-excel</artifactId>
		<version>1.0.0</version>
	</dependency>

You can simply extend _AbstractExcelDataSource_ if you need full control over the conversion from the excel row to your data type.

	@Component
	class UserExcelDataSource extends AbstractExcelDataSource<User> {

		override protected mapDataSet(ExcelRecord excelRecord) {
			...
		}

	}

Now you can put the Excel file in your test classpath and inject the content into your test class with tapir's _Resource_ annotation.

	@Resource('user.xlsx')
	User user

That's it. As the _UserExcelDataSource_ is in the Spring context, it is automatically used by tapir to fill the _user_ field with the content of the _user.xlsx_ file. Note that currently only the first sheet of the Excel file is used. Furthermore, the first row of the excel sheet must contain the header names, which you can use to access the columns via the _ExcelRecord_ class.

The rapit Datasource Excel module comes also with a useful dynamic annotation, which generates a default data source implementation for you. It works like the _CSVDatasource_ annotation from tapir.

	@ExcelDataSource
	@Immutable
	class User {
			
		String username
		Optional<String> password
			
	}

Now rapit will generate the _UserExcelDataSource_ for you and maps the columns of the Excel file to the fields. In order for this to work, the headers in the Excel sheet must be named like the fields (_username_ and _password_ in this case). If that is not possible, you can also use the _ExcelColumn_ annotation to override the default mapping.

	@ExcelDataSource
	@Immutable
	class User {
			
		@ExcelColumn('user')
		String username
		
		@ExcelColumn('pass')
		Optional<String> password
			
	}

In this case the header names in the Excel sheet must be _user_ and _pass_.