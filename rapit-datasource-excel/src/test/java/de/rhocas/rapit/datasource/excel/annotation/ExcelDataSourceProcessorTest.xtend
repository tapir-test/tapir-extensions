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
package de.rhocas.rapit.datasource.excel.annotation

import de.bmiag.tapir.data.Immutable
import java.util.Optional
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static org.hamcrest.collection.IsMapContaining.hasKey
import static org.hamcrest.core.Is.is
import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertThat
import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import org.eclipse.xtend.lib.macro.services.Problem.Severity

/**
 * This is the unit test for the {@link ExcelDataSourceProcessor}.
 * 
 * @author Nils Christian Ehmke
 */
class ExcelDataSourceProcessorTest {
	
	XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(ExcelDataSourceProcessorTest.classLoader)
	
	@Test
	def dataSourceWithTwoFieldsShouldBeCorrectlyCompiled() {
		compilerTester.compile('''
		package de.rhocas.rapit.test
		
		import «ExcelDataSource.name»
		import «Immutable.name»
		
		@«ExcelDataSource.simpleName»
		@«Immutable.simpleName»
		class User {
			
			String username
			String password
			
		}
		''') [
			assertThat(allGeneratedResources.size, is(2))
			assertThat(allGeneratedResources, hasKey('/myProject/xtend-gen/de/rhocas/rapit/test/User.java'))
			assertThat(allGeneratedResources, hasKey('/myProject/xtend-gen/de/rhocas/rapit/test/UserExcelDataSource.java'))
			
			assertEquals('''
			package de.rhocas.rapit.test;
			
			import de.rhocas.rapit.datasource.excel.AbstractExcelDataSource;
			import de.rhocas.rapit.datasource.excel.ExcelRecord;
			import de.rhocas.rapit.test.User;
			import org.apache.poi.ss.usermodel.Cell;
			import org.springframework.beans.factory.annotation.Autowired;
			import org.springframework.core.convert.ConversionService;
			import org.springframework.stereotype.Component;
			
			@Component
			@SuppressWarnings("all")
			public class UserExcelDataSource extends AbstractExcelDataSource<User> {
			  @Autowired
			  private ConversionService conversionService;
			  
			  @Override
			  public User mapDataSet(final ExcelRecord excelRecord) {
			    return User.build(it -> {
			    	Cell cell;
			    	
			    	cell = excelRecord.get("username");
			    	
			    	if (cell != null) {
			    		final String cellContentString = cell.toString();
			    		final String cellContent = conversionService.convert(cellContentString, String.class);
			    		
			    		it.setUsername(cellContent);
			    	}
			    	
			    	cell = excelRecord.get("password");
			    	
			    	if (cell != null) {
			    		final String cellContentString = cell.toString();
			    		final String cellContent = conversionService.convert(cellContentString, String.class);
			    		
			    		it.setPassword(cellContent);
			    	}
			    }
			    );
			  }
			}
			'''.toString, allGeneratedResources.get('/myProject/xtend-gen/de/rhocas/rapit/test/UserExcelDataSource.java').toString)
		]
	}
	
