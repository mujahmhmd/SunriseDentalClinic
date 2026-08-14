<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%@ page import="com.icbt.SunriseDentalClinic.util.AppointmentValidator" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
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
  <title>Edit Appointment - Sunrise Dental</title>
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
    <jsp:param name="active" value="appointments" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Edit Appointment" />
    </jsp:include>

    <main class="flex-1 min-h-0 p-8 flex justify-center">
      <div class="w-full max-w-lg">

        <a href="appointments" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 mb-5 transition-colors">
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
          Back to Appointments
        </a>

        <%
          String vId = request.getAttribute("id") != null ? (String) request.getAttribute("id") : "";
          String vPatientId = request.getAttribute("patientId") != null ? (String) request.getAttribute("patientId") : "";
          String vPatientDisplay = request.getAttribute("patientDisplay") != null ? (String) request.getAttribute("patientDisplay") : "";
          String vDoctorId = request.getAttribute("doctorId") != null ? (String) request.getAttribute("doctorId") : "";
          String vDate = request.getAttribute("appointmentDate") != null ? (String) request.getAttribute("appointmentDate") : "";
          String vTime = request.getAttribute("appointmentTime") != null ? (String) request.getAttribute("appointmentTime") : "";
          String vReason = request.getAttribute("reasonForVisit") != null ? (String) request.getAttribute("reasonForVisit") : "";
          String vNotes = request.getAttribute("notes") != null ? (String) request.getAttribute("notes") : "";
          List<Map<String, String>> doctors = (List<Map<String, String>>) request.getAttribute("doctors");
        %>

        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-7">
          <h1 class="font-display text-xl text-clinic-900 mb-1">Edit appointment</h1>
          <p class="text-sm text-clinic-700/70 mb-6">Update its details below.</p>

          <% if (request.getAttribute("error") != null) { %>
          <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-3.5 py-2.5">
            <%= request.getAttribute("error") %>
          </div>
          <% } %>

          <form id="editAppointmentForm" action="editAppointment" method="post" novalidate>
            <input type="hidden" name="id" value="<%= vId %>">

            <div class="mb-4">
              <label for="patientQuery" class="block text-sm font-medium text-clinic-900 mb-1.5">Patient <span class="text-coral-500">*</span></label>
              <div class="relative">
                <input type="text" id="patientQuery" placeholder="Search by name, phone or NIC" autocomplete="off"
                       value="<%= vPatientDisplay %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <input type="hidden" id="patientId" name="patientId" value="<%= vPatientId %>">
                <ul id="patientResults" role="listbox" class="hidden absolute z-20 mt-1.5 w-full max-h-56 overflow-auto bg-white border border-clinic-100 rounded-xl shadow-lg py-1.5 text-sm"></ul>
              </div>
              <p id="patientIdError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-4">
              <label for="doctorId" class="block text-sm font-medium text-clinic-900 mb-1.5">Doctor <span class="text-coral-500">*</span></label>
              <select id="doctorId" name="doctorId" data-custom-select>
                <option value="">Select a doctor</option>
                <% if (doctors != null) { for (Map<String, String> doctor : doctors) { %>
                  <option value="<%= doctor.get("id") %>" <%= doctor.get("id").equals(vDoctorId) ? "selected" : "" %>>Dr. <%= doctor.get("name") %></option>
                <% } } %>
              </select>
              <p id="doctorIdError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-4">
              <label for="appointmentDate" class="block text-sm font-medium text-clinic-900 mb-1.5">Date <span class="text-coral-500">*</span></label>
              <input type="date" id="appointmentDate" name="appointmentDate" data-custom-date required
                     min="<%= LocalDate.now() %>" value="<%= vDate %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="appointmentDateError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-clinic-900 mb-1.5">Time <span class="text-coral-500">*</span></label>
              <div id="appointmentTimeTags" class="flex flex-wrap gap-1.5">
                <% for (String[] slot : AppointmentValidator.TIME_SLOTS) {
                     boolean timeChecked = slot[0].equals(vTime);
                %>
                <label class="relative inline-flex cursor-pointer" data-time="<%= slot[0] %>">
                  <input type="radio" name="appointmentTime" value="<%= slot[0] %>" class="peer absolute inset-0 w-full h-full opacity-0 m-0 cursor-pointer" <%= timeChecked ? "checked" : "" %>>
                  <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs border border-clinic-100 text-clinic-700 bg-white cursor-pointer peer-checked:bg-clinic-800 peer-checked:text-white peer-checked:border-clinic-800 transition-colors"><%= slot[1] %></span>
                </label>
                <% } %>
              </div>
              <div class="flex flex-wrap items-center gap-x-4 gap-y-1.5 mt-2.5 text-xs text-clinic-700/60">
                <span class="inline-flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded-full bg-clinic-800 shrink-0"></span>Selected</span>
                <span class="inline-flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded-full border border-clinic-200 bg-white shrink-0"></span>Available</span>
                <span class="inline-flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded-full bg-red-400 shrink-0"></span>Already Booked</span>
                <span class="inline-flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded-full bg-amber-400 shrink-0"></span>Patient Already Booked</span>
                <span class="inline-flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded-full bg-slate-300 shrink-0"></span>Doctor Not Visiting</span>
              </div>
              <p id="appointmentTimeError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="mb-4">
              <label for="reasonForVisit" class="block text-sm font-medium text-clinic-900 mb-1.5">Reason for Visit <span class="text-clinic-700/40 font-normal">(optional)</span></label>
              <input type="text" id="reasonForVisit" name="reasonForVisit" placeholder="e.g. Tooth pain"
                     value="<%= vReason %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
            </div>

            <div class="mb-6">
              <label for="notes" class="block text-sm font-medium text-clinic-900 mb-1.5">Notes <span class="text-clinic-700/40 font-normal">(optional)</span></label>
              <textarea id="notes" name="notes" rows="3" placeholder="Internal notes, not shown to the patient"
                        class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition resize-none"><%= vNotes %></textarea>
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

  <script src="assets/js/custom-select.js"></script>
  <script src="assets/js/custom-date.js"></script>
  <script src="assets/js/patient-search.js"></script>
  <script src="assets/js/appointment-slots.js"></script>
  <script src="assets/js/appointment-form-validation.js"></script>
  <script>
    initPatientSearch({ inputId: 'patientQuery', hiddenId: 'patientId', resultsId: 'patientResults' });
    initAppointmentSlots({ doctorId: 'doctorId', dateId: 'appointmentDate', patientId: 'patientId', tagsContainerId: 'appointmentTimeTags', excludeId: '<%= vId %>' });
    initAppointmentFormValidation('editAppointmentForm');

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
