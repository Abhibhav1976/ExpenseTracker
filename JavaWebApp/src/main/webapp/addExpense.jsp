<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <title>Add Expense</title>
  <link rel="stylesheet" href="styles.css"> <!-- Optional: Add a stylesheet link if needed -->
</head>
<body>
<h2>Add a New Expense</h2>

<!-- Form to submit a new expense -->
<form action="${pageContext.request.contextPath}/expenses" method="POST">
  <div>
    <label for="category">Category:</label>
    <select name="category" id="category" required>
      <option value="Food">Food</option>
      <option value="Transport">Transport</option>
      <option value="Entertainment">Entertainment</option>
      <option value="Utilities">Utilities</option>
      <option value="Others">Others</option>
    </select>
  </div>

  <div>
    <label for="title">Title:</label>
    <input type="text" name="title" id="title" required placeholder="Expense title (e.g., Lunch)">
  </div>

  <div>
    <label for="amount">Amount:</label>
    <input type="number" name="amount" id="amount" step="0.01" required placeholder="Enter the amount" min="0">
  </div>

  <div>
    <label for="date">Date:</label>
    <input type="date" name="date" id="date" required value="<%= java.time.LocalDate.now() %>">
  </div>

  <div>
    <button type="submit">Add Expense</button>
  </div>
</form>
</body>
</html>
