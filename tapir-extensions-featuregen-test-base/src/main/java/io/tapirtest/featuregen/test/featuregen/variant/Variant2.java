package io.tapirtest.featuregen.test.featuregen.variant;

import io.tapirtest.featuregen.test.featuregen.feature.FeatureGenTestFeature;
import io.tapirtest.featuregen.test.featuregen.feature.FeatureGenTestSelectedFeatures;
import io.tapirtest.featuregen.test.featuregen.feature.FeatureGenTestVariant;

@FeatureGenTestSelectedFeatures( {FeatureGenTestFeature.F1_FEATURE, FeatureGenTestFeature.F2_FEATURE} )
public final class Variant2 implements FeatureGenTestVariant {
	
	private Variant2( ) {
	}
	
}
