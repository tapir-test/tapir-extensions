package io.tapirtest.featuregen.annotation

import de.bmiag.tapir.annotationprocessing.annotation.DynamicActive
import java.lang.annotation.Target

/**
 * This annotation can be used to generate a {@code tapir} variant from a feature-gen variant.
 * 
 * @author Nils Christian Ehmke
 *  
 * @since 1.1.0
 */
@DynamicActive
@Target(TYPE)
annotation FeatureGenVariant {
	
	/**
	 * The name of the variant. If this is not specified, the class name will be used instead.
	 * 
	 * @since 1.1.0
	 */
	String name = ''
	
	/**
	 * This value should reference the class annotated with {@code FeatureIDEVariant}.
	 * 
	 * @since 1.1.0
	 */
	Class<?> variantClass
	
	/**
	 * This value should reference the class annotated with {@code FeatureGenFeatures}.
	 * 
	 * @since 1.1.0
	 */
	Class<?> featuresClass
	
	/**
     * The name of the property which determines the active variant. If not specified explicitly 'variant' is used
     * 
     * @since 1.2.0
     */
    String propertyName = 'variant'
	
}
