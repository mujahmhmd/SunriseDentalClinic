<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%@ page import="java.util.List, java.util.Map, java.util.Set, java.util.HashSet, java.util.Arrays" %>
<%@ page import="com.icbt.SunriseDentalClinic.util.DoctorValidator" %>
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
  <title>Edit Doctor - Sunrise Dental</title>
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
    <jsp:param name="active" value="doctors" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Edit Doctor" />
    </jsp:include>

    <main class="flex-1 min-h-0 p-8 flex justify-center">
      <div class="w-full max-w-lg">

        <a href="doctors" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 mb-5 transition-colors">
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
          Back to Doctors
        </a>

        <%
          String vId = request.getAttribute("id") != null ? (String) request.getAttribute("id") : "";
          String vName = request.getAttribute("name") != null ? (String) request.getAttribute("name") : "";
          String vNic = request.getAttribute("nic") != null ? (String) request.getAttribute("nic") : "";
          String vPhone = request.getAttribute("phone") != null ? (String) request.getAttribute("phone") : "";
          String vAddress = request.getAttribute("address") != null ? (String) request.getAttribute("address") : "";
          String vSlmc = request.getAttribute("slmcRegNo") != null ? (String) request.getAttribute("slmcRegNo") : "";
          String vQualifications = request.getAttribute("qualifications") != null ? (String) request.getAttribute("qualifications") : "";
          String vExperience = request.getAttribute("experienceYears") != null ? (String) request.getAttribute("experienceYears") : "";
          String vFee = request.getAttribute("consultationFee") != null ? (String) request.getAttribute("consultationFee") : "";

          List<Map<String, String>> specializations = (List<Map<String, String>>) request.getAttribute("specializations");
          String[] selectedArr = (String[]) request.getAttribute("selectedSpecializations");
          Set<String> selected = selectedArr == null ? new HashSet<String>() : new HashSet<String>(Arrays.asList(selectedArr));

          String[] selectedDaysArr = (String[]) request.getAttribute("selectedDays");
          Set<String> selectedDays = selectedDaysArr == null ? new HashSet<String>() : new HashSet<String>(Arrays.asList(selectedDaysArr));
        %>

        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-7">
          <h1 class="font-display text-xl text-clinic-900 mb-1">Edit doctor</h1>
          <p class="text-sm text-clinic-700/70 mb-6">Update their details below.</p>

          <% if (request.getAttribute("error") != null) { %>
          <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-3.5 py-2.5">
            <%= request.getAttribute("error") %>
          </div>
          <% } %>

          <form id="editDoctorForm" action="editDoctor" method="post" novalidate>
            <input type="hidden" name="id" value="<%= vId %>">

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

            <div class="mb-6">
              <label for="address" class="block text-sm font-medium text-clinic-900 mb-1.5">Address <span class="text-clinic-700/40 font-normal">(optional)</span></label>
              <input type="text" id="address" name="address" placeholder="e.g. Trincomalee"
                     value="<%= vAddress %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
            </div>

            <h2 class="text-xs font-semibold uppercase tracking-wide text-clinic-700/50 mb-3 pt-4 border-t border-clinic-100">Professional Details</h2>

            <div class="mb-4">
              <label for="slmcRegNo" class="block text-sm font-medium text-clinic-900 mb-1.5">SLMC Registration No <span class="text-coral-500">*</span></label>
              <input type="text" id="slmcRegNo" name="slmcRegNo" placeholder="e.g. SLMC-24681" required
                     value="<%= vSlmc %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="slmcRegNoError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-clinic-900 mb-1.5">Specialization <span class="text-coral-500">*</span></label>
              <div class="flex flex-wrap gap-2">
                <% if (specializations != null) { for (Map<String, String> spec : specializations) {
                     String specId = spec.get("id");
                     boolean checked = selected.contains(specId);
                %>
                <label class="relative inline-flex cursor-pointer">
                  <input type="checkbox" name="specializations" value="<%= specId %>" class="peer absolute inset-0 w-full h-full opacity-0 m-0 cursor-pointer" <%= checked ? "checked" : "" %>>
                  <span class="inline-flex items-center px-3 py-1.5 rounded-full text-sm border border-clinic-100 text-clinic-700 peer-checked:bg-clinic-800 peer-checked:text-white peer-checked:border-clinic-800 transition-colors">
                    <%= spec.get("name") %>
                  </span>
                </label>
                <% } } %>
              </div>
              <p id="specializationsError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-4">
              <label for="qualifications" class="block text-sm font-medium text-clinic-900 mb-1.5">Qualifications <span class="text-coral-500">*</span></label>
              <input type="text" id="qualifications" name="qualifications" placeholder="e.g. BDS (Colombo), MDS (Ortho)" required
                     value="<%= vQualifications %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="qualificationsError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="grid grid-cols-2 gap-4 mb-6">
              <div>
                <label for="experienceYears" class="block text-sm font-medium text-clinic-900 mb-1.5">Years of Experience <span class="text-clinic-700/40 font-normal">(optional)</span></label>
                <input type="text" id="experienceYears" name="experienceYears" placeholder="e.g. 8"
                       value="<%= vExperience %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <p id="experienceYearsError" class="hidden text-xs text-red-600 mt-1.5"></p>
              </div>
              <div>
                <label for="consultationFee" class="block text-sm font-medium text-clinic-900 mb-1.5">Consultation Fee <span class="text-coral-500">*</span></label>
                <input type="text" id="consultationFee" name="consultationFee" placeholder="e.g. 2500" required
                       value="<%= vFee %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <p id="consultationFeeError" class="hidden text-xs text-red-600 mt-1.5"></p>
              </div>
            </div>

            <div class="mb-6">
              <label class="block text-sm font-medium text-clinic-900 mb-1.5">Visiting Days <span class="text-clinic-700/40 font-normal">(optional)</span></label>
              <div class="flex flex-wrap gap-2 mb-3">
                <% for (String day : DoctorValidator.DAYS) {
                     boolean dayChecked = selectedDays.contains(day);
                %>
                <label class="relative inline-flex cursor-pointer">
                  <input type="checkbox" name="days" value="<%= day %>" class="day-checkbox peer absolute inset-0 w-full h-full opacity-0 m-0 cursor-pointer" data-day="<%= day %>" <%= dayChecked ? "checked" : "" %>>
                  <span class="inline-flex items-center px-3 py-1.5 rounded-full text-sm border border-clinic-100 text-clinic-700 peer-checked:bg-clinic-800 peer-checked:text-white peer-checked:border-clinic-800 transition-colors">
                    <%= day.substring(0, 3) %>
                  </span>
                </label>
                <% } %>
              </div>

              <div id="dayTimeRows" class="space-y-4">
                <% for (String day : DoctorValidator.DAYS) {
                     boolean dayChecked = selectedDays.contains(day);
                     Object startAttr = request.getAttribute("start_" + day);
                     Object endAttr = request.getAttribute("end_" + day);
                     String startVal = startAttr != null ? (String) startAttr : "";
                     String endVal = endAttr != null ? (String) endAttr : "";
                %>
                <div class="day-time-row <%= dayChecked ? "" : "hidden" %> bg-clinic-50/50 border border-clinic-100 rounded-xl p-3" data-day-row="<%= day %>">
                  <p class="text-sm font-medium text-clinic-900 mb-2"><%= day %></p>

                  <p class="text-xs text-clinic-700/50 mb-1.5">From</p>
                  <div class="flex flex-wrap gap-1.5 mb-3">
                    <% for (int h = 0; h < DoctorValidator.HOURS.length; h++) {
                         String[] hour = DoctorValidator.HOURS[h];
                         boolean hourChecked = hour[0].equals(startVal);
                         // The last hour can never be a start — there'd be no later hour to end at.
                         boolean startEnabled = h < DoctorValidator.HOURS.length - 1;
                    %>
                    <label class="relative inline-flex cursor-pointer">
                      <input type="radio" name="start_<%= day %>" value="<%= hour[0] %>" class="start-radio peer absolute inset-0 w-full h-full opacity-0 m-0 cursor-pointer" data-day="<%= day %>" <%= hourChecked ? "checked" : "" %> <%= startEnabled ? "" : "disabled" %>>
                      <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs border border-clinic-100 text-clinic-700 bg-white peer-checked:bg-clinic-800 peer-checked:text-white peer-checked:border-clinic-800 peer-disabled:opacity-30 peer-disabled:cursor-not-allowed transition-colors"><%= hour[1] %></span>
                    </label>
                    <% } %>
                  </div>

                  <p class="text-xs text-clinic-700/50 mb-1.5">To</p>
                  <div class="flex flex-wrap gap-1.5">
                    <% for (String[] hour : DoctorValidator.HOURS) {
                         boolean hourChecked = hour[0].equals(endVal);
                         boolean hourEnabled = !startVal.isEmpty() && hour[0].compareTo(startVal) > 0;
                    %>
                    <label class="relative inline-flex cursor-pointer">
                      <input type="radio" name="end_<%= day %>" value="<%= hour[0] %>" class="end-radio peer absolute inset-0 w-full h-full opacity-0 m-0 cursor-pointer" data-day="<%= day %>" <%= hourChecked ? "checked" : "" %> <%= hourEnabled ? "" : "disabled" %>>
                      <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs border border-clinic-100 text-clinic-700 bg-white peer-checked:bg-clinic-800 peer-checked:text-white peer-checked:border-clinic-800 peer-disabled:opacity-30 peer-disabled:cursor-not-allowed transition-colors"><%= hour[1] %></span>
                    </label>
                    <% } %>
                  </div>
                </div>
                <% } %>
              </div>
              <p id="scheduleError" class="hidden text-xs text-red-600 mt-1.5"></p>
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

  <script src="assets/js/doctor-form-validation.js"></script>
  <script>
    initDoctorFormValidation('editDoctorForm');

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
