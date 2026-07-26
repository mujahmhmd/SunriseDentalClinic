<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Dashboard - Sunrise Dental</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="tailwind.config.js"></script>
</head>
<body class="min-h-screen flex items-center justify-center bg-clinic-50">
  <div class="text-center">
    <h1 class="font-display text-2xl text-clinic-900 mb-2">
      Welcome, <%= session.getAttribute("name") %>
    </h1>
    <p class="text-clinic-700/70 mb-6">Role: <%= session.getAttribute("role") %></p>
    <a href="logout" class="text-sm text-coral-500 hover:text-coral-400 font-medium">Log out</a>
  </div>
</body>
</html>
