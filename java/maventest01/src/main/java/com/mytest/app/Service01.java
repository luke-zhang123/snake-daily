package com.mytest.app;

import org.springframework.stereotype.Service;

@Service
public class Service01 {

    public String name() {
        return this.getClass().getName();
    }
}
