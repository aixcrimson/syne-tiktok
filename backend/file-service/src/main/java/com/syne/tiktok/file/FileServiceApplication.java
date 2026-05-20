package com.syne.tiktok.file;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.context.annotation.ComponentScan;

/**
 * 文件服务启动类
 * <p>
 * 负责文件上传、封面生成、MinIO 对象存储管理。
 */
@SpringBootApplication
@EnableDiscoveryClient
@ComponentScan(basePackages = {"com.syne.tiktok.file", "com.syne.tiktok.common"})
public class FileServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(FileServiceApplication.class, args);
    }
}
