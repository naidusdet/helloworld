package com.example.helloworld.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {

    public static class UrlResponse {
        private String url;

        public UrlResponse(String url) {
            this.url = url;
        }

        @SuppressWarnings("unused")
        public String getUrl() {
            return url;
        }

        @SuppressWarnings("unused")
        public void setUrl(String url) {
            this.url = url;
        }
    }

    @GetMapping("/hello")
    public String hello() {
        return "Hello, Hanita Welcome to  GCP 2025 +" +
                "Digital Ways to Pay Lab EDB.";
    }

    @GetMapping("/barclaycard")
    public UrlResponse getUrl() {
        return new UrlResponse("https://www.barclaycard.co.uk/personal/credit-cards/balance-transfer-credit-cards");
    }

}
