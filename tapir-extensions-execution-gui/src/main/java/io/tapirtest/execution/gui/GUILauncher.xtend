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
package io.tapirtest.execution.gui

import io.tapirtest.execution.gui.application.views.MainView
import de.saxsys.mvvmfx.FluentViewLoader
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.image.Image
import javafx.stage.Stage

/**
 * This is the GUI launcher for tapir test cases. It allows to start arbitrary parts of a test case or a test suite, as long as the tests and the
 * bootstrap configuration can be found in the classpath.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class GUILauncher extends Application {

	def static void main(String[] args) {
		GUILauncher.launch(args)
	}

	override start(Stage primaryStage) throws Exception {
		try {
			val tuple = FluentViewLoader.javaView(MainView).load
			val scene = new Scene(tuple.view)

			primaryStage.title = 'tapir-extensions Execution GUI'
			primaryStage.icons += new Image(GUILauncher.classLoader.getResourceAsStream('tapir-extensions-app-icon.png'))
			primaryStage.scene = scene
			primaryStage.maximized = true
			primaryStage.show

			tuple.viewModel.start(parameters)
		} catch (IllegalArgumentException ex) {
			printError(ex)
			printUsage()
		}
	}

	private def printError(IllegalArgumentException exception) {
		System.err.println('''Error: «exception.localizedMessage»''')
	}

	private def printUsage() {
		System.err.println('''Usage: java «GUILauncher.name» <test class or test suite>''')
	}

}
