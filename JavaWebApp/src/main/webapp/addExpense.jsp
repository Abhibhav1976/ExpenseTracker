<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Add Expense - Expense Tracker App</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'Roboto', sans-serif;
    }
  </style>
</head>
<body class="bg-gray-900 text-white">

<!-- Header with Navigation -->
<header class="flex justify-between items-center p-6">
  <div class="text-2xl font-bold">Expense Tracker</div>
  <nav class="space-x-4 hidden md:flex">
    <a href="#" class="hover:text-gray-400">Home</a>
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

<!-- Mobile Menu -->
<div id="mobile-menu" class="hidden md:hidden">
  <nav class="flex flex-col items-center space-y-4">
    <a href="dashboard.jsp" methods="get" class="hover:text-gray-400">Home</a>
    <a href="#" class="hover:text-gray-400">Features</a>
    <a href="#" class="hover:text-gray-400">Pricing</a>
    <a href="#" class="hover:text-gray-400">Contact</a>
  </nav>
</div>

<!-- Main Content -->
<main class="flex flex-col items-center justify-center min-h-screen px-4">
  <section class="text-center">
    <h1 class="text-5xl font-bold mb-6">Add a New Expense</h1>
    <p class="text-xl mb-8">Fill in the details below to add a new expense to your tracker.</p>
  </section>

  <!-- Form Section -->
  <section class="w-full max-w-md bg-gray-800 p-8 rounded-lg shadow-lg">
    <form action="${pageContext.request.contextPath}/expenses" method="POST">
      <div class="mb-4">
        <label for="category" class="block text-lg font-bold mb-2">Category</label>
        <div class="relative">
          <select name="category" id="category" class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500 appearance-none" required>
            <option value="Food">Food</option>
            <option value="Transport">Transport</option>
            <option value="Entertainment">Entertainment</option>
            <option value="Utilities">Utilities</option>
            <option value="Others">Others</option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-white">
            <i class="fas fa-chevron-down"></i>
          </div>
        </div>
      </div>

      <div class="mb-4">
        <label for="title" class="block text-lg font-bold mb-2">Title</label>
        <input type="text" name="title" id="title" class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500" required placeholder="Expense title (e.g., Lunch)">
      </div>

      <div class="mb-4">
        <label for="amount" class="block text-lg font-bold mb-2">Amount</label>
        <input type="number" name="amount" id="amount" step="0.01" class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500" required placeholder="Enter the amount" min="0">
      </div>

      <div class="mb-4">
        <label for="date" class="block text-lg font-bold mb-2">Date</label>
        <input type="date" name="date" id="date" class="w-full p-3 rounded bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-blue-500" required value="<%= java.time.LocalDate.now() %>">
      </div>

      <div>
        <button type="submit" class="w-full bg-blue-500 text-white px-6 py-3 rounded-full text-lg hover:bg-blue-600 transition duration-300">Add Expense</button>
      </div>
    </form>
  </section>
</main>

<!-- Footer -->
<footer class="mt-16 p-6 text-center border-t border-gray-700">
  <p>&copy; 2023 Expense Tracker. All rights reserved.</p>
</footer>

<!-- JavaScript for Mobile Menu Toggle -->
<script>
  document.getElementById('menu-button').addEventListener('click', function() {
    var menu = document.getElementById('mobile-menu');
    if (menu.classList.contains('hidden')) {
      menu.classList.remove('hidden');
    } else {
      menu.classList.add('hidden');
    }
  });
</script>
</body>
</html>