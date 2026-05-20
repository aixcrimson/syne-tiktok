package com.syne.tiktok.admin;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;

/**
 * 管理服务启动类
 * <p>
 * 负责视频审核、下架、用户管理（禁言/封号）、评论管理、举报处理。
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.syne.tiktok.admin.mapper")
@ComponentScan(basePackages = {"com.syne.tiktok.admin", "com.syne.tiktok.common"})
public class AdminServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(AdminServiceApplication.class, args);
    }
}
