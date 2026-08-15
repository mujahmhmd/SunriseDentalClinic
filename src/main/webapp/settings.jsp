<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String vUsername = request.getAttribute("username") != null
      ? (String) request.getAttribute("username")
      : (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en" class="h-full overflow-hidden">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Settings - Sunrise Dental</title>
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
    <jsp:param name="active" value="settings" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Settings" />
    </jsp:include>

    <main class="flex-1 min-h-0 p-8 flex justify-center">
      <div class="w-full max-w-lg space-y-6">

        <!-- Account -->
        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-7">
          <h1 class="font-display text-xl text-clinic-900 mb-1">Account</h1>
          <p class="text-sm text-clinic-700/70 mb-6">This is what you sign in with.</p>

          <% if (request.getAttribute("usernameError") != null) { %>
          <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-3.5 py-2.5">
            <%= request.getAttribute("usernameError") %>
          </div>
          <% } %>

          <form id="updateUsernameForm" action="updateUsername" method="post" novalidate>
            <div class="mb-6">
              <label for="username" class="block text-sm font-medium text-clinic-900 mb-1.5">Username</label>
              <input type="text" id="username" name="username" placeholder="e.g. mujahith.mohamed" required
                     value="<%= vUsername %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="usernameError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <button type="submit"
                    class="w-full flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl py-3 transition shadow-lg shadow-clinic-900/15">
              Update Username
            </button>
          </form>
        </div>

        <!-- Change password -->
        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-7">
          <h1 class="font-display text-xl text-clinic-900 mb-1">Change password</h1>
          <p class="text-sm text-clinic-700/70 mb-6">Confirm your current password first, then choose a new one.</p>

          <% if (request.getAttribute("passwordError") != null) { %>
          <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-3.5 py-2.5">
            <%= request.getAttribute("passwordError") %>
          </div>
          <% } %>

          <form id="updatePasswordForm" action="updateAccountPassword" method="post" novalidate>

            <div class="mb-4">
              <label for="currentPassword" class="block text-sm font-medium text-clinic-900 mb-1.5">Current Password</label>
              <div class="relative">
                <input type="password" id="currentPassword" name="currentPassword" placeholder="••••••••" required
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 pr-10 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <button type="button" onclick="togglePassword('currentPassword')" aria-label="Show password" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-clinic-700/40 hover:text-clinic-700">
                  <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  </svg>
                </button>
              </div>
              <p id="currentPasswordError" class="hidden text-xs text-red-600 mt-1.5"></p>
              <p id="currentPasswordVerified" class="hidden text-xs text-clinic-600 mt-1.5">✓ Verified — you can set a new password below.</p>
            </div>

            <div class="mb-4">
              <label for="newPassword" class="block text-sm font-medium text-clinic-900 mb-1.5">New Password</label>
              <div class="relative">
                <input type="password" id="newPassword" name="newPassword" placeholder="e.g. Welcome@123" required disabled
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 pr-10 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition disabled:opacity-50 disabled:cursor-not-allowed">
                <button type="button" onclick="togglePassword('newPassword')" aria-label="Show password" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-clinic-700/40 hover:text-clinic-700">
                  <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  </svg>
                </button>
              </div>
              <p id="newPasswordError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-6">
              <label for="confirmPassword" class="block text-sm font-medium text-clinic-900 mb-1.5">Confirm New Password</label>
              <div class="relative">
                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-type the password above" required disabled
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 pr-10 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition disabled:opacity-50 disabled:cursor-not-allowed">
                <button type="button" onclick="togglePassword('confirmPassword')" aria-label="Show password" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-clinic-700/40 hover:text-clinic-700">
                  <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  </svg>
                </button>
              </div>
              <p id="confirmPasswordError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <button type="submit" id="updatePasswordBtn" disabled
                    class="w-full flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl py-3 transition shadow-lg shadow-clinic-900/15 disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-clinic-800">
              Update Password
            </button>
          </form>
        </div>

      </div>
    </main>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script src="assets/js/settings-validation.js"></script>
  <script>
    initSettingsValidation();

    <% if (request.getAttribute("usernameError") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("usernameError")) %>', 'error');
    <% } %>
    <% if (request.getAttribute("passwordError") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("passwordError")) %>', 'error');
    <% } %>
    <% if (request.getParameter("success") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getParameter("success")) %>', 'success');
    history.replaceState(null, '', 'settings');
    <% } %>
  </script>

</body>
</html>
