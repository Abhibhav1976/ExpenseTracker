package org.example.expensetracker;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.expensetracker.userDAO;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@WebServlet("/signup")
public class UserSignUp extends HttpServlet {
    private userDAO userDAO;

    @Override
    public void init() {
        String jdbcURL = "jdbc:mysql://localhost:3306/expensetracker";
        String user = "root";
        String password = "aryan1976";

        try {
            Connection connection = DriverManager.getConnection(jdbcURL, user, password);
            userDAO = new userDAO(connection);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            boolean isUserCreated = userDAO.createUser(username, password, email);
            if (isUserCreated) {
                // Redirect to setAllowance.jsp with the username
                response.sendRedirect(request.getContextPath() + "/setAllowance.jsp?username=" + username);
            } else {
                response.sendRedirect("signup.jsp?error=Username or Email already exists.");
            }
        } catch (SQLException e) {
            throw new ServletException("Error creating user", e);
        }
    }
}