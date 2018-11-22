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

package io.tapirtest.featureide.annotation

import de.bmiag.tapir.annotationprocessing.annotation.DynamicActive
import java.lang.annotation.Target

/**
 * This annotation can be used to generate a {@code tapir} variant from a variant configuration file created with the {@code FeatureIDE}.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
@DynamicActive
@Target(TYPE)
annotation FeatureIDEVariant {

	/**
	 * The path to a variant configuration file from the {@code FeatureIDE} containing a set of features. The file path is relative to the annotated class.
	 * If the file path starts with a slash ({@code /}), the file path is absolute. If this value is not given, it is assumed that the configuration model is
	 * contained in an xml file next to the annotated class with the same name as the annotated class.
	 * 
	 * @since 1.1.0
	 */
	String value = ''
	
	/**
	 * The name of the variant. If this is not specified, the class name will be used instead.
	 * 
	 * @since 1.1.0
	 */
	String name = ''
	
	/**
	 * The prefix prepended to each generated feature.
	 * 
	 * @since 1.1.0
	 */
	String prefix = ''
	
	/**
	 * The suffix appended to each generated feature.
	 * 
	 * @since 1.1.0
	 */
	String suffix = 'Feature'
	
	/**
	 * The package in which the features are contained. If this is empty, the package of the annotated class is used instead.
	 * 
	 * @since 1.1.0
	 */
	String featuresPackage = ''
	
}
