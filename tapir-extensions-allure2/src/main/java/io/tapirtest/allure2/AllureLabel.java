package io.tapirtest.allure2;

/**
 * Contains all the valid Allure labels.
 * 
 * @author Oliver Libutzki {@literal <}oliver.libutzki@libutzki.de{@literal >}
 * 
 * @since 1.0.0
 */
public enum AllureLabel {

    OWNER( "owner" ), SEVERITY( "severity" ), ISSUE( "issue" ), TAG( "tag" ), TEST_TYPE( "testType" ), PARENT_SUITE( "parentSuite" ), SUITE( "suite" ), SUB_SUITE( "subSuite" ), PACKAGE( "package" ), EPIC( "epic" ), FEATURE( "feature" ), STORY( "story" ), TEST_CLASS( "testClass" ), TEST_METHOD( "testMethod" ), HOST( "host" ), THREAD( "thread" ), LANGUAGE( "language" ), FRAMEWORK( "framework" ), RESULT_FORMAT( "resultFormat" );

    private final String value;

    AllureLabel( final String value ) {
        this.value = value;
    }

    public String getValue( ) {
        return value;
    }
}