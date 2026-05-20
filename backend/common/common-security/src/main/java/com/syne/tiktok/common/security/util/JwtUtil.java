package com.syne.tiktok.common.security.util;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import lombok.extern.slf4j.Slf4j;

import java.util.Date;

/**
 * JWT 工具类
 * <p>
 * 提供 Token 的生成、解析和验证功能。
 * 密钥和过期时间应通过配置注入，此处为骨架实现。
 */
@Slf4j
public class JwtUtil {

    /** 默认密钥（生产环境应从配置中心读取） */
    private static final String DEFAULT_SECRET = "syne-tiktok-jwt-secret-key";

    /** 默认过期时间：24小时 */
    private static final long DEFAULT_EXPIRE_MS = 24 * 60 * 60 * 1000L;

    /**
     * 生成 JWT Token
     *
     * @param userId 用户ID
     * @param role   用户角色
     * @return JWT Token 字符串
     */
    public static String generateToken(Long userId, String role) {
        return generateToken(userId, role, DEFAULT_SECRET, DEFAULT_EXPIRE_MS);
    }

    /**
     * 生成 JWT Token（自定义密钥和过期时间）
     */
    public static String generateToken(Long userId, String role, String secret, long expireMs) {
        Algorithm algorithm = Algorithm.HMAC256(secret);
        return JWT.create()
                .withClaim("userId", userId)
                .withClaim("role", role)
                .withIssuedAt(new Date())
                .withExpiresAt(new Date(System.currentTimeMillis() + expireMs))
                .sign(algorithm);
    }

    /**
     * 解析 Token，获取用户ID
     *
     * @param token  JWT Token
     * @param secret 密钥
     * @return 用户ID，解析失败返回 null
     */
    public static Long getUserId(String token, String secret) {
        try {
            DecodedJWT jwt = verify(token, secret);
            return jwt.getClaim("userId").asLong();
        } catch (JWTVerificationException e) {
            log.warn("JWT 解析失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 解析 Token，获取用户角色
     */
    public static String getRole(String token, String secret) {
        try {
            DecodedJWT jwt = verify(token, secret);
            return jwt.getClaim("role").asString();
        } catch (JWTVerificationException e) {
            log.warn("JWT 解析失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 验证 Token 是否有效
     */
    public static boolean validateToken(String token, String secret) {
        try {
            verify(token, secret);
            return true;
        } catch (JWTVerificationException e) {
            return false;
        }
    }

    private static DecodedJWT verify(String token, String secret) {
        Algorithm algorithm = Algorithm.HMAC256(secret);
        JWTVerifier verifier = JWT.require(algorithm).build();
        return verifier.verify(token);
    }
}
