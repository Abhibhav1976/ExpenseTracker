package org.example.expensetracker;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private ExpenseDAO expenseDAO;
    private AllowanceDAO allowanceDAO;

    @Override
    public void init() throws ServletException {
        String jdbcURL = "jdbc:mysql://localhost:3306/expensetracker";
        String user = "root";
        String password = "aryan1976";

        try {
            Connection connection = DriverManager.getConnection(jdbcURL, user, password);
            expenseDAO = new ExpenseDAO(connection);
            allowanceDAO = new AllowanceDAO(connection);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to database", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Check if the request is coming from a mobile app
        boolean isMobileRequest = "true".equals(req.getHeader("X-Mobile-App"));

        // Get the current user from session
        HttpSession session = req.getSession(false);
        user currentUser = (user) session.getAttribute("currentUser");
        if (currentUser == null) {
            resp.setContentType("text/html");
            try (PrintWriter out = resp.getWriter()) {
                out.println("<script type=\"text/javascript\">");
                out.println("alert('Session has expired. Please log in again.');");
                out.println("window.location.href = 'login.jsp';");
                out.println("</script>");
            }
            return;
        }
        if (isMobileRequest) {
            // Mobile app: JSON response
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            try (PrintWriter out = resp.getWriter()) {
                // Check if the user is authenticated
                if (currentUser == null) {
                    resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    JSONObject errorResponse = new JSONObject();
                    errorResponse.put("success", false);
                    errorResponse.put("message", "User not authenticated.");
                    out.print(errorResponse.toString());
                    return;
                }

                Allowance allowance = allowanceDAO.getAllowanceForUser(currentUser.getId());
                // Fetch only current expenses
                List<Expense> expenses = expenseDAO.getExpensesForUser(currentUser.getId());

                BigDecimal totalExpenses = expenses.stream()
                        .map(Expense::getAmount)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);
                BigDecimal remainingAllowance = allowance.getMonthlyAllowance().subtract(totalExpenses);

                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("success", true);
                jsonResponse.put("userId", currentUser.getId());
                jsonResponse.put("username", currentUser.getUsername());
                jsonResponse.put("email", currentUser.getEmail());
                jsonResponse.put("allowance", allowance.getMonthlyAllowance());
                jsonResponse.put("totalExpenses", totalExpenses);
                jsonResponse.put("remainingAllowance", remainingAllowance);

                JSONArray expensesArray = new JSONArray();
                for (Expense expense : expenses) {
                    JSONObject expenseJson = new JSONObject();
                    expenseJson.put("id", expense.getId());
                    expenseJson.put("category", expense.getCategory());
                    expenseJson.put("title", expense.getTitle());
                    expenseJson.put("amount", expense.getAmount());
                    expenseJson.put("date", expense.getDate().toString());
                    expensesArray.put(expenseJson);
                }
                jsonResponse.put("expenses", expensesArray);
                out.print(jsonResponse.toString());
            } catch (SQLException e) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                JSONObject errorResponse = new JSONObject();
                errorResponse.put("success", false);
                errorResponse.put("message", "Database error: " + e.getMessage());
                resp.getWriter().print(errorResponse.toString());
            }
        } else {
            // Web app: Render dashboard JSP
            if (session == null || currentUser == null) {
                resp.setContentType("text/html");
                try (PrintWriter out = resp.getWriter()) {
                    out.println("<script type=\"text/javascript\">");
                    out.println("alert('Session has expired. Please log in again.');");
                    out.println("window.location.href = 'login.jsp';");
                    out.println("</script>");
                }
                return;
            }

            try {
                Allowance allowance = allowanceDAO.getAllowanceForUser(currentUser.getId());
                System.out.println("Fetched allowance: " + allowance);  // Debug: Check the fetched allowance

                // Check if the allowance is null
                if (allowance == null || allowance.getRemainingAllowance().compareTo(BigDecimal.ZERO) == 0) {
                    System.out.println("initialAllowance being run");
                    allowanceDAO.initialAllowance(currentUser.getId()); // Initialize allowance if zero
                    allowance = allowanceDAO.getAllowanceForUser(currentUser.getId());
                }

                req.setAttribute("allowance", allowance);

                List<Expense> expenses = expenseDAO.getExpensesForUser(currentUser.getId());
                req.setAttribute("expenses", expenses);

                BigDecimal totalExpenses = expenses.stream()
                        .map(Expense::getAmount)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);
                session.setAttribute("totalExpenses", totalExpenses);

                BigDecimal remainingAllowance = allowance.getMonthlyAllowance().subtract(totalExpenses);
                session.setAttribute("remainingAllowance", remainingAllowance);

                RequestDispatcher dispatcher = req.getRequestDispatcher("dashboard.jsp");
                dispatcher.forward(req, resp);
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        user currentUser = (user) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.setContentType("text/html");
            try (PrintWriter out = resp.getWriter()) {
                out.println("<script type=\"text/javascript\">");
                out.println("alert('Session has expired. Please log in again.');");
                out.println("window.location.href = 'login.jsp';");
                out.println("</script>");
            }
            return;
        }

        try {
            String startDateParam = req.getParameter("startDate");
            String endDateParam = req.getParameter("endDate");
            List<Expense> prevExpenses;

            // Print received date parameters
            System.out.println("Start date parameter: " + startDateParam);
            System.out.println("End date parameter: " + endDateParam);

            if (startDateParam != null && !startDateParam.isEmpty() && endDateParam != null && !endDateParam.isEmpty()) {
                LocalDate startDate = LocalDate.parse(startDateParam);
                LocalDate endDate = LocalDate.parse(endDateParam);

                // Print parsed dates
                System.out.println("Parsed start date: " + startDate);
                System.out.println("Parsed end date: " + endDate);

                // Fetch previous expenses within the date range
                prevExpenses = expenseDAO.getPrevExpensesForUser(currentUser.getId(), startDate, endDate);

                // Print the number of expenses retrieved
                System.out.println("Number of previous expenses found: " + prevExpenses.size());

                // Print each expense detail
                for (Expense expense : prevExpenses) {
                    System.out.println("Expense ID: " + expense.getId() + ", Title: " + expense.getTitle() + ", Amount: " + expense.getAmount() + ", Date: " + expense.getDate());
                }
            } else {
                // No dates provided, fetch all previous expenses
                prevExpenses = expenseDAO.getPrevExpensesForUser(currentUser.getId(), null, null);

                // Print the number of expenses retrieved
                System.out.println("Number of all previous expenses found: " + prevExpenses.size());
            }

            req.setAttribute("previousExpenses", prevExpenses);

            // Redirect back to the dashboard.jsp to display the previous expenses
            RequestDispatcher dispatcher = req.getRequestDispatcher("dashboard.jsp");
            dispatcher.forward(req, resp);
        } catch (DateTimeParseException e) {
            req.setAttribute("errorMessage", "Invalid date format. Please use YYYY-MM-DD.");
            RequestDispatcher dispatcher = req.getRequestDispatcher("dashboard.jsp");
            dispatcher.forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }
}
