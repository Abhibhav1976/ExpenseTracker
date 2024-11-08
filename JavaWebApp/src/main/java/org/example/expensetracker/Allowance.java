package org.example.expensetracker;

import java.math.BigDecimal;

public class Allowance {
    private int userId;
    private BigDecimal monthlyAllowance;
    private BigDecimal remainingAllowance;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public BigDecimal getMonthlyAllowance() {
        return monthlyAllowance;
    }

    public void setMonthlyAllowance(BigDecimal monthlyAllowance) {
        this.monthlyAllowance = monthlyAllowance;
    }

    public BigDecimal getRemainingAllowance() {
        return remainingAllowance;
    }

    public void setRemainingAllowance(BigDecimal remainingAllowance) {
        this.remainingAllowance = remainingAllowance;
    }
}
