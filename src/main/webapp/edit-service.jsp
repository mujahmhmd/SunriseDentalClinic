<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en" class="h-full overflow-hidden">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Edit Service - Sunrise Dental</title>
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
<body class="h-full overflow-hidden flex bg-clinic-50 text-clinic-900">

  <jsp:include page="components/sidebar.jsp">
    <jsp:param name="active" value="services" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Edit Service" />
    </jsp:include>

    <main class="flex-1 min-h-0 p-8 flex justify-center">
      <div class="w-full max-w-lg">

        <a href="services" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 mb-5 transition-colors">
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
          Back to Services
        </a>

        <%
          String vId = request.getAttribute("id") != null ? (String) request.getAttribute("id") : "";
          String vName = request.getAttribute("name") != null ? (String) request.getAttribute("name") : "";
          String vPrice = request.getAttribute("price") != null ? (String) request.getAttribute("price") : "";
          String vDescription = request.getAttribute("description") != null ? (String) request.getAttribute("description") : "";
        %>

        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-7">
          <h1 class="font-display text-xl text-clinic-900 mb-1">Edit service</h1>
          <p class="text-sm text-clinic-700/70 mb-6">Update its details below.</p>

          <% if (request.getAttribute("error") != null) { %>
          <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-3.5 py-2.5">
            <%= request.getAttribute("error") %>
          </div>
          <% } %>

          <form id="editServiceForm" action="editService" method="post" novalidate>
            <input type="hidden" name="id" value="<%= vId %>">

            <div class="mb-4">
              <label for="name" class="block text-sm font-medium text-clinic-900 mb-1.5">Service Name <span class="text-coral-500">*</span></label>
              <input type="text" id="name" name="name" placeholder="e.g. Root Canal Treatment" required
                     value="<%= vName %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="nameError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-4">
              <label for="price" class="block text-sm font-medium text-clinic-900 mb-1.5">Price (LKR) <span class="text-coral-500">*</span></label>
              <div class="relative">
                <span class="absolute left-3.5 top-1/2 -translate-y-1/2 text-sm text-clinic-700/40">Rs.</span>
                <input type="text" inputmode="decimal" id="price" name="price" placeholder="e.g. 5000" required
                       value="<%= vPrice %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl pl-10 pr-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              </div>
              <p id="priceError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-6">
              <label for="description" class="block text-sm font-medium text-clinic-900 mb-1.5">Description <span class="text-clinic-700/40 font-normal">(optional)</span></label>
              <textarea id="description" name="description" rows="3" placeholder="A short note on what this treatment involves"
                        class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition resize-none"><%= vDescription %></textarea>
              <p id="descriptionError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <button type="submit"
                    class="w-full flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl py-3 transition shadow-lg shadow-clinic-900/15">
              Save Changes
            </button>
          </form>
        </div>
      </div>
    </main>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script src="assets/js/service-form-validation.js"></script>
  <script>
    initServiceFormValidation('editServiceForm');

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
