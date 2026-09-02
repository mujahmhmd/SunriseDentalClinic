<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // Only reachable after forgot-password.jsp has actually issued a code -
  // typing this URL directly with nothing in flight just sends you back to start.
  if (session.getAttribute("resetUserId") == null) {
    response.sendRedirect("forgot-password.jsp");
    return;
  }
  String resetEmail = (String) session.getAttribute("resetEmail");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Enter Reset Code - Sunrise Dental</title>
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
          <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
        </svg>
      </div>
      <h1 class="font-display text-2xl text-clinic-900">Enter Reset Code</h1>
      <p class="text-sm text-clinic-700/70 mt-1 text-center">We sent a 6-digit code to <span class="font-medium text-clinic-900"><%= resetEmail %></span>. It expires in 5 minutes.</p>
    </div>

    <div class="bg-white/90 backdrop-blur rounded-[1.75rem] shadow-xl shadow-clinic-900/10 border border-clinic-100 p-7">
      <form id="verifyOtpForm" action="verifyOtp" method="post" novalidate>

        <div class="mb-6">
          <label for="otpBox0" class="block text-sm font-medium text-clinic-900 mb-2 text-center">6-Digit Code</label>
          <div id="otpBoxes" class="flex items-center justify-center gap-2.5">
            <% for (int i = 0; i < 6; i++) { %>
            <input type="text" id="otpBox<%= i %>" class="otp-box w-10 h-12 sm:w-12 sm:h-14 border border-clinic-100 bg-clinic-50/50 rounded-xl text-center text-xl font-semibold text-clinic-900 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition"
                   inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" aria-label="Digit <%= i + 1 %> of 6">
            <% } %>
          </div>
          <input type="hidden" id="otp" name="otp">
          <p id="otpError" class="hidden text-xs text-red-600 mt-2.5 text-center"></p>
        </div>

        <button type="submit"
                class="w-full flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl py-3 transition shadow-lg shadow-clinic-900/15">
          Verify Code
        </button>
      </form>
    </div>

    <div class="flex justify-center mt-5">
      <a href="forgot-password.jsp" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 transition-colors">
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
        </svg>
        Use a different email / resend code
      </a>
    </div>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script src="assets/js/otp-input.js"></script>
  <script>
    var otpForm = document.getElementById('verifyOtpForm');
    var otpBoxes = Array.prototype.slice.call(document.querySelectorAll('.otp-box'));
    var otpErrorEl = document.getElementById('otpError');

    function showOtpError(message) {
      otpErrorEl.textContent = message;
      otpErrorEl.classList.remove('hidden');
      otpBoxes.forEach(function (box) {
        box.classList.add('border-red-400');
        box.classList.remove('border-clinic-100');
      });
    }

    function clearOtpError() {
      otpErrorEl.classList.add('hidden');
      otpBoxes.forEach(function (box) {
        box.classList.remove('border-red-400');
        box.classList.add('border-clinic-100');
      });
    }

    initOtpInput({
      containerId: 'otpBoxes',
      hiddenInputId: 'otp',
      // All 6 digits typed (or a full code pasted in) - submit right away
      // instead of making them also click Verify Code.
      onComplete: function () { otpForm.requestSubmit(); }
    });

    // Any edit after an error is showing means they're correcting it -
    // don't leave the boxes red while they're actively retyping.
    document.getElementById('otp').addEventListener('input', clearOtpError);

    otpForm.addEventListener('submit', function (e) {
      var otp = document.getElementById('otp').value;
      if (!/^\d{6}$/.test(otp)) {
        showOtpError('Enter the 6-digit code.');
        e.preventDefault();
      } else {
        clearOtpError();
      }
    });

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
