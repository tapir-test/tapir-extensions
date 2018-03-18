package de.rhocas.rapit.datasource.execution.gui.application.components

import de.bmiag.tapir.execution.model.Identifiable
import java.util.List
import javafx.scene.control.CheckBoxTreeItem
import javafx.scene.control.TreeItem

/**
 * A selectable tree item which holds an instance of {@link Identifiable} and initializes its children in a lazy way.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
abstract class AbstractLazyCheckBoxTreeItem<T extends Identifiable> extends CheckBoxTreeItem<Identifiable> {
	
	boolean childrenInitialized

	new(T t) {
		super(t)
	}

	override final getChildren() {
		if (!childrenInitialized) {
			childrenInitialized = true
			super.children.all = createChildren()
		}

		super.children
	}
	
	def abstract List<TreeItem<Identifiable>> createChildren()
	
}