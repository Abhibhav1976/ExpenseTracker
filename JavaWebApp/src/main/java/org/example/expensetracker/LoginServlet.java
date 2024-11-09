package org.example.expensetracker;

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
import java.util.List;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private userDAO userDAO;
    private AllowanceDAO allowanceDAO;
    private ExpenseDAO expenseDAO;

    @Override
    public void init() {
        String jdbcURL = "jdbc:mysql://localhost:3306/expensetracker";
        String user = "root";
        String password = "aryan1976";

        try {
            Connection connection = DriverManager.getConnection(jdbcURL, user, password);
            userDAO = new userDAO(connection);
            allowanceDAO = new AllowanceDAO(connection);
            expenseDAO = new ExpenseDAO(connection);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false); // Get existing session without creating a new one
        if (session == null) {
            // Session is null, respond with a user-friendly alert or redirect to login page
            resp.setContentType("text/html");
            try (PrintWriter out = resp.getWriter()) {
                out.println("<script type=\"text/javascript\">");
                out.println("alert('Session has expired. Please log in again.');");
                out.println("window.location.href = 'login.jsp';"); // Redirect to login page
                out.println("</script>");
            }
            return; // Stop further processing
        }
        if (session != null && session.getAttribute("currentUser") != null) {
            // User is already logged in, recalculate the values

            user currentUser = (user) session.getAttribute("currentUser");

            try {
                // Fetch the user's allowance
                Allowance allowance = allowanceDAO.getAllowanceForUser(currentUser.getId());
                session.setAttribute("allowance", allowance);

                // Fetch expenses for the current user
                List<Expense> expenses = expenseDAO.getExpensesForUser(currentUser.getId());
                session.setAttribute("expenses", expenses);
                //List<Expense> prevExpenses = expenseDAO.getExpensesForUser(currentUser.getId());
                //req.setAttribute("prevExpenses", prevExpenses);

                // Calculate the total expenses
                BigDecimal totalExpenses = expenses.stream()
                        .map(Expense::getAmount)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);
                session.setAttribute("totalExpenses", totalExpenses);

                // Calculate the remaining allowance
                BigDecimal remainingAllowance = allowance.getMonthlyAllowance().subtract(totalExpenses);
                session.setAttribute("remainingAllowance", remainingAllowance);

                // Redirect to the dashboard to display updated values
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        } else {
            // If not logged in, show the login form
            resp.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Check if the request is coming from a mobile app
        boolean isMobileRequest = "true".equals(req.getHeader("X-Mobile-App"));

        if (isMobileRequest) {
            // Mobile app: JSON response
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            try (PrintWriter out = resp.getWriter()) {
                user currentUser = userDAO.findUser(username, password);

                if (currentUser != null) {
                    HttpSession session = req.getSession();
                    session.setAttribute("currentUser", currentUser);

                    Allowance allowance = allowanceDAO.getAllowanceForUser(currentUser.getId());
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
                } else {
                    JSONObject jsonResponse = new JSONObject();
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Invalid username or password");
                    out.print(jsonResponse.toString());
                }
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        } else {
            // Web app: Redirect response
            try {
                user currentUser = userDAO.findUser(username, password);
                if (currentUser != null) {
                    HttpSession session = req.getSession();
                    session.setAttribute("currentUser", currentUser);

                    List<Expense> expenses = expenseDAO.getExpensesForUser(currentUser.getId());
                    session.setAttribute("expenses", expenses);

                    BigDecimal totalExpenses = expenses.stream()
                            .map(Expense::getAmount)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);
                    session.setAttribute("totalExpenses", totalExpenses);

                    // Redirect to dashboard
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                } else {
                    resp.sendRedirect("login.jsp");
                }
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }
    }
}
