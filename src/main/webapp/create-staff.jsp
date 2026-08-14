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
  <title>Create Staff - Sunrise Dental</title>
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
    <jsp:param name="active" value="staffs" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Create Staff" />
    </jsp:include>

    <main class="flex-1 min-h-0 p-8 flex justify-center">
      <div class="w-full max-w-lg">

        <a href="staffs" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 mb-5 transition-colors">
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
          Back to Staffs
        </a>

        <%
          String vName = request.getAttribute("name") != null ? (String) request.getAttribute("name") : "";
          String vNic = request.getAttribute("nic") != null ? (String) request.getAttribute("nic") : "";
          String vAddress = request.getAttribute("address") != null ? (String) request.getAttribute("address") : "";
          String vPhone = request.getAttribute("phone") != null ? (String) request.getAttribute("phone") : "";
          String vEmail = request.getAttribute("email") != null ? (String) request.getAttribute("email") : "";
          String vUsername = request.getAttribute("username") != null ? (String) request.getAttribute("username") : "";
        %>

        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-7">
          <h1 class="font-display text-xl text-clinic-900 mb-1">Add a new staff member</h1>
          <p class="text-sm text-clinic-700/70 mb-6">They'll be able to log in immediately with the credentials below.</p>

          <% if (request.getAttribute("error") != null) { %>
          <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-3.5 py-2.5">
            <%= request.getAttribute("error") %>
          </div>
          <% } %>

          <form id="createStaffForm" action="createStaff" method="post" novalidate>

            <h2 class="text-xs font-semibold uppercase tracking-wide text-clinic-700/50 mb-3">Personal Details</h2>

            <div class="mb-4">
              <label for="name" class="block text-sm font-medium text-clinic-900 mb-1.5">Full Name <span class="text-coral-500">*</span></label>
              <input type="text" id="name" name="name" placeholder="e.g. Mujahith Mohamed" required
                     value="<%= vName %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="nameError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label for="nic" class="block text-sm font-medium text-clinic-900 mb-1.5">NIC <span class="text-coral-500">*</span></label>
                <input type="text" id="nic" name="nic" placeholder="e.g. 200012345678" required
                       value="<%= vNic %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <p id="nicError" class="hidden text-xs text-red-600 mt-1.5"></p>
              </div>
              <div>
                <label for="phone" class="block text-sm font-medium text-clinic-900 mb-1.5">Contact Number <span class="text-coral-500">*</span></label>
                <input type="text" id="phone" name="phone" placeholder="e.g. 0712345678" required
                       value="<%= vPhone %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <p id="phoneError" class="hidden text-xs text-red-600 mt-1.5"></p>
              </div>
            </div>

            <div class="mb-4">
              <label for="email" class="block text-sm font-medium text-clinic-900 mb-1.5">Email <span class="text-coral-500">*</span></label>
              <input type="email" id="email" name="email" placeholder="e.g. jane.perera@sunrisedental.lk" required
                     value="<%= vEmail %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="emailError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-6">
              <label for="address" class="block text-sm font-medium text-clinic-900 mb-1.5">Address <span class="text-clinic-700/40 font-normal">(optional)</span></label>
              <input type="text" id="address" name="address" placeholder="e.g. Trincomalee"
                     value="<%= vAddress %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
            </div>

            <h2 class="text-xs font-semibold uppercase tracking-wide text-clinic-700/50 mb-3 pt-4 border-t border-clinic-100">Login Details</h2>

            <div class="mb-4">
              <label for="username" class="block text-sm font-medium text-clinic-900 mb-1.5">Username <span class="text-coral-500">*</span></label>
              <input type="text" id="username" name="username" placeholder="e.g. mujahith.mohamed" maxlength="16" required
                     value="<%= vUsername %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="usernameError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-6">
              <label for="password" class="block text-sm font-medium text-clinic-900 mb-1.5">Password <span class="text-coral-500">*</span></label>
              <div class="relative">
                <input type="password" id="password" name="password" placeholder="e.g. Welcome@123" required
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 pr-10 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <button type="button" onclick="togglePassword()" aria-label="Show password" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-clinic-700/40 hover:text-clinic-700">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  </svg>
                </button>
              </div>
              <p id="passwordError" class="hidden text-xs text-red-600 mt-1.5"></p>
              <p class="text-xs text-clinic-700/50 mt-1.5">Share this with them directly; it's encrypted the moment it's saved.</p>
            </div>

            <button type="submit"
                    class="w-full flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl py-3 transition shadow-lg shadow-clinic-900/15">
              Create Staff Account
            </button>
          </form>
        </div>
      </div>
    </main>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script src="assets/js/staff-form-validation.js"></script>
  <script>
    // Shows/hides the password text
    function togglePassword() {
      const field = document.getElementById('password');
      field.type = field.type === 'password' ? 'text' : 'password';
    }

    initStaffFormValidation('createStaffForm');

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