	@Test
	def dataSourceWithExcelColumnShouldOverrideDefaultFieldNames() {
		compilerTester.compile('''
		package de.rhocas.rapit.test
		
		import «ExcelDataSource.name»
		import «Immutable.name»
		import «ExcelColumn.name»
		
		@«ExcelDataSource.simpleName»
		@«Immutable.simpleName»
		class User {
			
			@«ExcelColumn.simpleName»('user')
			String username
			@«ExcelColumn.simpleName»('pass')
			String password
			
		}
		''') [
			assertThat(allGeneratedResources.size, is(2))
			assertThat(allGeneratedResources, hasKey('/myProject/xtend-gen/de/rhocas/rapit/test/User.java'))
			assertThat(allGeneratedResources, hasKey('/myProject/xtend-gen/de/rhocas/rapit/test/UserExcelDataSource.java'))
			
			assertEquals('''
			package de.rhocas.rapit.test;
			
			import de.rhocas.rapit.datasource.excel.AbstractExcelDataSource;
			import de.rhocas.rapit.datasource.excel.ExcelRecord;
			import de.rhocas.rapit.test.User;
			import org.apache.poi.ss.usermodel.Cell;
			import org.springframework.beans.factory.annotation.Autowired;
			import org.springframework.core.convert.ConversionService;
			import org.springframework.stereotype.Component;
			
			@Component
			@SuppressWarnings("all")
			public class UserExcelDataSource extends AbstractExcelDataSource<User> {
			  @Autowired
			  private ConversionService conversionService;
			  
			  @Override
			  public User mapDataSet(final ExcelRecord excelRecord) {
			    return User.build(it -> {
			    	Cell cell;
			    	
			    	cell = excelRecord.get("user");
			    	
			    	if (cell != null) {
			    		final String cellContentString = cell.toString();
			    		final String cellContent = conversionService.convert(cellContentString, String.class);
			    		
			    		it.setUsername(cellContent);
			    	}
			    	
			    	cell = excelRecord.get("pass");
			    	
			    	if (cell != null) {
			    		final String cellContentString = cell.toString();
			    		final String cellContent = conversionService.convert(cellContentString, String.class);
			    		
			    		it.setPassword(cellContent);
			    	}
			    }
			    );
			  }
			}
			'''.toString, allGeneratedResources.get('/myProject/xtend-gen/de/rhocas/rapit/test/UserExcelDataSource.java').toString)
		]
	}
	
	@Test
	def dataSourceWithOptionalFieldShouldBeCorrectlyCompiled() {
		compilerTester.compile('''
		package de.rhocas.rapit.test
		
		import «ExcelDataSource.name»
		import «Immutable.name»
		import «Optional.name»
		
		@«ExcelDataSource.simpleName»
		@«Immutable.simpleName»
		class User {
			
			«Optional.simpleName»<String> username
			String password
			
		}
		''') [
			assertThat(allGeneratedResources.size, is(2))
			assertThat(allGeneratedResources, hasKey('/myProject/xtend-gen/de/rhocas/rapit/test/User.java'))
			assertThat(allGeneratedResources, hasKey('/myProject/xtend-gen/de/rhocas/rapit/test/UserExcelDataSource.java'))
			
			assertEquals('''
			package de.rhocas.rapit.test;
			
			import de.rhocas.rapit.datasource.excel.AbstractExcelDataSource;
			import de.rhocas.rapit.datasource.excel.ExcelRecord;
			import de.rhocas.rapit.test.User;
			import java.util.Optional;
			import org.apache.poi.ss.usermodel.Cell;
			import org.springframework.beans.factory.annotation.Autowired;
			import org.springframework.core.convert.ConversionService;
			import org.springframework.stereotype.Component;
			
			@Component
			@SuppressWarnings("all")
			public class UserExcelDataSource extends AbstractExcelDataSource<User> {
			  @Autowired
			  private ConversionService conversionService;
			  
			  @Override
			  public User mapDataSet(final ExcelRecord excelRecord) {
			    return User.build(it -> {
			    	Cell cell;
			    	
			    	cell = excelRecord.get("username");
			    	
			    	if (cell != null) {
			    		final String cellContentString = cell.toString();
			    		final String cellContent = conversionService.convert(cellContentString, String.class);
			    		
			    		it.setUsername(Optional.of(cellContent));
			    	}
			    	
			    	cell = excelRecord.get("password");
			    	
			    	if (cell != null) {
			    		final String cellContentString = cell.toString();
			    		final String cellContent = conversionService.convert(cellContentString, String.class);
			    		
			    		it.setPassword(cellContent);
			    	}
			    }
			    );
			  }
			}
			'''.toString, allGeneratedResources.get('/myProject/xtend-gen/de/rhocas/rapit/test/UserExcelDataSource.java').toString)
		]
	}
	
	@Test
	def dataSourceWithoutImmutableAnnotationShouldBeMarkedWithError() {
		compilerTester.compile('''
		package de.rhocas.rapit.test
		
		import «ExcelDataSource.name»
		
		@«ExcelDataSource.simpleName»
		class User {
		}
		''') [
			val problems = allProblems
			assertThat(problems, hasSize(1))
			
			val problem = problems.get(0)
			assertThat(problem.message, is('The annotation can only be used in conjunction with interface de.bmiag.tapir.data.Immutable.'))
			assertThat(problem.severity, is(Severity.ERROR))
		]
	}
	
}