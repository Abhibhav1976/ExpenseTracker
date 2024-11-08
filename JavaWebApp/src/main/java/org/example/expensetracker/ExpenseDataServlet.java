package org.example.expensetracker;

import com.google.gson.Gson;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.expensetracker.userDAO;
import org.example.expensetracker.user;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/expenseData")
public class ExpenseDataServlet extends HttpServlet {
    private ExpenseDAO expenseDAO;

    @Override
    public void init() {
        String jdbcURL = "jdbc:mysql://localhost:3306/expensetracker";
        String user = "root";
        String password = "aryan1976";

        try {
            Connection connection = DriverManager.getConnection(jdbcURL, user, password);
            expenseDAO = new ExpenseDAO(connection);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        // Fetch expense data for the current user
        user currentUser = (user) req.getSession().getAttribute("currentUser");
        List<Expense> expenses = null;
        try {
            expenses = expenseDAO.getExpensesForUser(currentUser.getId());
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        // Process expenses to get data for the chart
        Map<String, BigDecimal> expenseData = new HashMap<>();
        for (Expense expense : expenses) {
            expenseData.merge(expense.getCategory(), expense.getAmount(), BigDecimal::add);
        }

        // Convert the map to JSON
        Gson gson = new Gson();
        String json = gson.toJson(expenseData);
        out.print(json);
        out.flush();
    }
}

