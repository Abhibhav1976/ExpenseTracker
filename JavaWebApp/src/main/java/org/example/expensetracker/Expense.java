package org.example.expensetracker;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Expense {
    private int expense_id;
    private int userId;
    private String title;
    private BigDecimal amount;
    private String category;
    private LocalDate date;

    public int getId() {
        return expense_id;
    }
    public void setId(int id) {
        this.expense_id = id;
    }
    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
    }
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    public String getCategory() {
        return category;
    }
    public void setCategory(String category) {
        this.category = category;
    }
    public LocalDate getDate() {
        return date;
    }
    public void setDate(LocalDate date) {
        this.date = date;
    }

}
