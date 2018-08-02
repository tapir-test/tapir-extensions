package io.tapirtest.junit5executiontest;

import java.io.UnsupportedEncodingException;

import org.junit.platform.engine.UniqueId;
import org.springframework.util.DigestUtils;

public class JUnit5TestUtil {

    public static final UniqueId TAPIR_ENGINE_UID = UniqueId.forEngine( "tapir" );

    public static String getDigist( String string ) {
        try {
            return DigestUtils.md5DigestAsHex( string.getBytes( "UTF-8" ) );
        } catch ( UnsupportedEncodingException e ) {
            throw new RuntimeException( e );
        }
    }
}
