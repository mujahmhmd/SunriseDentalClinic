<%--
  Reusable toast notifications, top-right, auto-dismiss after 3s (or close
  manually with the X). Include once per page:

    <jsp:include page="components/toast.jsp" />

  Then anywhere in that page's JS:
    showToast('Staff account created', 'success');
    showToast('That username is already taken.', 'error');
--%>
<div id="toastContainer" class="fixed top-5 right-5 z-[100] flex flex-col gap-2 pointer-events-none"></div>

<script>
  if (typeof window.showToast !== 'function') {
    window.showToast = function (message, type) {
      type = type || 'success';
      var container = document.getElementById('toastContainer');

      var toast = document.createElement('div');
      toast.className = 'pointer-events-auto flex items-center gap-3 bg-white rounded-xl shadow-lg border border-clinic-100 px-4 py-3 min-w-[260px] max-w-sm transition-all duration-300 translate-x-[120%] opacity-0';

      var isError = type === 'error';
      var iconWrapClass = isError ? 'bg-red-50 text-red-500' : 'bg-clinic-600/10 text-clinic-600';
      var iconPath = isError
        ? 'M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z'
        : 'M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z';

      toast.innerHTML =
        '<span class="shrink-0 w-8 h-8 rounded-full flex items-center justify-center ' + iconWrapClass + '">' +
          '<svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="' + iconPath + '"/></svg>' +
        '</span>' +
        '<p class="flex-1 text-sm text-clinic-900">' + message + '</p>' +
        '<button type="button" aria-label="Close" class="shrink-0 text-clinic-700/40 hover:text-clinic-700">' +
          '<svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12"/></svg>' +
        '</button>';

      container.appendChild(toast);

      var dismissTimer = setTimeout(dismiss, 3000);

      function dismiss() {
        clearTimeout(dismissTimer);
        toast.classList.add('translate-x-[120%]', 'opacity-0');
        setTimeout(function () { toast.remove(); }, 300);
      }

      toast.querySelector('button').addEventListener('click', dismiss);

      // Two frames so the initial "off-screen" state paints before removing
      // it, otherwise the browser collapses straight to the end state with no visible slide-in.
      requestAnimationFrame(function () {
        requestAnimationFrame(function () {
          toast.classList.remove('translate-x-[120%]', 'opacity-0');
        });
      });
    };
  }
</script>
