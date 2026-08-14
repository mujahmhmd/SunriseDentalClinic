<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
  String vEmail = request.getAttribute("email") != null ? (String) request.getAttribute("email") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Forgot Password - Sunrise Dental</title>
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
        <svg width="24" height="25" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg" class="w-7 h-7">
          <path d="M18.6667 0C20.1333 0 21.3889 0.522222 22.4333 1.56667C23.4778 2.61111 24 3.86667 24 5.33333C24 5.57778 23.9833 5.90556 23.95 6.31667C23.9167 6.72778 23.8667 7.2 23.8 7.73333L21.9667 21.1667C21.8556 22.0111 21.4722 22.7 20.8167 23.2333C20.1611 23.7667 19.4111 24.0333 18.5667 24.0333C18.0556 24.0333 17.5833 23.9222 17.15 23.7C16.7167 23.4778 16.3556 23.1667 16.0667 22.7667L12.5 17.5667C12.4556 17.4778 12.3833 17.4167 12.2833 17.3833C12.1833 17.35 12.0778 17.3333 11.9667 17.3333C11.8778 17.3333 11.7 17.4333 11.4333 17.6333L7.96667 22.6667C7.65556 23.1111 7.27222 23.45 6.81667 23.6833C6.36111 23.9167 5.87778 24.0333 5.36667 24.0333C4.52222 24.0333 3.77778 23.7611 3.13333 23.2167C2.48889 22.6722 2.11111 21.9778 2 21.1333L0.2 7.73333C0.133333 7.2 0.0833333 6.72778 0.05 6.31667C0.0166667 5.90556 0 5.57778 0 5.33333C0 3.86667 0.522222 2.61111 1.56667 1.56667C2.61111 0.522222 3.86667 0 5.33333 0C6.13333 0 6.77222 0.105556 7.25 0.316667C7.72778 0.527778 8.18889 0.755556 8.63333 1C9.07778 1.24444 9.55 1.47222 10.05 1.68333C10.55 1.89444 11.2 2 12 2C12.8 2 13.45 1.89444 13.95 1.68333C14.45 1.47222 14.9222 1.24444 15.3667 1C15.8111 0.755556 16.2778 0.527778 16.7667 0.316667C17.2556 0.105556 17.8889 0 18.6667 0ZM18.6667 2.66667C18.1556 2.66667 17.7056 2.77222 17.3167 2.98333C16.9278 3.19444 16.5 3.42222 16.0333 3.66667C15.5667 3.91111 15.0222 4.13889 14.4 4.35C13.7778 4.56111 12.9778 4.66667 12 4.66667C11.0222 4.66667 10.2222 4.56111 9.6 4.35C8.97778 4.13889 8.43333 3.91111 7.96667 3.66667C7.5 3.42222 7.07222 3.19444 6.68333 2.98333C6.29444 2.77222 5.84444 2.66667 5.33333 2.66667C4.6 2.66667 3.97222 2.92778 3.45 3.45C2.92778 3.97222 2.66667 4.6 2.66667 5.33333C2.66667 5.51111 2.67778 5.76667 2.7 6.1C2.72222 6.43333 2.76667 6.82222 2.83333 7.26667L4.66667 20.7667C4.68889 20.9444 4.76667 21.0833 4.9 21.1833C5.03333 21.2833 5.18889 21.3333 5.36667 21.3333C5.47778 21.3333 5.57778 21.3111 5.66667 21.2667C5.75556 21.2222 5.82222 21.1556 5.86667 21.0667L9.23333 16.1333C9.54444 15.6889 9.94444 15.3333 10.4333 15.0667C10.9222 14.8 11.4444 14.6667 12 14.6667C12.5556 14.6667 13.0778 14.8 13.5667 15.0667C14.0556 15.3333 14.4556 15.6889 14.7667 16.1333L18.2 21.1667C18.2444 21.2333 18.3 21.2833 18.3667 21.3167C18.4333 21.35 18.5111 21.3667 18.6 21.3667C18.7778 21.3667 18.9389 21.3167 19.0833 21.2167C19.2278 21.1167 19.3111 20.9778 19.3333 20.8L21.1667 7.26667C21.2333 6.82222 21.2778 6.43333 21.3 6.1C21.3222 5.76667 21.3333 5.51111 21.3333 5.33333C21.3333 4.6 21.0722 3.97222 20.55 3.45C20.0278 2.92778 19.4 2.66667 18.6667 2.66667Z" fill="white"/>
        </svg>
      </div>
      <h1 class="font-display text-2xl text-clinic-900">Forgot Password</h1>
      <p class="text-sm text-clinic-700/70 mt-1 text-center">Enter your account email and we'll send you a reset code.</p>
    </div>

    <div class="bg-white/90 backdrop-blur rounded-[1.75rem] shadow-xl shadow-clinic-900/10 border border-clinic-100 p-7">
      <form id="forgotPasswordForm" action="forgotPassword" method="post" novalidate>

        <div class="mb-6">
          <label for="email" class="block text-sm font-medium text-clinic-900 mb-1.5">Email</label>
          <div class="relative">
            <svg class="w-4 h-4 text-clinic-700/40 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
            </svg>
            <input type="email" id="email" name="email" placeholder="e.g. mujahithmohamed59@gmail.com" required
                   value="<%= vEmail %>"
                   class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl pl-10 pr-3 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
          </div>
          <p id="emailError" class="hidden text-xs text-red-600 mt-1.5"></p>
        </div>

        <button type="submit"
                class="w-full flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl py-3 transition shadow-lg shadow-clinic-900/15">
          Send Reset Code
        </button>
      </form>
    </div>

    <div class="flex justify-center mt-5">
      <a href="login.jsp" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 transition-colors">
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
        </svg>
        Back to Login
      </a>
    </div>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script>
    document.getElementById('forgotPasswordForm').addEventListener('submit', function (e) {
      var email = document.getElementById('email').value.trim();
      var errorEl = document.getElementById('emailError');
      var inputEl = document.getElementById('email');
      if (email === '') {
        errorEl.textContent = 'Enter your email address.';
        errorEl.classList.remove('hidden');
        inputEl.classList.add('border-red-400');
        inputEl.classList.remove('border-clinic-100');
        e.preventDefault();
      } else {
        errorEl.classList.add('hidden');
        inputEl.classList.remove('border-red-400');
        inputEl.classList.add('border-clinic-100');
      }
    });

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
