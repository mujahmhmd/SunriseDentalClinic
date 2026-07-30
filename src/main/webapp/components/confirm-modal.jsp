<%--
  Reusable confirmation modal. Include it anywhere a destructive/important
  action needs a "are you sure?" step, and trigger it from a button/link with:

    onclick="openConfirmModal('someModalId'); return false;"

  Usage:
    <jsp:include page="components/confirm-modal.jsp">
      <jsp:param name="id" value="logoutModal" />
      <jsp:param name="title" value="Log out?" />
      <jsp:param name="message" value="You'll need to sign in again to access the dashboard." />
      <jsp:param name="confirmText" value="Logout" />
      <jsp:param name="confirmHref" value="logout" />
      (cancelText is optional, defaults to "Cancel")
    </jsp:include>

  "id" must be unique on the page if more than one confirm-modal is included.
--%>
<%@ page buffer="64kb" %>
<%
  String modalId = request.getParameter("id");
  String title = request.getParameter("title");
  String message = request.getParameter("message");
  String confirmText = request.getParameter("confirmText");
  String confirmHref = request.getParameter("confirmHref");
  String cancelText = request.getParameter("cancelText");
  if (cancelText == null) cancelText = "Cancel";
%>
<div id="<%= modalId %>" class="confirm-modal hidden fixed inset-0 z-50 items-center justify-center bg-clinic-900/40 backdrop-blur-sm px-4">
  <div class="confirm-modal-card bg-white rounded-2xl shadow-xl max-w-xs w-full p-6 text-center transition-all duration-200 scale-95 opacity-0">
    <div class="w-11 h-11 mx-auto mb-4 rounded-full bg-coral-500/10 text-coral-500 flex items-center justify-center">
      <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z" />
      </svg>
    </div>
    <h3 class="font-display text-lg text-clinic-900 mb-1"><%= title %></h3>
    <p class="text-sm text-clinic-700/70 mb-5"><%= message %></p>
    <div class="flex gap-2.5">
      <button type="button" onclick="closeConfirmModal('<%= modalId %>')"
              class="flex-1 rounded-xl py-2.5 text-sm font-medium text-clinic-700 bg-clinic-50 hover:bg-clinic-100 transition-colors"><%= cancelText %></button>
      <button type="button" onclick="window.location.href='<%= confirmHref %>'"
              class="flex-1 rounded-xl py-2.5 text-sm font-medium text-white bg-coral-500 hover:bg-coral-400 transition-colors"><%= confirmText %></button>
    </div>
  </div>
</div>

<script>
  // Defined once even if this component is included more than once per page.
  if (typeof window.openConfirmModal !== 'function') {
    window.openConfirmModal = function (id) {
      var modal = document.getElementById(id);
      if (!modal) return;
      modal.classList.remove('hidden');
      modal.classList.add('flex');
      // Runs on the next frame so the "hidden -> visible" change registers
      // before the scale/opacity transition starts, otherwise it just snaps in.
      requestAnimationFrame(function () {
        modal.querySelector('.confirm-modal-card').classList.remove('scale-95', 'opacity-0');
      });
    };

    window.closeConfirmModal = function (id) {
      var modal = document.getElementById(id);
      if (!modal) return;
      modal.querySelector('.confirm-modal-card').classList.add('scale-95', 'opacity-0');
      setTimeout(function () {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
      }, 150);
    };
  }

  (function () {
    var modal = document.getElementById('<%= modalId %>');
    // Click on the dark backdrop (not the card itself) closes the modal.
    modal.addEventListener('click', function (e) {
      if (e.target === modal) closeConfirmModal('<%= modalId %>');
    });
  })();
</script>
