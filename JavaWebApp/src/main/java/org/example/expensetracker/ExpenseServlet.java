package org.example.expensetracker;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.expensetracker.userDAO;
import org.example.expensetracker.user;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static java.lang.System.out;

@WebServlet("/expenses")
public class ExpenseServlet extends HttpServlet {
    private ExpenseDAO expenseDAO;

    @Override
    public void init() throws ServletException {
        String jdbcURL = "jdbc:mysql://localhost:3306/expensetracker";
        String user = "root";
        String password = "aryan1976";

        try {
            Connection connection = DriverManager.getConnection(jdbcURL, user, password);
            expenseDAO = new ExpenseDAO(connection);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to database", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String webAction = req.getParameter("action");
        String mobileAction = req.getParameter("mobileAction");
        boolean isMobileRequest = "true".equals(req.getHeader("X-Mobile-App"));
        resp.setCharacterEncoding("UTF-8");
        user currentUser = (user) req.getSession().getAttribute("currentUser");
        // String action = req.getParameter("action");
        String startDateParam = req.getParameter("startDate"); // New parameter for start date
        String endDateParam = req.getParameter("endDate");

        if ("delete".equals(webAction)) {
            String expenseIdStr = req.getParameter("expenseId");
            out.println("Expense ID passed: " + expenseIdStr);

            if (expenseIdStr != null && !expenseIdStr.isEmpty()) {
                try {
                    int expenseId = Integer.parseInt(expenseIdStr);
                    expenseDAO.deleteExpense(expenseId);
                    resp.sendRedirect(req.getContextPath() + "/login");
                } catch (SQLException e) {
                    throw new RuntimeException(e);
                }
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid expense ID");
            }
            return;
        }

        if (isMobileRequest) {
            resp.setContentType("application/json");
            List<Expense> expensesList;
            int id = ((user) req.getSession().getAttribute("currentUser")).getId();

            if ("getPreviousExpenses".equals(mobileAction)){
                List<Expense> prevExpenses = new ArrayList<>();
                if (startDateParam != null && endDateParam != null) {
                    LocalDate startDate = LocalDate.parse(startDateParam);
                    LocalDate endDate = LocalDate.parse(endDateParam);
                    try {
                        prevExpenses = expenseDAO.getPrevExpensesForUser(id, startDate, endDate);
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                }

                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("success", true);
                jsonResponse.put("id", id);
                jsonResponse.put("username", currentUser.getUsername());

                JSONArray prevExpensesArray = new JSONArray();
                for (Expense expense : prevExpenses) {
                    JSONObject prevExpenseJson = new JSONObject();
                    prevExpenseJson.put("id", expense.getId());
                    prevExpenseJson.put("category", expense.getCategory());
                    prevExpenseJson.put("title", expense.getTitle());
                    prevExpenseJson.put("amount", expense.getAmount());
                    prevExpenseJson.put("date", expense.getDate().toString());
                    prevExpensesArray.put(prevExpenseJson);
                }
                jsonResponse.put("previousExpenses", prevExpensesArray);
                out.print(jsonResponse.toString());
            } else {
                try {
                    expensesList = expenseDAO.getExpensesForUser(id);

                    JSONArray expensesJsonArray = new JSONArray();
                    for (Expense expense : expensesList) {
                        JSONArray expenseArray = new JSONArray();
                        expenseArray.put(expense.getId());
                        expenseArray.put(expense.getCategory());
                        expenseArray.put(expense.getTitle());
                        expenseArray.put(expense.getAmount().toString());
                        expenseArray.put(expense.getDate().toString());
                        expensesJsonArray.put(expenseArray);
                    }

                    JSONObject responseJson = new JSONObject();
                    responseJson.put("expenses", expensesJsonArray);
                    responseJson.put("success", true);

                    PrintWriter out = resp.getWriter();
                    out.print(responseJson);
                    out.flush();
                } catch (SQLException e) {
                    resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to retrieve expenses");
                }
            }

            if ("deleteExpense".equals(mobileAction)) {
                String expenseIdStr = req.getParameter("expenseId");
                if (expenseIdStr != null && !expenseIdStr.isEmpty()) {
                    try {
                        int expenseId = Integer.parseInt(expenseIdStr);
                        expenseDAO.deleteExpense(expenseId);

                        JSONObject responseJson = new JSONObject();
                        responseJson.put("success", true);
                        responseJson.put("message", "Expense deleted successfully.");
                        resp.setContentType("application/json");
                        PrintWriter out = resp.getWriter();
                        out.print(responseJson);
                        out.flush();
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                } else {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid expense ID");
                }
            } else if ("addExpense".equals(mobileAction)) {
                String category = req.getParameter("category");
                String title = req.getParameter("title");
                BigDecimal amount = new BigDecimal(req.getParameter("amount"));
                LocalDate date = LocalDate.parse(req.getParameter("date"));

                Expense expense = new Expense();
                expense.setUserId(id);
                expense.setCategory(category);
                expense.setTitle(title);
                expense.setAmount(amount);
                expense.setDate(date);


                try {
                    List<Expense> updatedExpenses = expenseDAO.getExpensesForUser(id);
                    expenseDAO.addExpense(expense);
                    JSONObject responseJson = new JSONObject();
                    responseJson.put("success", true);
                    responseJson.put("message", "Expense added successfully.");

                    // Add the updated expenses to the response
                    JSONArray expensesArray = new JSONArray();
                    for (Expense e : updatedExpenses) {
                        JSONArray expenseData = new JSONArray();
                        //expenseData.put(e.getExpenseId());
                        expenseData.put(e.getCategory());
                        expenseData.put(e.getTitle());
                        expenseData.put(e.getAmount().toString());
                        expenseData.put(e.getDate().toString());
                        expensesArray.put(expenseData);
                    }

                    responseJson.put("expenses", expensesArray);

                    resp.setContentType("application/json");
                    PrintWriter out = resp.getWriter();
                    out.print(responseJson);
                    out.flush();
                } catch (SQLException e) {
                    throw new ServletException(e);
                }
            }
        } else {
            String category = req.getParameter("category");
            String title = req.getParameter("title");
            BigDecimal amount = new BigDecimal(req.getParameter("amount"));
            LocalDate date = LocalDate.parse(req.getParameter("date"));
            int id = ((user) req.getSession().getAttribute("currentUser")).getId();

            Expense expense = new Expense();
            expense.setUserId(id);
            expense.setCategory(category);
            expense.setTitle(title);
            expense.setAmount(amount);
            expense.setDate(date);

            try {
                expenseDAO.addExpense(expense);
                resp.sendRedirect(req.getContextPath() + "/login");
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        String action = req.getParameter("action");
        String startDateParam = req.getParameter("startDate"); // New parameter for start date
        String endDateParam = req.getParameter("endDate");
        boolean isMobileRequest = "true".equals(req.getHeader("X-Mobile-App"));

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");


        try (PrintWriter out = resp.getWriter()) {
            if (idParam == null) {
                sendErrorResponse(out, "ID is required");
                return;
            }

            int id = Integer.parseInt(idParam);
            System.out.println(id);

            user currentUser = (user) req.getSession().getAttribute("currentUser");

            if (currentUser == null) {
                sendErrorResponse(out, "User not found");
                return;
            }
            if ("getPreviousExpenses".equals(action)){
                List<Expense> prevExpenses = new ArrayList<>();
                if (startDateParam != null && endDateParam != null) {
                    LocalDate startDate = LocalDate.parse(startDateParam);
                    LocalDate endDate = LocalDate.parse(endDateParam);
                    prevExpenses = expenseDAO.getPrevExpensesForUser(id, startDate, endDate);
                }

                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("success", true);
                jsonResponse.put("id", id);
                jsonResponse.put("username", currentUser.getUsername());

                JSONArray prevExpensesArray = new JSONArray();
                for (Expense expense : prevExpenses) {
                    JSONObject prevExpenseJson = new JSONObject();
                    prevExpenseJson.put("id", expense.getId());
                    prevExpenseJson.put("category", expense.getCategory());
                    prevExpenseJson.put("title", expense.getTitle());
                    prevExpenseJson.put("amount", expense.getAmount());
                    prevExpenseJson.put("date", expense.getDate().toString());
                    prevExpensesArray.put(prevExpenseJson);
                }
                jsonResponse.put("previousExpenses", prevExpensesArray);
                out.print(jsonResponse.toString());
            } else if("getCurrentExpenses".equals(action)){
                List<Expense> expenses = expenseDAO.getExpensesForUser(id);


                BigDecimal totalExpenses = calculateTotalExpenses(expenses);
                BigDecimal allowance = currentUser.getAllowance();
                BigDecimal remainingAllowance = allowance.subtract(totalExpenses);

                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("success", true);
                jsonResponse.put("id", id);
                jsonResponse.put("username", currentUser.getUsername());
                jsonResponse.put("allowance", allowance);
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
            }
        } catch (NumberFormatException e) {
            sendErrorResponse(resp.getWriter(), "Invalid ID format");
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(resp.getWriter(), "Database error: " + e.getMessage());
        }
    }

    private void sendErrorResponse(PrintWriter out, String message) {
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("success", false);
        errorResponse.put("message", message);
        out.print(errorResponse.toString());
    }

    private BigDecimal calculateTotalExpenses(List<Expense> expenses) {
        return expenses.stream()
                .map(Expense::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
