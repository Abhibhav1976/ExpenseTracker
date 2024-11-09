package org.example.expensetracker;

import java.math.BigDecimal;

public class user {
    private Integer id;
    private String username;
    private String password;
    private String email;
    private BigDecimal allowance;

    public Integer getId() {
        return id;  // Return Integer to handle null values
    }

    public void setId(Integer id) {
        this.id = id;  // Set the Integer value, which can be null
    }
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public BigDecimal getAllowance() {
        return allowance;
    }

    public void setAllowance(BigDecimal allowance) {
        this.allowance = allowance;
    }
}

