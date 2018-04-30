[![Build Status](https://travis-ci.org/tapir-test/tapir-extensions.svg?branch=master)](https://travis-ci.org/tapir-test/tapir-extensions)

# tapir extensions
The tapir extensions project contains various official open-source extensions for the tapir Test framework.

## How do I use it?

### tapir extensions Datasource Excel (since 1.0.0)

Note that this module uses the Apache Poi library, which means that the licenses of Apache Poi apply, when you use them.

The tapir extensions Datasource Excel module is an adapter for tapir's datasource module. It allows you to fill your test data containers with data from Excel files. It works similar as the official CSV datasource module. To use it, you simply need to add it as Maven dependency. 

	<dependency>
		<groupId>io.tapirtest</groupId>
		<artifactId>tapir-extensions-datasource-excel</artifactId>
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

The tapir extensions Datasource Excel module comes also with a useful dynamic annotation, which generates a default data source implementation for you. It works like the _CSVDatasource_ annotation from tapir.

	@ExcelDataSource
	@Immutable
	class User {
			
		String username
		Optional<String> password
			
	}

Now tapir extensions will generate the _UserExcelDataSource_ for you and maps the columns of the Excel file to the fields. In order for this to work, the headers in the Excel sheet must be named like the fields (_username_ and _password_ in this case). If that is not possible, you can also use the _ExcelColumn_ annotation to override the default mapping.

	@ExcelDataSource
	@Immutable
	class User {
			
		@ExcelColumn('user')
		String username
		
		@ExcelColumn('pass')
		Optional<String> password
			
	}

In this case the header names in the Excel sheet must be _user_ and _pass_.

The conversion from the excel cells to the field types is performed with Spring's _ConversionService_. The cell's content is read as String and converted with the conversion service. This allows you to tap into the conversion by overriding the binding of this bean. However, the string representation of the Excel cell might not always be usable for the conversion service, especially when it comes to dates and such. In those cases it is recommended to either implement your own datasource or to force Excel to interpret the content of the cell as text by using a leading apostrophe. 

### tapir extensions Reporting Base (since 1.0.0)

This module contains an implementation of tapir's execution listener, which can be used as a base for concrete reporting classes. To use it, you simply need to add it as Maven dependency. 

	<dependency>
		<groupId>io.tapirtest</groupId>
		<artifactId>tapir-extensions-reporting-base</artifactId>
		<version>1.0.0</version>
	</dependency>

tapir's default implementations use either frameworks which have to be informed about each event (JUnit) or have an internal model, which stores the events (Allure). However, some people might want to develop reporting listeners which simply convert the resulting execution at the end into a report instead of listening to each single execution event. The tapir extensions reporting base provides the _AbstractBaseReportingListener_ class which collects all the events during the execution. The concrete implementation of this class is informed after the execution and is provided with tapir's execution plan and a mapping to retrieve information about the execution.

### tapir extensions Excel Reporting (since 1.0.0)

Note that this module uses the Apache Poi library, which means that the licenses of Apache Poi apply, when you use it.

This module contains a reporting listener which writes an Excel report about the test execution. To use it, you simply need to add it as Maven dependency. 

	<dependency>
		<groupId>io.tapirtest</groupId>
		<artifactId>tapir-extensions-reporting-excel</artifactId>
		<version>1.0.0</version>
	</dependency>
	
As many other tapir modules, it contains an auto configuration, which means that it is already executed once it is part of the classpath. The execution listener has an order of 7000, which is equal to the Allure listener. Specify the output directory for the export with the property _rapid.reporting.excel.outputDirectory_. If you want to report to show step parameters, set the property _rapid.reporting.excel.displayStepParameters_ to _true_. In this case it is recommended to use a custom labeled data container with _singleLine_ set to _true_.

### tapir extensions Execution GUI (since 1.1.0)

Note that this module uses icons from the essential app icon set at https://www.iconfinder.com/iconsets/essential-app-1. This module uses also the mvvmFX framework, which means that the licenses of mvvmFX (and its dependencies) apply, when you use it.

This module contains a new launcher to start tapir test cases and test suites. It allows you to select which parts of the execution plan should be executed. To use it, you simply need to add it as Maven dependency. 

	<dependency>
		<groupId>io.tapirtest</groupId>
		<artifactId>tapir-extensions-execution-gui</artifactId>
		<version>1.1.0</version>
	</dependency>

Once the module is in your classpath, you can start the launcher by calling the main class "io.tapirtest.execution.gui.GUILauncher" with your test class or test suite as first parameter. In Eclipse you can add a launch configuration for this. Once the application is opened, it shows you the whole execution plan of the given test case. You can now select and deselect arbitrary steps in the execution plan. When you are finished, you can start the tests by clicking "Start Tests".

The GUI of the tapir extensions launcher allows you not only to start your tests, but also to show the execution plan with different properties. In the lower part of the application, you can add properties and update the view by clicking on "Reinitialize Execution Plan". This is very useful if you are using tapir's variant or conditional module.

Unfortunately the usage of the launcher has a drawback: In Eclipse you can only start your tests with it, if the test cases are located in the main source folder (src/main/java by default). Otherwise the launcher cannot find the classes. Note also that the GUI uses JavaFX, which means that you might have to install JavaFX in addition, if you are using OpenJDK.

## License

The tapir extensions project is licensed under the MIT license. You can find a copy of it in the LICENSE file in the root folder of the project. Note that third party libraries, which are added as transitive dependencies, may have further and other licenses.