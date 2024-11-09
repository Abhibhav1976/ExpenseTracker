package org.example.expensetracker;

import java.sql.*;
import java.math.BigDecimal;

public class AllowanceDAO {
    private Connection connection;

    public AllowanceDAO(Connection connection) {
        this.connection = connection;
    }

    // Retrieve allowance for a specific user
    public Allowance getAllowanceForUser(int userId) throws SQLException {
        String query = "SELECT * FROM allowances WHERE user_id = ?";
        Allowance allowance = null;

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            ResultSet rs = statement.executeQuery();

            if (rs.next()) {
                allowance = new Allowance();
                allowance.setUserId(rs.getInt("user_id"));
                allowance.setMonthlyAllowance(rs.getBigDecimal("monthly_allowance"));
                BigDecimal remainingAllowance = rs.getBigDecimal("remaining_allowance");
                allowance.setRemainingAllowance(remainingAllowance);
            } else {
                // If no allowance exists for the user, create a new one with a default value (e.g., 0)
                allowance = new Allowance();
                allowance.setUserId(userId);
                allowance.setMonthlyAllowance(BigDecimal.ZERO); // Default value
                allowance.setRemainingAllowance(BigDecimal.ZERO); // Default value
            }
        }
        if (allowance == null) {
            System.out.println("No allowance found for user ID " + userId);  // Debug: Check if allowance is missing
        }

        return allowance;
    }

    // Add a new allowance for a user (use when creating a new account)
    public void addAllowanceForUser(int userId, BigDecimal monthlyAllowance) throws SQLException {
        String query = "INSERT INTO allowances (user_id, monthly_allowance, remaining_allowance) VALUES (?, ?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            statement.setBigDecimal(2, monthlyAllowance);
            statement.setBigDecimal(3, monthlyAllowance); // Initially, remaining = monthly allowance
            statement.executeUpdate();
        }
    }

    // Update monthly allowance for a user
    public void updateMonthlyAllowance(int userId, BigDecimal newMonthlyAllowance) throws SQLException {
        String query = "UPDATE allowances SET monthly_allowance = ?, remaining_allowance = ? WHERE user_id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setBigDecimal(1, newMonthlyAllowance);
            statement.setBigDecimal(2, newMonthlyAllowance); // Reset remaining allowance
            statement.setInt(3, userId);
            statement.executeUpdate();
        }
    }
    public void initialAllowance(int userId) throws SQLException {
        String query = "INSERT INTO allowances (user_id, monthly_allowance, remaining_allowance) VALUES (?, ?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            BigDecimal defaultAllowance = new BigDecimal("5000.00"); // Default value for both monthly and remaining allowance
            statement.setInt(1, userId);
            statement.setBigDecimal(2, defaultAllowance);
            statement.setBigDecimal(3, defaultAllowance); // Initialize remaining allowance with the same value
            statement.executeUpdate();
        }
    }

    // Deduct an amount from the remaining allowance (when adding expenses)
    public void deductFromAllowance(int userId, BigDecimal amount) throws SQLException {
        String query = "UPDATE allowances SET remaining_allowance = remaining_allowance - ? WHERE user_id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setBigDecimal(1, amount);
            statement.setInt(2, userId);
            statement.executeUpdate();
        }
    }

    // Reset remaining allowance at the start of a new month
    public void resetAllowance(int userId) throws SQLException {
        String query = "UPDATE allowances SET remaining_allowance = monthly_allowance WHERE user_id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            statement.executeUpdate();
        }
    }
}
