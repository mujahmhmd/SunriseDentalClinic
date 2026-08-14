<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // Only reachable once step 2 has actually verified a code — typing this
  // URL directly (or coming back after the code's since expired) sends you
  // back to start rather than showing a form that can't succeed.
  Object otpVerified = session.getAttribute("otpVerified");
  if (session.getAttribute("resetUserId") == null || otpVerified == null || !((Boolean) otpVerified)) {
    response.sendRedirect("forgot-password.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password - Sunrise Dental</title>
  <link rel="icon" type="image/svg+xml" href="assets/images/favicon.svg">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;1,9..144,500&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">

  <script src="https://cdn.tailwindcss.com"></script>
  <script src="tailwind.config.js"></script>

  <style>
    body { font-family: 'Outfit', sans-serif; }
    .font-display { font-family: 'Fraunces', serif; }
    .grain::before {
      content: '';
      position: fixed;
      inset: 0;
      pointer-events: none;
      opacity: 0.035;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='120' height='120'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
    }
  </style>
</head>
<body class="grain min-h-screen relative flex items-center justify-center bg-clinic-50 px-4 overflow-hidden">

  <div class="pointer-events-none absolute -top-32 -left-24 w-96 h-96 rounded-full bg-clinic-600/20 blur-3xl"></div>
  <div class="pointer-events-none absolute -bottom-32 -right-16 w-[28rem] h-[28rem] rounded-full bg-coral-400/20 blur-3xl"></div>

  <div class="w-full max-w-sm relative">

    <div class="flex flex-col items-center mb-7">
      <div class="relative w-14 h-14 rounded-2xl bg-gradient-to-br from-clinic-600 to-clinic-800 shadow-lg shadow-clinic-900/20 flex items-center justify-center mb-4">
        <svg class="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M12 17.25h.007v.008H12v-.008ZM12 3.75a9 9 0 1 0 0 18 9 9 0 0 0 0-18Z" />
        </svg>
      </div>
      <h1 class="font-display text-2xl text-clinic-900">Reset Password</h1>
      <p class="text-sm text-clinic-700/70 mt-1 text-center">Choose a new password for your account.</p>
    </div>

    <div class="bg-white/90 backdrop-blur rounded-[1.75rem] shadow-xl shadow-clinic-900/10 border border-clinic-100 p-7">
      <form id="resetPasswordForm" action="resetPassword" method="post" novalidate>

        <div class="mb-4">
          <label for="newPassword" class="block text-sm font-medium text-clinic-900 mb-1.5">New Password</label>
          <div class="relative">
            <input type="password" id="newPassword" name="newPassword" placeholder="e.g. Welcome@123" required
                   class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 pr-10 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
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
            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-type the password above" required
                   class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 pr-10 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
            <button type="button" onclick="togglePassword('confirmPassword')" aria-label="Show password" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-clinic-700/40 hover:text-clinic-700">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
              </svg>
            </button>
          </div>
          <p id="confirmPasswordError" class="hidden text-xs text-red-600 mt-1.5"></p>
        </div>

        <button type="submit"
                class="w-full flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl py-3 transition shadow-lg shadow-clinic-900/15">
          Reset Password
        </button>
      </form>
    </div>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script>
    function togglePassword(id) {
      var field = document.getElementById(id);
      field.type = field.type === 'password' ? 'text' : 'password';
    }

    var PASSWORD_PATTERN = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$/;

    function showFieldError(id, message) {
      var errorEl = document.getElementById(id + 'Error');
      var inputEl = document.getElementById(id);
      errorEl.textContent = message;
      errorEl.classList.remove('hidden');
      inputEl.classList.add('border-red-400');
      inputEl.classList.remove('border-clinic-100');
    }

    function clearFieldError(id) {
      var errorEl = document.getElementById(id + 'Error');
      var inputEl = document.getElementById(id);
      errorEl.classList.add('hidden');
      inputEl.classList.remove('border-red-400');
      inputEl.classList.add('border-clinic-100');
    }

    function validateNewPassword() {
      var password = document.getElementById('newPassword').value;
      if (!PASSWORD_PATTERN.test(password)) {
        showFieldError('newPassword', 'Min 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.');
        return false;
      }
      clearFieldError('newPassword');
      return true;
    }

    function validateConfirmPassword() {
      var password = document.getElementById('newPassword').value;
      var confirm = document.getElementById('confirmPassword').value;
      if (confirm !== password) {
        showFieldError('confirmPassword', "Passwords don't match.");
        return false;
      }
      clearFieldError('confirmPassword');
      return true;
    }

    document.getElementById('newPassword').addEventListener('blur', validateNewPassword);
    document.getElementById('confirmPassword').addEventListener('blur', validateConfirmPassword);

    document.getElementById('resetPasswordForm').addEventListener('submit', function (e) {
      var valid = [validateNewPassword(), validateConfirmPassword()].every(function (r) { return r; });
      if (!valid) e.preventDefault();
    });

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
