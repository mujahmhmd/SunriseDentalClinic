<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
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
  <title>Billing - Sunrise Dental</title>
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
    <jsp:param name="active" value="billing" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Billing" />
    </jsp:include>

    <!-- Placeholder for now; the billing/invoicing UI will be built later. -->
    <main class="flex-1 p-8">
      <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-8">
        <h1 class="font-display text-2xl text-clinic-900 mb-1">Billing</h1>
        <p class="text-clinic-700/70">This page is coming soon.</p>
      </div>
    </main>
  </div>

</body>
</html>
