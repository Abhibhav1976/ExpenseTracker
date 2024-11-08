package org.example.expensetracker;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ExpenseDAO {
    private Connection connection;

    public ExpenseDAO(Connection connection) {
        this.connection = connection;
    }

    public void addExpense(Expense expense) throws SQLException {
        String query = "INSERT INTO expenses (user_id, amount, category, date, title) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, expense.getUserId());
            statement.setBigDecimal(2, expense.getAmount());
            statement.setString(3, expense.getCategory());
            statement.setDate(4, Date.valueOf(expense.getDate()));
            statement.setString(5, expense.getTitle());
            statement.executeUpdate(); // Make sure to execute the statement
        }
    }


    public List<Expense> getExpensesForUser(int userId) throws SQLException{
        String query = "SELECT * FROM expenses WHERE user_id = ? AND is_current = TRUE";
        List<Expense> expenses = new ArrayList<>();
        try(PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            ResultSet rs = statement.executeQuery();
            while(rs.next()) {
                Expense expense = new Expense();
                expense.setId(rs.getInt("expense_id"));
                expense.setUserId(rs.getInt("user_id"));
                expense.setTitle(rs.getString("title"));
                expense.setAmount(rs.getBigDecimal("amount"));
                expense.setCategory(rs.getString("category"));
                expense.setDate(rs.getDate("date").toLocalDate());
                expenses.add(expense);

                //System.out.println("Fetched Expense - ID: " + expense.getId() + ", Amount: " + expense.getAmount() +
                //        ", Category: " + expense.getCategory() + ", Date: " + expense.getDate());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }

        return expenses;
    }
    public List<Expense> getPrevExpensesForUser(int userId, LocalDate startDate, LocalDate endDate) throws SQLException {
        String query;
        boolean hasDateRange = startDate != null && endDate != null;
        if (hasDateRange) {
            query = "SELECT * FROM expenses WHERE user_id = ? AND is_current = FALSE AND date BETWEEN ? AND ?";
        } else {
            query = "SELECT * FROM expenses WHERE user_id = ? AND is_current = FALSE";
        }
        List<Expense> expenses = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            statement.setDate(2, Date.valueOf(startDate));
            statement.setDate(3, Date.valueOf(endDate));
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                Expense expense = new Expense();
                expense.setId(rs.getInt("expense_id"));
                expense.setUserId(rs.getInt("user_id"));
                expense.setTitle(rs.getString("title"));
                expense.setAmount(rs.getBigDecimal("amount"));
                expense.setCategory(rs.getString("category"));
                expense.setDate(rs.getDate("date").toLocalDate());
                expenses.add(expense);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return expenses;
    }
    public void deleteExpense(int expenseId) throws SQLException {
        String query = "DELETE FROM expenses WHERE expense_id=?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, expenseId);
            statement.executeUpdate();
        }
    }
}
