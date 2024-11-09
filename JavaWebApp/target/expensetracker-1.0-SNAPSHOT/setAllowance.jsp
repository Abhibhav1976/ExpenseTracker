<%@ page import="org.example.expensetracker.user" %>
<%@ page import="org.example.expensetracker.userDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Sign Up</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body {
      font-family: 'Roboto', sans-serif;
      margin: 0;
      padding: 0;
      background-color: #1c1c1e;
      color: #f5f5f7;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 2rem;
    }
    .login-signup {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 80vh;
    }
    .form-container {
      background-color: #2c2c2e;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
      width: 100%;
      max-width: 400px;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .form-container:hover {
      transform: translateY(-10px);
      box-shadow: 0 8px 16px rgba(0, 0, 0, 0.5);
    }
    .form-container h2 {
      margin-bottom: 1.5rem;
      font-weight: 700;
      color: #f5f5f7;
    }
    .form-container input {
      width: 100%;
      padding: 0.75rem;
      margin-bottom: 1rem;
      border: 1px solid #3a3a3c;
      border-radius: 4px;
      background-color: #3a3a3c;
      color: #f5f5f7;
    }
    .form-container button {
      width: 100%;
      padding: 0.75rem;
      background-color: #0071e3;
      color: #fff;
      border: none;
      border-radius: 4px;
      font-size: 1rem;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }
    .form-container button:hover {
      background-color: #005bb5;
    }
  </style>
</head>
<body>
<%
  String username = request.getParameter("username"); // Get username from request
  user currentUser = (user) session.getAttribute("currentUser");

  if (currentUser != null) {
    // Use userId from session if available
    int userId = currentUser.getId();
  }
%>
<div class="container">
  <div class="login-signup">
    <div class="form-container">
      <h2>Set Monthly Allowance</h2>
      <form action="allowance" method="post" class="mb-4">
        <div class="mb-4">
          <label for="newAllowance" class="block text-lg font-bold mb-2">New Monthly Allowance</label>
          <input type="text" name="newAllowance" id="newAllowance"
                 class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                 required placeholder="Enter new allowance">
        </div>
        <input type="submit" value="Update">
      </form>
    </div>
  </div>
</div>
</body>
</html>