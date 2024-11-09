package org.example.expensetracker;

import java.sql.*;

public class userDAO {
    private Connection connection;

    public userDAO(Connection connection) {
        this.connection = connection;
    }

    public user findUser(String username, String password) throws SQLException {
        String query = "SELECT * FROM users WHERE username=? AND password=?";
        try(PreparedStatement statement = connection.prepareStatement(query)){
            statement.setString(1, username);
            statement.setString(2, password);
            ResultSet rs = statement.executeQuery();
            if (rs.next()){
                user user = new user();
                user.setId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                return user;
            }
        }
        return null;
    }
    public boolean createUser(String username, String password, String email) throws SQLException {
        String query = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, username);
            statement.setString(2, password);
            statement.setString(3, email);

            int rowsInserted = statement.executeUpdate();
            return rowsInserted > 0; // Return true if insert was successful
        }
    }
}

