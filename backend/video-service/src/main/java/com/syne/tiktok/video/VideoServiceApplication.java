package com.syne.tiktok.video;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;

/**
 * 视频服务启动类
 * <p>
 * 负责视频发布、浏览、点赞、收藏、评论等互动功能。
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.syne.tiktok.video.mapper")
@ComponentScan(basePackages = {"com.syne.tiktok.video", "com.syne.tiktok.common"})
public class VideoServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(VideoServiceApplication.class, args);
    }
}
