package org.example.expensetracker;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/allowance")
public class AllowanceServlet extends HttpServlet {
    private AllowanceDAO allowanceDAO;
    private ExpenseDAO expenseDAO;

    @Override
    public void init() throws ServletException {
        String jdbcURL = "jdbc:mysql://localhost:3306/expensetracker";
        String user = "root";
        String password = "aryan1976";

        try {
            Connection connection = DriverManager.getConnection(jdbcURL, user, password);
            allowanceDAO = new AllowanceDAO(connection);
            expenseDAO = new ExpenseDAO(connection);
            System.out.println("AllowanceDAO initialized successfully.");
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to database", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        user currentUser = (user) req.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            // Handle session expiration or redirect to login
            resp.sendRedirect("login.jsp");
            return;
        }

        try {
            Allowance allowance = allowanceDAO.getAllowanceForUser(currentUser.getId());
            List<Expense> expenses = expenseDAO.getExpensesForUser(currentUser.getId());

            BigDecimal totalExpenses = expenses.stream()
                    .map(Expense::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal remainingAllowance = allowance.getMonthlyAllowance().subtract(totalExpenses);

            req.setAttribute("remainingAllowance", remainingAllowance);
            req.setAttribute("allowance", allowance);
            req.setAttribute("expenses", expenses);

            req.getRequestDispatcher("dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /*@Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        user currentUser = (user) req.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            // Handle session expiration or redirect to login
            resp.sendRedirect("login.jsp");
            return;
        }

        BigDecimal newAllowance = new BigDecimal(req.getParameter("newAllowance"));

        try {
            // Update the user's monthly allowance
            allowanceDAO.updateMonthlyAllowance(currentUser.getId(), newAllowance);

            // After updating, redirect the user to LoginServlet to refresh the data
            resp.sendRedirect("login"); // Ensure this matches your LoginServlet URL pattern
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        user currentUser = (user) req.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            // Handle session expiration or redirect to login
            resp.sendRedirect("login.jsp");
            return;
        }

        BigDecimal newAllowance = new BigDecimal(req.getParameter("newAllowance"));

        try {
            // Update the monthly allowance in the database
            allowanceDAO.updateMonthlyAllowance(currentUser.getId(), newAllowance);

            // Fetch the updated allowance for the user
            Allowance updatedAllowance = allowanceDAO.getAllowanceForUser(currentUser.getId());

            // Fetch the user's expenses
            List<Expense> expenses = expenseDAO.getExpensesForUser(currentUser.getId());

            // Calculate total expenses
            BigDecimal totalExpenses = expenses.stream()
                    .map(Expense::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Calculate the remaining allowance
            BigDecimal remainingAllowance = updatedAllowance.getMonthlyAllowance().subtract(totalExpenses);

            // Update the session attributes with the new values
            req.getSession().setAttribute("allowance", updatedAllowance);
            req.getSession().setAttribute("expenses", expenses);
            req.getSession().setAttribute("totalExpenses", totalExpenses);
            req.getSession().setAttribute("remainingAllowance", remainingAllowance);

            // Redirect back to the login servlet to refresh the dashboard
            resp.sendRedirect(req.getContextPath() + "/login");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

}
