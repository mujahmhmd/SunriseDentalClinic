<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String nic = (String) request.getAttribute("nic");
  String gender = (String) request.getAttribute("gender");
  String address = (String) request.getAttribute("address");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Patient ID Card - Sunrise Dental</title>
  <link rel="icon" type="image/svg+xml" href="assets/images/favicon.svg">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;1,9..144,500&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">

  <script src="https://cdn.tailwindcss.com"></script>
  <script src="tailwind.config.js"></script>

  <style>
    body { font-family: 'Outfit', sans-serif; }
    .font-display { font-family: 'Fraunces', serif; }
    /* Standalone page (no sidebar shell), same reasoning as appointment-receipt.jsp. */
    @media print {
      .no-print { display: none !important; }
      body { background: white !important; }
      .id-card { box-shadow: none !important; }
    }
  </style>
</head>
<body class="min-h-screen bg-clinic-50 text-clinic-900 py-10 px-4">

  <div class="max-w-sm mx-auto">

    <div class="no-print flex items-center justify-between mb-5">
      <a href="patients" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 transition-colors">
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
        </svg>
        Back to Patients
      </a>
      <button type="button" onclick="window.print()"
              class="inline-flex items-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl px-4 py-2.5 transition shadow-sm">
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
        </svg>
        Print
      </button>
    </div>

    <div class="id-card bg-white rounded-2xl border border-clinic-100 shadow-sm overflow-hidden">

      <!-- Header strip: clinic branding -->
      <div class="bg-gradient-to-br from-clinic-800 to-clinic-900 px-6 py-4 flex items-center gap-3">
        <div class="shrink-0 w-9 h-9 rounded-lg bg-white/10 ring-1 ring-white/15 flex items-center justify-center">
          <svg width="15" height="16" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M18.6667 0C20.1333 0 21.3889 0.522222 22.4333 1.56667C23.4778 2.61111 24 3.86667 24 5.33333C24 5.57778 23.9833 5.90556 23.95 6.31667C23.9167 6.72778 23.8667 7.2 23.8 7.73333L21.9667 21.1667C21.8556 22.0111 21.4722 22.7 20.8167 23.2333C20.1611 23.7667 19.4111 24.0333 18.5667 24.0333C18.0556 24.0333 17.5833 23.9222 17.15 23.7C16.7167 23.4778 16.3556 23.1667 16.0667 22.7667L12.5 17.5667C12.4556 17.4778 12.3833 17.4167 12.2833 17.3833C12.1833 17.35 12.0778 17.3333 11.9667 17.3333C11.8778 17.3333 11.7 17.4333 11.4333 17.6333L7.96667 22.6667C7.65556 23.1111 7.27222 23.45 6.81667 23.6833C6.36111 23.9167 5.87778 24.0333 5.36667 24.0333C4.52222 24.0333 3.77778 23.7611 3.13333 23.2167C2.48889 22.6722 2.11111 21.9778 2 21.1333L0.2 7.73333C0.133333 7.2 0.0833333 6.72778 0.05 6.31667C0.0166667 5.90556 0 5.57778 0 5.33333C0 3.86667 0.522222 2.61111 1.56667 1.56667C2.61111 0.522222 3.86667 0 5.33333 0C6.13333 0 6.77222 0.105556 7.25 0.316667C7.72778 0.527778 8.18889 0.755556 8.63333 1C9.07778 1.24444 9.55 1.47222 10.05 1.68333C10.55 1.89444 11.2 2 12 2C12.8 2 13.45 1.89444 13.95 1.68333C14.45 1.47222 14.9222 1.24444 15.3667 1C15.8111 0.755556 16.2778 0.527778 16.7667 0.316667C17.2556 0.105556 17.8889 0 18.6667 0ZM18.6667 2.66667C18.1556 2.66667 17.7056 2.77222 17.3167 2.98333C16.9278 3.19444 16.5 3.42222 16.0333 3.66667C15.5667 3.91111 15.0222 4.13889 14.4 4.35C13.7778 4.56111 12.9778 4.66667 12 4.66667C11.0222 4.66667 10.2222 4.56111 9.6 4.35C8.97778 4.13889 8.43333 3.91111 7.96667 3.66667C7.5 3.42222 7.07222 3.19444 6.68333 2.98333C6.29444 2.77222 5.84444 2.66667 5.33333 2.66667C4.6 2.66667 3.97222 2.92778 3.45 3.45C2.92778 3.97222 2.66667 4.6 2.66667 5.33333C2.66667 5.51111 2.67778 5.76667 2.7 6.1C2.72222 6.43333 2.76667 6.82222 2.83333 7.26667L4.66667 20.7667C4.68889 20.9444 4.76667 21.0833 4.9 21.1833C5.03333 21.2833 5.18889 21.3333 5.36667 21.3333C5.47778 21.3333 5.57778 21.3111 5.66667 21.2667C5.75556 21.2222 5.82222 21.1556 5.86667 21.0667L9.23333 16.1333C9.54444 15.6889 9.94444 15.3333 10.4333 15.0667C10.9222 14.8 11.4444 14.6667 12 14.6667C12.5556 14.6667 13.0778 14.8 13.5667 15.0667C14.0556 15.3333 14.4556 15.6889 14.7667 16.1333L18.2 21.1667C18.2444 21.2333 18.3 21.2833 18.3667 21.3167C18.4333 21.35 18.5111 21.3667 18.6 21.3667C18.7778 21.3667 18.9389 21.3167 19.0833 21.2167C19.2278 21.1167 19.3111 20.9778 19.3333 20.8L21.1667 7.26667C21.2333 6.82222 21.2778 6.43333 21.3 6.1C21.3222 5.76667 21.3333 5.51111 21.3333 5.33333C21.3333 4.6 21.0722 3.97222 20.55 3.45C20.0278 2.92778 19.4 2.66667 18.6667 2.66667Z" fill="white"/>
          </svg>
        </div>
        <div>
          <p class="font-display text-sm leading-tight text-white">Sunrise Dental Clinic</p>
          <p class="text-[11px] text-white/60">Patient ID Card</p>
        </div>
      </div>

      <div class="p-6">
        <p class="text-xs text-clinic-700/50 mb-0.5">Patient ID</p>
        <p class="font-display text-2xl text-clinic-900 mb-5 tracking-wide"><%= request.getAttribute("patientCode") %></p>

        <p class="text-xs text-clinic-700/50 mb-0.5">Name</p>
        <p class="text-base font-medium text-clinic-900 mb-4"><%= request.getAttribute("name") %></p>

        <div class="grid grid-cols-2 gap-x-4 gap-y-3.5 pt-4 border-t border-dashed border-clinic-100">
          <div>
            <p class="text-xs text-clinic-700/50 mb-0.5">Date of Birth</p>
            <p class="text-sm font-medium text-clinic-900"><%= request.getAttribute("dobDisplay") %> (<%= request.getAttribute("age") %> yrs)</p>
          </div>
          <div>
            <p class="text-xs text-clinic-700/50 mb-0.5">Gender</p>
            <p class="text-sm font-medium text-clinic-900"><%= gender != null ? gender : "—" %></p>
          </div>
          <div>
            <p class="text-xs text-clinic-700/50 mb-0.5">Phone</p>
            <p class="text-sm font-medium text-clinic-900"><%= request.getAttribute("phone") %></p>
          </div>
          <div>
            <p class="text-xs text-clinic-700/50 mb-0.5">NIC</p>
            <p class="text-sm font-medium text-clinic-900"><%= nic != null ? nic : "Not issued yet" %></p>
          </div>
          <% if (address != null && !address.isEmpty()) { %>
          <div class="col-span-2">
            <p class="text-xs text-clinic-700/50 mb-0.5">Address</p>
            <p class="text-sm font-medium text-clinic-900"><%= address %></p>
          </div>
          <% } %>
        </div>
      </div>

      <div class="bg-clinic-50/70 px-6 py-3 border-t border-clinic-100">
        <p class="text-[11px] text-clinic-700/50 text-center">Please bring this card to your appointments at Sunrise Dental Clinic.</p>
      </div>
    </div>

    <p class="no-print text-center text-xs text-clinic-700/40 mt-5">Quote the Patient ID above when booking by phone or at the front desk.</p>
  </div>

</body>
</html>
