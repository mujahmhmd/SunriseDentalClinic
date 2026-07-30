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
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard - Sunrise Dental</title>
  <link rel="icon" type="image/svg+xml" href="assets/images/favicon.svg">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;1,9..144,500&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">

  <script src="https://cdn.tailwindcss.com"></script>
  <script src="tailwind.config.js"></script>

  <style>
    body { font-family: 'Outfit', sans-serif; }
    .font-display { font-family: 'Fraunces', serif; }
  </style>
</head>
<body class="min-h-screen flex bg-clinic-50 text-clinic-900">

  <jsp:include page="components/sidebar.jsp">
    <jsp:param name="active" value="dashboard" />
  </jsp:include>

  <!-- Main content -->
  <div class="flex-1 flex flex-col min-w-0">

    <!-- Top bar -->
    <header class="h-20 px-8 flex items-center justify-between border-b border-clinic-100 bg-white/60 backdrop-blur">
      <h2 class="font-display text-xl text-clinic-900">Dashboard</h2>
      <div class="flex items-center gap-3">
        <div class="text-right">
          <p class="text-sm font-medium text-clinic-900"><%= session.getAttribute("name") %></p>
          <p class="text-xs text-clinic-700/60 capitalize"><%= session.getAttribute("role") %></p>
        </div>
        <div class="w-9 h-9 rounded-full bg-clinic-800 text-clinic-50 flex items-center justify-center text-sm font-medium">
          <%= String.valueOf(session.getAttribute("name")).trim().charAt(0) %>
        </div>
      </div>
    </header>

    <!-- Page content -->
    <main class="flex-1 p-8">
      <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-8">
        <h1 class="font-display text-2xl text-clinic-900 mb-1">
          Welcome, <%= session.getAttribute("name") %>
        </h1>
        <p class="text-clinic-700/70">You're signed in as a <%= session.getAttribute("role") %>.</p>
      </div>
    </main>
  </div>

</body>
</html>
