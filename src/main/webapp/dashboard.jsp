<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  int todaysAppointmentCount = request.getAttribute("todaysAppointmentCount") != null ? (Integer) request.getAttribute("todaysAppointmentCount") : 0;
  int totalPatients = request.getAttribute("totalPatients") != null ? (Integer) request.getAttribute("totalPatients") : 0;
  int activeDoctors = request.getAttribute("activeDoctors") != null ? (Integer) request.getAttribute("activeDoctors") : 0;
  String revenueThisMonth = request.getAttribute("revenueThisMonth") != null ? (String) request.getAttribute("revenueThisMonth") : "0.00";
  List<Map<String, String>> todaysSchedule = (List<Map<String, String>>) request.getAttribute("todaysSchedule");
  // Doctors/Services/Billing pages are admin-only (RememberMeFilter enforces
  // it server-side) - this just keeps the dashboard from showing revenue or
  // linking to pages Staff would immediately get bounced away from.
  boolean isAdmin = "admin".equals(session.getAttribute("role"));
%>
<!DOCTYPE html>
<html lang="en" class="h-full overflow-hidden">
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
<body class="h-full overflow-hidden flex bg-clinic-50 text-clinic-900">

  <jsp:include page="components/sidebar.jsp">
    <jsp:param name="active" value="dashboard" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Dashboard" />
    </jsp:include>

    <main class="flex-1 p-8">

      <div class="mb-6">
        <h1 class="font-display text-2xl text-clinic-900 mb-1">Welcome, <%= session.getAttribute("name") %></h1>
        <p class="text-clinic-700/70">Here's what's happening today.</p>
      </div>

      <!-- Stat cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 <%= isAdmin ? "lg:grid-cols-4" : "lg:grid-cols-3" %> gap-4 mb-6">
        <a href="appointments" class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-5 hover:border-clinic-200 hover:shadow-md transition-all">
          <div class="w-9 h-9 rounded-lg bg-coral-500/10 text-coral-500 flex items-center justify-center mb-3">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
            </svg>
          </div>
          <p class="text-xs text-clinic-700/50 mb-0.5">Today's Appointments</p>
          <p class="font-display text-2xl text-clinic-900"><%= todaysAppointmentCount %></p>
        </a>

        <a href="patients" class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-5 hover:border-clinic-200 hover:shadow-md transition-all">
          <div class="w-9 h-9 rounded-lg bg-clinic-600/10 text-clinic-700 flex items-center justify-center mb-3">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
            </svg>
          </div>
          <p class="text-xs text-clinic-700/50 mb-0.5">Total Patients</p>
          <p class="font-display text-2xl text-clinic-900"><%= totalPatients %></p>
        </a>

        <a href="doctors" class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-5 hover:border-clinic-200 hover:shadow-md transition-all">
          <div class="w-9 h-9 rounded-lg bg-clinic-600/10 text-clinic-700 flex items-center justify-center mb-3">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 3.75v5.25a3.75 3.75 0 0 0 7.5 0V3.75" />
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 3.75h-1M13.5 3.75h1" />
              <path stroke-linecap="round" stroke-linejoin="round" d="M9.75 12.75v2.25a5.25 5.25 0 0 0 10.5 0v-1.5" />
              <circle cx="18.75" cy="15" r="1.875" />
            </svg>
          </div>
          <p class="text-xs text-clinic-700/50 mb-0.5">Active Doctors</p>
          <p class="font-display text-2xl text-clinic-900"><%= activeDoctors %></p>
        </a>

        <% if (isAdmin) { %>
        <a href="billing" class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-5 hover:border-clinic-200 hover:shadow-md transition-all">
          <div class="w-9 h-9 rounded-lg bg-clinic-600/10 text-clinic-700 flex items-center justify-center mb-3">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m-3-2.818.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
            </svg>
          </div>
          <p class="text-xs text-clinic-700/50 mb-0.5">Revenue This Month</p>
          <p class="font-display text-2xl text-clinic-900">Rs. <%= revenueThisMonth %></p>
        </a>
        <% } %>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

        <!-- Today's schedule -->
        <div class="lg:col-span-2 bg-white rounded-2xl border border-clinic-100 shadow-sm overflow-hidden">
          <div class="p-6 flex items-center justify-between border-b border-clinic-100">
            <h2 class="font-display text-lg text-clinic-900">Today's Schedule</h2>
            <a href="appointments" class="text-sm text-clinic-700 hover:text-clinic-900 font-medium">View all</a>
          </div>
          <div class="divide-y divide-clinic-50 max-h-[26rem] overflow-y-auto">
            <% if (todaysSchedule != null) { for (Map<String, String> appt : todaysSchedule) {
                 String status = appt.get("status");
                 String badgeClass;
                 if ("Completed".equals(status)) badgeClass = "bg-clinic-600/10 text-clinic-700";
                 else if ("Processing Payment".equals(status)) badgeClass = "bg-amber-50 text-amber-600";
                 else badgeClass = "bg-coral-500/10 text-coral-500";
            %>
            <div class="p-4 flex items-center justify-between gap-3">
              <div class="min-w-0">
                <p class="text-sm font-medium text-clinic-900 truncate"><%= appt.get("patientName") %></p>
                <p class="text-xs text-clinic-700/50">Dr. <%= appt.get("doctorName") %> &middot; <%= appt.get("time") %></p>
              </div>
              <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium shrink-0 <%= badgeClass %>"><%= status %></span>
            </div>
            <% } } %>

            <% if (todaysSchedule == null || todaysSchedule.isEmpty()) { %>
            <div class="py-14 text-center">
              <p class="text-clinic-700/60 text-sm">No appointments scheduled for today.</p>
            </div>
            <% } %>
          </div>
        </div>

        <!-- Quick actions -->
        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-6">
          <h2 class="font-display text-lg text-clinic-900 mb-4">Quick Actions</h2>
          <div class="space-y-2">
            <a href="createAppointment" class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium text-clinic-900 bg-clinic-50/70 hover:bg-clinic-50 transition-colors">
              <span class="w-7 h-7 rounded-lg bg-clinic-800 text-white flex items-center justify-center shrink-0">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>
              </span>
              Book Appointment
            </a>
            <a href="createPatient" class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium text-clinic-900 bg-clinic-50/70 hover:bg-clinic-50 transition-colors">
              <span class="w-7 h-7 rounded-lg bg-clinic-800 text-white flex items-center justify-center shrink-0">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>
              </span>
              Add Patient
            </a>
            <a href="createDoctor" class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium text-clinic-900 bg-clinic-50/70 hover:bg-clinic-50 transition-colors">
              <span class="w-7 h-7 rounded-lg bg-clinic-800 text-white flex items-center justify-center shrink-0">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>
              </span>
              Add Doctor
            </a>
            <% if (isAdmin) { %>
            <a href="createService" class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium text-clinic-900 bg-clinic-50/70 hover:bg-clinic-50 transition-colors">
              <span class="w-7 h-7 rounded-lg bg-clinic-800 text-white flex items-center justify-center shrink-0">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>
              </span>
              Add Service
            </a>
            <% } %>
          </div>
        </div>
      </div>
    </main>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script>
    <% if (request.getParameter("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getParameter("error")) %>', 'error');
    // Drop the ?error=... query string once it's been shown as a toast,
    // so it doesn't sit there in the address bar.
    history.replaceState(null, '', 'dashboard');
    <% } %>
  </script>

</body>
</html>
