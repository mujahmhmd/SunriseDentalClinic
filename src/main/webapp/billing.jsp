<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String searchQuery = request.getAttribute("searchQuery") != null ? (String) request.getAttribute("searchQuery") : "";
  String dateFrom = request.getAttribute("dateFrom") != null ? (String) request.getAttribute("dateFrom") : "";
  String dateTo = request.getAttribute("dateTo") != null ? (String) request.getAttribute("dateTo") : "";
  int initialPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
%>
<!DOCTYPE html>
<html lang="en" class="h-full overflow-hidden">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Billing - Sunrise Dental</title>
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
    <jsp:param name="active" value="billing" />
  </jsp:include>

  <div class="flex-1 flex flex-col min-w-0 min-h-0 h-screen overflow-y-auto">

    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Billing" />
    </jsp:include>

    <main class="flex-1 p-8">

      <!-- Toolbar: search + date range. Table below (including the revenue
           stat cards) is replaced in place on every filter change.
           No overflow-hidden here (unlike the combined toolbar+table cards
           elsewhere) — the date pickers' popup panels need to render outside
           this card's edge, and clipping it hides them. -->
      <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm mb-6">
        <div class="p-6 flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
          <div class="w-full lg:max-w-xs">
            <label class="block text-xs text-clinic-700/50 mb-1.5">Search</label>
            <div class="relative">
              <svg class="w-4 h-4 text-clinic-700/40 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
              </svg>
              <input type="text" id="billingSearch" value="<%= searchQuery %>" placeholder="Search by patient, doctor or appt no."
                     class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl pl-10 pr-3 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
            </div>
          </div>

          <div class="flex flex-wrap items-end gap-3">
            <div>
              <label for="billingDateFrom" class="block text-xs text-clinic-700/50 mb-1.5">From</label>
              <input type="date" id="billingDateFrom" data-custom-date value="<%= dateFrom %>"
                     class="w-40 border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
            </div>
            <div>
              <label for="billingDateTo" class="block text-xs text-clinic-700/50 mb-1.5">To</label>
              <input type="date" id="billingDateTo" data-custom-date value="<%= dateTo %>"
                     class="w-40 border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-clinic-900 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
            </div>
            <button type="button" id="billingClearFilters"
                    class="text-sm text-clinic-700/60 hover:text-clinic-900 underline underline-offset-2 pb-2.5">
              Clear
            </button>
          </div>
        </div>
      </div>

      <div id="billingContainer">
        <jsp:include page="components/billing-table.jsp" />
      </div>
    </main>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script src="assets/js/custom-date.js"></script>
  <script>
    (function () {
      var searchInput = document.getElementById('billingSearch');
      var dateFromInput = document.getElementById('billingDateFrom');
      var dateToInput = document.getElementById('billingDateTo');
      var clearBtn = document.getElementById('billingClearFilters');
      var container = document.getElementById('billingContainer');
      var debounceTimer = null;
      var currentPage = <%= initialPage %>;

      function loadBilling(page, pushState) {
        var params = 'q=' + encodeURIComponent(searchInput.value) +
          '&dateFrom=' + encodeURIComponent(dateFromInput.value) +
          '&dateTo=' + encodeURIComponent(dateToInput.value) +
          '&page=' + page;
        fetch('billing?' + params + '&ajax=1')
          .then(function (res) { return res.text(); })
          .then(function (html) {
            currentPage = page;
            container.innerHTML = html;
            if (pushState) {
              history.pushState({ page: page }, '', 'billing?' + params);
            }
          });
      }

      // Filters as you type/pick, debounced so it doesn't fire a request per keystroke.
      function debouncedReload() {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function () { loadBilling(1, true); }, 300);
      }

      searchInput.addEventListener('input', debouncedReload);
      // custom-date.js hides the real <input> and dispatches 'change' on it
      // once a date is picked — that's what these need to listen for.
      dateFromInput.addEventListener('change', debouncedReload);
      dateToInput.addEventListener('change', debouncedReload);

      // Keep the range valid in both directions: picking a From date
      // disables anything before it in the To picker, and picking a To
      // date disables anything after it in the From picker — so an
      // impossible range can't be selected in the first place.
      function syncDateRange() {
        if (dateFromInput.customDate) dateFromInput.customDate.setMax(dateToInput.value);
        if (dateToInput.customDate) dateToInput.customDate.setMin(dateFromInput.value);
      }
      dateFromInput.addEventListener('change', syncDateRange);
      dateToInput.addEventListener('change', syncDateRange);
      syncDateRange(); // apply immediately in case both are already filled in (e.g. after a page reload)

      // A plain page reload (rather than clearing the inputs in place) since
      // custom-date.js's visible trigger label is only ever updated by its
      // own calendar clicks — resetting input.value directly wouldn't be
      // reflected there, leaving a stale-looking date shown.
      clearBtn.addEventListener('click', function () {
        window.location.href = 'billing';
      });

      // Pagination links inside the fragment are re-rendered on every load,
      // so we delegate from the container instead of binding individually.
      container.addEventListener('click', function (e) {
        var link = e.target.closest('.page-link');
        if (link) {
          if (link.classList.contains('pointer-events-none')) return;
          e.preventDefault();
          loadBilling(link.dataset.page, true);
        }
      });

      // Supports the browser back/forward buttons since we're pushing state above.
      window.addEventListener('popstate', function () {
        loadBilling(currentPage, false);
      });
    })();
  </script>

</body>
</html>
