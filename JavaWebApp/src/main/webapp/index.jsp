<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Expense Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"></link>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
        }
    </style>
</head>
<body class="bg-gray-900 text-white">
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

<div id="mobile-menu" class="hidden md:hidden">
    <nav class="flex flex-col items-center space-y-4">
        <a href="#" class="hover:text-gray-400">Home</a>
        <a href="#" class="hover:text-gray-400">Features</a>
        <a href="#" class="hover:text-gray-400">Pricing</a>
        <a href="#" class="hover:text-gray-400">Contact</a>
    </nav>
</div>

<main class="flex flex-col items-center justify-center min-h-screen px-4">
    <section class="text-center">
        <h1 class="text-5xl font-bold mb-6">Track Your Expenses Effortlessly</h1>
        <p class="text-xl mb-8">Manage your finances with ease using our intuitive expense tracker app.</p>
        <form action="login.jsp" method="get">
        <button type="submit" class="bg-blue-500 text-white px-6 py-3 rounded-full text-lg hover:bg-blue-600 transition duration-300">Get Started</button>
        </form>
    </section>

    <section class="mt-16 w-full">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="bg-gray-800 p-6 rounded-lg shadow-lg">
                <i class="fas fa-chart-line text-4xl mb-4"></i>
                <h2 class="text-2xl font-bold mb-2">Real-Time Analytics</h2>
                <p>Get insights into your spending habits with real-time analytics and detailed reports.</p>
            </div>
            <div class="bg-gray-800 p-6 rounded-lg shadow-lg">
                <i class="fas fa-mobile-alt text-4xl mb-4"></i>
                <h2 class="text-2xl font-bold mb-2">Mobile Friendly</h2>
                <p>Access your expense tracker on the go with our mobile-friendly design.</p>
            </div>
            <div class="bg-gray-800 p-6 rounded-lg shadow-lg">
                <i class="fas fa-lock text-4xl mb-4"></i>
                <h2 class="text-2xl font-bold mb-2">Secure and Private</h2>
                <p>Your data is secure with us. We prioritize your privacy and data protection.</p>
            </div>
        </div>
    </section>
</main>

<footer class="mt-16 p-6 text-center border-t border-gray-700">
    <p>&copy; 2023 Expense Tracker. All rights reserved.</p>
</footer>

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