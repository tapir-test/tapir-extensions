package io.tapirtest.featuregen.test.featuregen.feature;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.lang.annotation.ElementType;
import de.rhocas.featuregen.lib.FeatureGenSelectedFeatures;

/**
 * This annotation is used to mark which features the annotated variant provides.<br>
 * <br>
 * This annotation is generated.
 */
@Retention( RetentionPolicy.RUNTIME )
@Target( ElementType.TYPE )
@FeatureGenSelectedFeatures( )
public @interface FeatureGenTestSelectedFeatures {
	
	/**
	 * The selected features.
	 */
	FeatureGenTestFeature[] value( );
	
}
