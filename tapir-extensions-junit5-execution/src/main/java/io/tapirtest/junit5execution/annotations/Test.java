package io.tapirtest.junit5execution.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * This annotation is used for an artificial method which is generated by {@link TapirJUnit5AnnotationProcessorUtil} in order to
 * improve the Eclipse integration, see <a href="https://github.com/eclipse/xtext-xtend/issues/519">Xtend #519</a>.
 * 
 * @since 1.0.0
 * @author Oliver Libutzki {@literal <}oliver.libutzki@bmiag.de{@literal >}
 * 
 * @see <a href="https://github.com/eclipse/xtext-xtend/issues/519">Xtend #519</a>
 * 
 */
@Target( ElementType.METHOD )
@Retention( RetentionPolicy.SOURCE )
public @interface Test {

}