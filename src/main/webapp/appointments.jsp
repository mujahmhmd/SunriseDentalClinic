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
  <title>Appointments - Sunrise Dental</title>
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
      <jsp:param name="title" value="Appointments" />
    </jsp:include>

    <main class="flex-1 p-8">
      <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm overflow-hidden">

        <!-- Toolbar: search + create -->
        <div class="p-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-clinic-100">
          <div class="relative w-full sm:max-w-xs">
            <svg class="w-4 h-4 text-clinic-700/40 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
            </svg>
            <input type="text" id="appointmentSearch" value="<%= searchQuery %>" placeholder="Search by patient or doctor name"
                   class="w-full border border-clinic-100 bg-clinic-50/50 rounded-xl pl-10 pr-3 py-2.5 text-sm text-clinic-900 placeholder:text-clinic-700/30 focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition">
          </div>

          <a href="createAppointment"
             class="inline-flex items-center justify-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl px-4 py-2.5 transition shadow-sm shrink-0">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Book Appointment
          </a>
        </div>

        <!-- Replaced in place on search/pagination, no full page reload -->
        <div id="appointmentTableContainer">
          <jsp:include page="components/appointment-table.jsp" />
        </div>
      </div>
    </main>
  </div>

  <jsp:include page="components/confirm-modal.jsp">
    <jsp:param name="id" value="deleteAppointmentModal" />
    <jsp:param name="title" value="Remove this appointment?" />
    <jsp:param name="message" value="This will permanently remove it. This can't be undone." />
    <jsp:param name="confirmText" value="Delete" />
    <jsp:param name="confirmHref" value="#" />
  </jsp:include>

  <jsp:include page="components/confirm-modal.jsp">
    <jsp:param name="id" value="cancelAppointmentModal" />
    <jsp:param name="title" value="Cancel this appointment?" />
    <jsp:param name="message" value="The patient will need to be rebooked separately. This can't be undone." />
    <jsp:param name="confirmText" value="Cancel Appointment" />
    <jsp:param name="confirmHref" value="#" />
  </jsp:include>

  <jsp:include page="components/confirm-modal.jsp">
    <jsp:param name="id" value="reopenAppointmentModal" />
    <jsp:param name="title" value="Reopen this appointment?" />
    <jsp:param name="message" value="It goes back to Scheduled. Any billed services and the total charged will be cleared - you'll need to confirm payment again if you re-complete it." />
    <jsp:param name="confirmText" value="Reopen" />
    <jsp:param name="confirmHref" value="#" />
  </jsp:include>

  <!--
    Complete & Bill popup. Not the generic confirm-modal.jsp since this needs
    real content (service checkboxes + a running total), not just a yes/no
    prompt. Opening it (openAppointmentPayment, wired up by
    appointment-payment.js) moves the appointment to Processing Payment;
    "Confirm Payment" is a real form submit to confirmAppointmentPayment
    (marks it Completed and redirects to the billed receipt); Cancel/Escape/
    backdrop-click revert it back to Scheduled instead of leaving it stuck.
  -->
  <div id="paymentModal" class="hidden fixed inset-0 z-50 items-center justify-center bg-clinic-900/40 backdrop-blur-sm px-4">
    <div class="payment-modal-card bg-white rounded-2xl shadow-xl max-w-md w-full p-6 transition-all duration-200 scale-95 opacity-0">
      <h3 class="font-display text-lg text-clinic-900 mb-1">Complete &amp; Bill Appointment</h3>
      <p class="text-sm text-clinic-700/70 mb-4">Tick any treatments performed, then confirm payment.</p>

      <form id="paymentForm" action="confirmAppointmentPayment" method="post">
        <input type="hidden" name="id" id="paymentAppointmentId">

        <div class="flex items-center justify-between text-sm py-2 border-b border-clinic-100">
          <span class="text-clinic-700">Consultation Fee</span>
          <span id="paymentConsultationFee" class="font-medium text-clinic-900">Rs. 0.00</span>
        </div>

        <div id="paymentServicesList" class="max-h-56 overflow-y-auto divide-y divide-clinic-50"></div>

        <div class="flex items-center justify-between text-sm pt-3 mt-1 border-t border-clinic-100 font-medium">
          <span class="text-clinic-900">Total</span>
          <span id="paymentTotal" class="text-clinic-900">Rs. 0.00</span>
        </div>

        <div class="flex gap-2.5 mt-5">
          <button type="button" id="paymentCancelBtn"
                  class="flex-1 rounded-xl py-2.5 text-sm font-medium text-clinic-700 bg-clinic-50 hover:bg-clinic-100 transition-colors">Cancel</button>
          <button type="submit"
                  class="flex-1 rounded-xl py-2.5 text-sm font-medium text-white bg-clinic-800 hover:bg-clinic-900 transition-colors">Confirm Payment</button>
        </div>
      </form>
    </div>
  </div>

  <jsp:include page="components/toast.jsp" />

  <script src="assets/js/appointment-payment.js"></script>
  <script>
    (function () {
      var searchInput = document.getElementById('appointmentSearch');
      var container = document.getElementById('appointmentTableContainer');
      var debounceTimer = null;
      var currentPage = <%= initialPage %>;

      function loadAppointments(query, page, pushState) {
        var url = 'appointments?q=' + encodeURIComponent(query) + '&page=' + page;
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
          loadAppointments(query, 1, true);
        }, 300);
      });

      // Pagination links and status actions inside the fragment are
      // re-rendered on every load, so we delegate from the container
      // instead of binding to each one individually.
      container.addEventListener('click', function (e) {
        var link = e.target.closest('.page-link');
        if (link) {
          if (link.classList.contains('pointer-events-none')) return;
          e.preventDefault();
          loadAppointments(searchInput.value, link.dataset.page, true);
          return;
        }

        var complete = e.target.closest('.complete-appointment');
        if (complete) {
          openAppointmentPayment(complete.dataset.id);
          return;
        }

        var cancel = e.target.closest('.cancel-appointment');
        if (cancel) {
          document.querySelector('#cancelAppointmentModal button.bg-coral-500').onclick = function () {
            fetch('cancelAppointment?id=' + cancel.dataset.id, { method: 'POST' })
              .then(function () {
                loadAppointments(searchInput.value, currentPage, false);
                showToast('Appointment cancelled', 'success');
              });
            closeConfirmModal('cancelAppointmentModal');
          };
          openConfirmModal('cancelAppointmentModal');
          return;
        }

        var reopen = e.target.closest('.reopen-appointment');
        if (reopen) {
          document.querySelector('#reopenAppointmentModal button.bg-coral-500').onclick = function () {
            fetch('reopenAppointment?id=' + reopen.dataset.id, { method: 'POST' })
              .then(function () {
                loadAppointments(searchInput.value, currentPage, false);
                showToast('Appointment reopened', 'success');
              });
            closeConfirmModal('reopenAppointmentModal');
          };
          openConfirmModal('reopenAppointmentModal');
        }
      });

      // Supports the browser back/forward buttons since we're pushing state above.
      window.addEventListener('popstate', function (e) {
        var state = e.state || { q: '', page: 1 };
        searchInput.value = state.q;
        loadAppointments(state.q, state.page, false);
      });

      initAppointmentPayment({
        modalId: 'paymentModal',
        idInputId: 'paymentAppointmentId',
        feeElId: 'paymentConsultationFee',
        servicesListId: 'paymentServicesList',
        totalElId: 'paymentTotal',
        cancelBtnId: 'paymentCancelBtn',
        // Cancelling the popup reverts the appointment to Scheduled server-side —
        // refresh the table so that shows up instead of the stale "Processing Payment" row.
        onCancelled: function () { loadAppointments(searchInput.value, currentPage, false); }
      });
    })();

    // Called from the Delete button rendered inside the appointment table fragment.
    function confirmDeleteAppointment(id) {
      document.querySelector('#deleteAppointmentModal button.bg-coral-500').onclick = function () {
        window.location.href = 'deleteAppointment?id=' + id;
      };
      openConfirmModal('deleteAppointmentModal');
    }

    <% if (request.getParameter("success") != null) { %>
    showToast('<%= request.getParameter("success") %>', 'success');
    history.replaceState(null, '', 'appointments?q=<%= java.net.URLEncoder.encode(searchQuery, "UTF-8") %>&page=<%= initialPage %>');
    <% } %>
  </script>

</body>
</html>
