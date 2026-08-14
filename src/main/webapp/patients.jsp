<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String searchQuery = request.getAttribute("searchQuery") != null ? (String) request.getAttribute("searchQuery") : "";
  int initialPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
%>
<!DOCTYPE html>
<html lang="en" class="h-full overflow-hidden">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Patients - Sunrise Dental</title>
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
      <jsp:param name="title" value="Patients" />
    </jsp:include>

    <main class="flex-1 min-h-0 p-8">
      <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm overflow-hidden">

        <!-- Toolbar: search + create -->
        <div class="p-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-clinic-100">
          <div class="relative w-full sm:max-w-xs">
            <svg class="w-4 h-4 text-clinic-700/40 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
            </svg>
            <input type="text" id="patientSearch" value="<%= searchQuery %>" placeholder="Search by name, phone or NIC"
                   class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl pl-10 pr-3 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
          </div>

          <a href="create-patient.jsp"
             class="inline-flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl px-4 py-2.5 transition shadow-sm shrink-0">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Create Patient
          </a>
        </div>

        <!-- Replaced in place on search/pagination, no full page reload -->
        <div id="patientTableContainer">
          <jsp:include page="components/patient-table.jsp" />
        </div>
      </div>
    </main>
  </div>

  <jsp:include page="components/confirm-modal.jsp">
    <jsp:param name="id" value="deletePatientModal" />
    <jsp:param name="title" value="Remove this patient?" />
    <jsp:param name="message" value="This will permanently remove their record. This can't be undone." />
    <jsp:param name="confirmText" value="Delete" />
    <jsp:param name="confirmHref" value="#" />
  </jsp:include>

  <jsp:include page="components/toast.jsp" />

  <script>
    (function () {
      var searchInput = document.getElementById('patientSearch');
      var container = document.getElementById('patientTableContainer');
      var debounceTimer = null;
      var currentPage = <%= initialPage %>;

      function loadPatients(query, page, pushState) {
        var url = 'patients?q=' + encodeURIComponent(query) + '&page=' + page;
        fetch(url + '&ajax=1')
          .then(function (res) { return res.text(); })
          .then(function (html) {
            currentPage = page;
            container.innerHTML = html;
            if (pushState) {
              history.pushState({ q: query, page: page }, '', url);
            }
          });
      }

      // Filters as you type, debounced so it doesn't fire a request per keystroke.
      searchInput.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        var query = searchInput.value;
        debounceTimer = setTimeout(function () {
          loadPatients(query, 1, true);
        }, 300);
      });

      // Pagination links inside the fragment are re-rendered on every load,
      // so we delegate from the container instead of binding to each link.
      container.addEventListener('click', function (e) {
        var link = e.target.closest('.page-link');
        if (!link || link.classList.contains('pointer-events-none')) return;
        e.preventDefault();
        loadPatients(searchInput.value, link.dataset.page, true);
      });

      // Supports the browser back/forward buttons since we're pushing state above.
      window.addEventListener('popstate', function (e) {
        var state = e.state || { q: '', page: 1 };
        searchInput.value = state.q;
        loadPatients(state.q, state.page, false);
      });
    })();

    // Called from the Delete button rendered inside the patient table fragment.
    function confirmDeletePatient(id, name) {
      document.querySelector('#deletePatientModal p').textContent =
        'This will permanently remove ' + name + '’s record. This can’t be undone.';
      document.querySelector('#deletePatientModal button.bg-coral-500').onclick = function () {
        window.location.href = 'deletePatient?id=' + id;
      };
      openConfirmModal('deletePatientModal');
    }

    <% if (request.getParameter("success") != null) { %>
    showToast('<%= com.icbt.SunriseDentalClinic.util.JsUtil.escape(request.getParameter("success")) %>', 'success');
    history.replaceState(null, '', 'patients?q=<%= java.net.URLEncoder.encode(searchQuery, "UTF-8") %>&page=<%= initialPage %>');
    <% } %>
  </script>

</body>
</html>
