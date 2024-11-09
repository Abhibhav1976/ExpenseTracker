<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.example.expensetracker.Allowance" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="org.example.expensetracker.Allowance" %>
<%@ page import="java.util.List" %>
<%@ page import="org.example.expensetracker.Expense" %>
<%@ page import="org.example.expensetracker.user" %>
<%@ page import="org.example.expensetracker.ExpenseDAO" %>
<%@ page import="java.time.LocalDate" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html>
<head>
    <meta charset="UTF-8">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"></link>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #111827;
            color: #f5f5f7;
            display: flex;
            flex-direction: column; /* Stack content vertically on mobile */
        }

        .sidebar {
            width: 200px;
            background-color: #5a00e0;
            color: white;
            padding: 20px;
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            transition: transform 0.3s ease;
        }
        .toggle-btn {
            display: none; /* Hidden by default on desktop */
            position: fixed;
            top: 10px;
            left: 10px;
            z-index: 1000;
            background-color: black;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 20px;
        }
        .sidebar.hidden {
            transform: translateX(-100%);
        }

        .sidebar h1 {
            font-size: 24px;
            margin-bottom: 40px;
            text-align: center;
        }

        .sidebar ul {
            list-style: none;
            padding: 0;
        }

        .sidebar ul li {
            margin: 20px 0;
            display: flex;
            align-items: center;
            font-size: 18px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .sidebar ul li:hover {
            background-color: #4000b7;
            border-radius: 5px;
        }

        .sidebar ul li.active {
            background-color: #4000b7;
        }

        .content {

            padding: 20px;
            flex: 1;
            transition: margin-left 0.3s ease;
        }

        .content.shifted {
            margin-left: 0;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h2 {
            font-size: 24px;
            font-weight: 700;
        }

        .header .user-info {
            display: flex;
            align-items: center;
        }

        .header .user-info img {
            border-radius: 50%;
            width: 40px;
            height: 40px;
            margin-left: 10px;
        }

        .cards {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }

        .card {
            background-color: #1F2937;
            border-radius: 10px;
            padding: 20px;
            width: 30%;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .card h3 {
            font-size: 18px;
            margin-bottom: 10px;
        }

        .card .amount {
            font-size: 36px;
            font-weight: 700;
        }

        .card .percentage {
            color: green;
            font-size: 14px;
        }

        .card .percentage.red {
            color: red;
        }

        .transactions {
            margin-top: 20px;
            display: flex;
            justify-content: space-between;
            gap: 30px;
        }

        .transactions .left, .transactions .right {
            background-color: #374151;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        .transactions .left {
            flex: 2;
            padding-right: 40px;
        }

        .transactions .right {
            flex: 1;
            padding-left: 40px;
        }

        .transactions h3 {
            font-size: 18px;
            margin-bottom: 20px;
        }

        .transactions .chart {
            height: 300px;
        }

        .transactions .table {
            width: 100%;
            border-collapse: collapse;
        }

        .transactions .table th, .transactions .table td {
            padding: 10px;
            text-align: left;
        }

        .transactions .table th {
            background-color: #1F2937;
        }

        .transactions .table tr:nth-child(even) {
            background-color: rgba(0, 0, 0, 0.5);
        }

        .transactions .table .status {
            color: green;
        }

        .transactions .table .status.failed {
            color: red;
        }

        .amount-transfer {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }

        .amount-transfer .circle {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background-color: #e0e0e0;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 24px;
            font-weight: 700;
        }

        .amount-transfer .circle + .circle {
            margin-left: 20px;
        }

        @media (max-width: 768px) {
            .toggle-btn {
                display: block; /* Show on mobile */
            }
            .sidebar {
                width: 100%;
                height: auto;
                padding: 10px;
                position: fixed;
                top: 0;
                left: 0;
                transform: translateX(-100%);
                z-index: 999;
            }
            .sidebar.active {
                transform: translateX(0);
            }

            .content {
                margin-left: 0;
                padding: 60px;
            }

            .header {
                flex-direction: column;
                align-items: flex-start;
            }

            .cards {
                flex-direction: column;
                align-items: stretch;
            }

            .card {
                width: 100%;
                margin-bottom: 20px;
            }

            .transactions {
                flex-direction: column;
            }

            .transactions .left, .transactions .right {
                width: 100%;
                margin-right: 0;
            }

            .amount-transfer {
                flex-direction: column;
            }

            .amount-transfer .circle {
                margin-bottom: 20px;
            }
        }

        @media (max-width: 480px) {
            .sidebar h1 {
                font-size: 20px;
            }

            .header h2 {
                font-size: 18px;
            }

            .card h3 {
                font-size: 16px;
            }

            .card .amount {
                font-size: 24px;
            }

            .card .percentage {
                font-size: 12px;
            }

            .transactions .table th, .transactions .table td {
                font-size: 12px;
            }

            .amount-transfer .circle {
                width: 80px;
                height: 80px;
                font-size: 20px;
            }
        }
        .navbar {
            background-color: #000;
            color: #fff;
            padding: 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: background-color 0.3s ease;
        }
        .navbar a {
            color: #fff;
            text-decoration: none;
            margin: 0 1rem;
            transition: color 0.3s ease;
        }
        .navbar a:hover {
            color: #0071e3;
        }
    </style>


</head>
<body>
<%
    user currentUser = (user) session.getAttribute("currentUser");
    //Allowance allowance = (Allowance) session.getAttribute("allowance");
    //BigDecimal totalAllowance = allowance.getMonthlyAllowance();
    //List<Expense> expenses = (List<Expense>) request.getAttribute("expenses");
    ExpenseDAO expenseDAO;
%>
<header class="flex justify-between items-center p-6">
    <div class="text-2xl font-bold">Expense Tracker</div>
    <nav class="space-x-4 hidden md:flex">
        <a href="index.jsp" methods="get" class="hover:text-gray-400">Home</a>
        <a href="#" class="hover:text-gray-400">Features</a>
        <a href="#" class="hover:text-gray-400">Pricing</a>
        <a href="#" class="hover:text-gray-400">Contact</a>
    </nav>
    <div class="md:hidden">
        <button id="menu-button" class="text-white focus:outline-none">
            <i class="fas fa-bars text-2xl"></i>
        </button>
    </div>
</header>

    <div id="mobile-menu" class="hidden md:hidden">
        <nav class="flex flex-col items-center space-y-4">
            <a href="#" class="hover:text-gray-400">Home</a>
            <a href="#" class="hover:text-gray-400">Features</a>
            <a href="#" class="hover:text-gray-400">Pricing</a>
            <a href="#" class="hover:text-gray-400">Contact</a>
        </nav>
    </div>
<%-- dashboard.jsp --%>
<div class="content">
    <div class="header">
<h2>Welcome, <%= currentUser.getUsername() %></h2>
    </div>
    <%
        Allowance allowance = (Allowance) request.getAttribute("allowance");
        BigDecimal totalAllowance = (allowance != null) ? allowance.getMonthlyAllowance() : null;
        BigDecimal totalExpenses = (BigDecimal) request.getAttribute("totalExpenses");
        BigDecimal remainingAllowance = (BigDecimal) request.getAttribute("remainingAllowance");
    %>
    <div class="cards">
        <div class="card">
            <h3>Monthly Allowance</h3>
            <div class="amount">
                <p>
                    <%= totalAllowance != null ? "$" + totalAllowance : "Not Set" %>
                </p>
            </div>
        </div>
        <div class="card">
            <h3>Total Expenses</h3>
            <div class="amount">
                <p>
                    <fmt:formatNumber value="${totalExpenses}" type="currency" currencySymbol="$" />
                </p> <!-- Make sure you define totalExpenses properly -->
            </div>
        </div>
        <div class="card">
            <h3>Remaining Allowance</h3>
            <div class="amount">
                <p>
                    <fmt:formatNumber value="${allowance.monthlyAllowance - totalExpenses}" type="currency" currencySymbol="$" />
                </p>
                </p>
            </div>
        </div>
    </div>
    <div class="transactions">
        <div class="right">
            <div class="table">
                <%
                    String view = request.getParameter("view");
                    String startDate = request.getParameter("startDate");
                    String endDate = request.getParameter("endDate");

                    if ("previous".equals(view)) {
                        // Display previous expenses filtered by date range
                        List<Expense> prevExpenses = (List<Expense>) request.getAttribute("previousExpenses");
                %>
                <h2>Your Previous Expenses</h2>
                <%
                    if (prevExpenses != null && !prevExpenses.isEmpty()) {
                %>
                <table>
                    <thead>
                    <tr>
                        <th>Title</th>
                        <th>Category</th>
                        <th>Amount</th>
                        <th>Date</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Expense expense : prevExpenses) { %>
                    <tr>
                        <td><%= expense.getTitle() %></td>
                        <td><%= expense.getCategory() %></td>
                        <td><%= expense.getAmount() %></td>
                        <td><%= expense.getDate() %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <%
                } else {
                %>
                <p>No previous expenses found for the selected dates.</p>
                <%
                    }
                %>
                <%
                } else {
                    // Display current expenses by default
                    List<Expense> expenses = (List<Expense>) request.getAttribute("expenses");
                %>
                <h2>Your Expenses</h2>
                <%
                    if (expenses != null && !expenses.isEmpty()) {
                %>
                <table>
                    <thead>
                    <tr>
                        <th>Title</th>
                        <th>Category</th>
                        <th>Amount</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Expense expense : expenses) { %>
                    <tr>
                        <td><%= expense.getTitle() %></td>
                        <td><%= expense.getCategory() %></td>
                        <td><%= expense.getAmount() %></td>
                        <td><%= expense.getDate() %></td>
                        <td>
                            <form action="${pageContext.request.contextPath}/expenses" method="post">
                                <input type="hidden" name="expenseId" value="<%= expense.getId() %>">
                                <input type="hidden" name="action" value="delete">
                                <button type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <%
                } else {
                %>
                <p>No expenses to display.</p>
                <%
                    }
                %>
                <%
                    }
                %>
                <!-- Date selection form at the end of the table -->
                <form action="dashboard" method="POST" class="mb-4">
                    <div class="mb-4">
                        <label for="startDate" class="block text-lg font-bold mb-2">Start Date</label>
                        <input type="date" name="startDate" id="startDate"
                               class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                               required>
                    </div>

                    <div class="mb-4">
                        <label for="endDate" class="block text-lg font-bold mb-2">End Date</label>
                        <input type="date" name="endDate" id="endDate"
                               class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                               required>
                    </div>

                    <button type="submit" name="view" value="previous"
                            class="bg-blue-500 text-white px-4 py-2 rounded-md text-sm hover:bg-blue-600 transition duration-300">
                        Get Previous Expenses
                    </button>
                </form>
            </div>
        </div>
    <div class="left">
            <h3>
                Expense Chart
            </h3>
            <div class="chart">
        <canvas id="expenseChart" width="600" height="300"></canvas>
             </div>
        </div>
    </div>


<script>
    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        const content = document.querySelector('.content');

        sidebar.classList.toggle('active');

        // Optional: prevent body scrolling when sidebar is open
        if (sidebar.classList.contains('active')) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = 'auto';
        }
    }

    // Optional: Close sidebar when clicking outside
    document.addEventListener('click', function(event) {
        const sidebar = document.getElementById('sidebar');
        const toggleBtn = document.querySelector('.toggle-btn');

        if (!sidebar.contains(event.target) &&
            !toggleBtn.contains(event.target) &&
            sidebar.classList.contains('active')) {
            toggleSidebar();
        }
    });
    // Fetch expense data
    fetch('expenseData')
        .then(response => response.json())
        .then(data => {
            const labels = Object.keys(data);
            const values = Object.values(data);
            const totalAllowance = <%= totalAllowance %>; // Pass allowance from JSP to JS

            const ctx = document.getElementById('expenseChart').getContext('2d');
            const myChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Expenses by Category',
                        data: values,
                        backgroundColor: 'rgba(0, 224, 224, 0.6)',
                        borderColor: 'rgba(0, 224, 224, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Amount'
                            }
                        }
                    },
                    plugins: {
                        annotation: {
                            annotations: {
                                line1: {
                                    type: 'line',
                                    yMin: totalAllowance,
                                    yMax: totalAllowance,
                                    borderColor: 'red',
                                    borderWidth: 2,
                                    label: {
                                        content: 'Total Allowance',
                                        enabled: true,
                                        position: 'end'
                                    }
                                }
                            }
                        }
                    }
                }
            });
        });
</script>

<div class = "container">
    <form action="allowance" method="post" class="mb-4">
        <div class="mb-4">
            <label for="newAllowance" class="block text-lg font-bold mb-2">New Monthly Allowance</label>
            <input type="text" name="newAllowance" id="newAllowance"
                   class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                   required placeholder="Enter new allowance">
        </div>
        <input type="submit" value="Update">
    </form>
    <a href="${pageContext.request.contextPath}/addExpense.jsp"
       class="w-full bg-blue-500 text-white px-6 py-3 rounded-full text-lg hover:bg-blue-600 transition duration-300 text-center block">
        Add New Expense
    </a>
</div>
</div>
</body>
</html>
