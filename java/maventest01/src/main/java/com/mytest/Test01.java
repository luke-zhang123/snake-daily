package com.mytest;

import com.mytest.app.Service01;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;

public class Test01 {

    public static void main(String[] args) {

        // ApplicationContext
        AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext();
        ac.scan("com.mytest.app");
        ac.refresh();

        Service01 service01 = ac.getBean("service01", Service01.class);
        System.out.println(service01.name());

        DriverManagerDataSource driverManagerDataSource = new DriverManagerDataSource();
//        driverManagerDataSource.setUrl("jdbc:postgresql://192.168.180.129:5432/mydb");
//        driverManagerDataSource.setUsername("myuser");
//        driverManagerDataSource.setPassword("mypass");
//        driverManagerDataSource.setDriverClassName("org.postgresql.Driver");

        driverManagerDataSource.setUrl("jdbc:mysql://192.168.180.129:3306/mydb");
        driverManagerDataSource.setUsername("root");
        driverManagerDataSource.setPassword("111111");
        driverManagerDataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");

        JdbcTemplate jdbcTemplate = new JdbcTemplate(driverManagerDataSource);

//        List<Map<String, Object>> mapList = jdbcTemplate.queryForList("select * from pg_class;");

        List<Integer> data = new ArrayList<>();
        for (int i = 0; i < 10000000; i++) {
            data.add(i);
        }

        jdbcTemplate.batchUpdate("insert into tbl02 values(?,?)", data, 200,
                (PreparedStatement ps, Integer data_one) -> {
                    ps.setInt(1, data_one);
                    ps.setString(2, String.valueOf(data_one));
                });


        System.out.println("done");
    }
}
