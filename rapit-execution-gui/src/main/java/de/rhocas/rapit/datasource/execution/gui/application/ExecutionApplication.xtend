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
 package de.rhocas.rapit.datasource.execution.gui.application

import de.rhocas.rapit.datasource.execution.gui.application.views.ExecutionPlanController
import de.rhocas.rapit.datasource.execution.gui.application.views.ExecutionPlanView
import de.rhocas.rapit.datasource.execution.gui.application.views.ExecutionPlanViewModel
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.layout.AnchorPane
import javafx.stage.Stage

/**
 * The actual GUI for this application.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class ExecutionApplication extends Application {

	override start(Stage primaryStage) throws Exception {
		val mainPane = createMainPane()
		val scene = new Scene(mainPane)

		primaryStage.title = 'rapit Execution GUI'
		primaryStage.scene = scene
		primaryStage.maximized = true
		primaryStage.show
	}

	private def createMainPane() {
		val pane = new AnchorPane

		val executionPlanView = new ExecutionPlanView
		AnchorPane.setBottomAnchor(executionPlanView, 0.0)
		AnchorPane.setLeftAnchor(executionPlanView, 0.0)
		AnchorPane.setRightAnchor(executionPlanView, 0.0)
		AnchorPane.setTopAnchor(executionPlanView, 0.0)
		pane.children.add(executionPlanView)

		val executionPlanViewModel = new ExecutionPlanViewModel(executionPlanView)
		val executionPlanController = new ExecutionPlanController(executionPlanViewModel)
		executionPlanView.executionPlanController = executionPlanController
		executionPlanController.initialize

		pane
	}

}
