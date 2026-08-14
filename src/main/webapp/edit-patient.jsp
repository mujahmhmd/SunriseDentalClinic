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
  <title>Edit Patient - Sunrise Dental</title>
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
    <jsp:param name="active" value="patients" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Edit Patient" />
    </jsp:include>

    <main class="flex-1 min-h-0 p-8 flex justify-center">
      <div class="w-full max-w-lg">

        <a href="patients" class="inline-flex items-center gap-1.5 text-sm text-clinic-700/70 hover:text-clinic-900 mb-5 transition-colors">
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
          Back to Patients
        </a>

        <%
          String vId = request.getAttribute("id") != null ? (String) request.getAttribute("id") : "";
          String vName = request.getAttribute("name") != null ? (String) request.getAttribute("name") : "";
          String vDob = request.getAttribute("dateOfBirth") != null ? (String) request.getAttribute("dateOfBirth") : "";
          String vPhone = request.getAttribute("phone") != null ? (String) request.getAttribute("phone") : "";
          String vNic = request.getAttribute("nic") != null ? (String) request.getAttribute("nic") : "";
          String vGender = request.getAttribute("gender") != null ? (String) request.getAttribute("gender") : "";
          String vAddress = request.getAttribute("address") != null ? (String) request.getAttribute("address") : "";
        %>

        <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-7">
          <h1 class="font-display text-xl text-clinic-900 mb-1">Edit patient</h1>
          <p class="text-sm text-clinic-700/70 mb-6">Update their details below.</p>

          <% if (request.getAttribute("error") != null) { %>
          <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-3.5 py-2.5">
            <%= request.getAttribute("error") %>
          </div>
          <% } %>

          <form id="editPatientForm" action="editPatient" method="post" novalidate>
            <input type="hidden" name="id" value="<%= vId %>">

            <div class="mb-4">
              <label for="name" class="block text-sm font-medium text-clinic-900 mb-1.5">Full Name <span class="text-coral-500">*</span></label>
              <input type="text" id="name" name="name" placeholder="e.g. Mujahith Mohamed" required
                     value="<%= vName %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
              <p id="nameError" class="hidden text-xs text-red-600 mt-1.5"></p>
            </div>

            <div class="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label for="dateOfBirth" class="block text-sm font-medium text-clinic-900 mb-1.5">Date of Birth <span class="text-coral-500">*</span></label>
                <input type="date" id="dateOfBirth" name="dateOfBirth" data-custom-date required
                       value="<%= vDob %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <p id="dateOfBirthError" class="hidden text-xs text-red-600 mt-1.5"></p>
              </div>
              <div>
                <label for="phone" class="block text-sm font-medium text-clinic-900 mb-1.5">Contact Number <span class="text-coral-500">*</span></label>
                <input type="text" id="phone" name="phone" placeholder="e.g. 0712345678" required
                       value="<%= vPhone %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <p id="phoneError" class="hidden text-xs text-red-600 mt-1.5"></p>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label for="nic" class="block text-sm font-medium text-clinic-900 mb-1.5">NIC <span class="text-clinic-700/40 font-normal">(optional)</span></label>
                <input type="text" id="nic" name="nic" placeholder="e.g. 200012345678"
                       value="<%= vNic %>"
                       class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
                <p id="nicError" class="hidden text-xs text-red-600 mt-1.5"></p>
              </div>
              <div>
                <label for="gender" class="block text-sm font-medium text-clinic-900 mb-1.5">Gender <span class="text-clinic-700/40 font-normal">(optional)</span></label>
                <select id="gender" name="gender" data-custom-select>
                  <option value="" <%= vGender.isEmpty() ? "selected" : "" %>>None</option>
                  <option value="Male" <%= "Male".equals(vGender) ? "selected" : "" %>>Male</option>
                  <option value="Female" <%= "Female".equals(vGender) ? "selected" : "" %>>Female</option>
                  <option value="Other" <%= "Other".equals(vGender) ? "selected" : "" %>>Other</option>
                </select>
              </div>
            </div>

            <div class="mb-6">
              <label for="address" class="block text-sm font-medium text-clinic-900 mb-1.5">Address <span class="text-clinic-700/40 font-normal">(optional)</span></label>
              <input type="text" id="address" name="address" placeholder="e.g. Trincomalee"
                     value="<%= vAddress %>"
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
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
  <script src="assets/js/patient-form-validation.js"></script>
  <script>
    initPatientFormValidation('editPatientForm');

    <% if (request.getAttribute("error") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getAttribute("error")) %>', 'error');
    <% } %>
  </script>

</body>
</html>
