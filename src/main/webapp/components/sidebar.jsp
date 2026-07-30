<%--
  Shared dashboard sidebar. Include on any page like this:

    <jsp:include page="components/sidebar.jsp">
      <jsp:param name="active" value="dashboard" />
    </jsp:include>

  "active" should match one of the values checked below (dashboard, staffs,
  patients, appointments, reports, billing) so the matching nav item gets
  highlighted.
--%>
<%
  String activePage = request.getParameter("active");
  if (activePage == null) activePage = "";
%>
<style>
  /* Sidebar width lives here (not Tailwind classes) so the collapse can
     animate smoothly between two states with one transition rule. */
  /* z-index keeps the sidebar (and its toggle button) above the header, whose
     backdrop-blur otherwise creates a stacking context that paints on top. */
  .sidebar { position: relative; z-index: 20; width: 17rem; transition: width 0.25s cubic-bezier(0.4, 0, 0.2, 1); }
  .sidebar.collapsed { width: 5.25rem; }

  /* Labels shrink away instead of disappearing instantly, so the collapse
     reads as one motion rather than a layout jump. */
  .sidebar-label { max-width: 12rem; opacity: 1; overflow: hidden; white-space: nowrap; transition: max-width 0.2s ease, opacity 0.15s ease; }
  .sidebar.collapsed .sidebar-label { max-width: 0; opacity: 0; }

  /* gap: 0 removes the phantom space the flex "gap" would otherwise still
     reserve for the (now zero-width) label, which was pushing the icon
     off-center inside the hover/active box. */
  .sidebar.collapsed .nav-item { justify-content: center; gap: 0; }
  .sidebar.collapsed #sidebarToggleIcon { transform: rotate(180deg); }
  #sidebarToggleIcon { transition: transform 0.25s ease; }

  /* Active/hover indicator bar on the left edge of a nav item */
  .nav-item { position: relative; }
  .nav-item::before {
    content: '';
    position: absolute;
    left: -0.75rem;
    top: 50%;
    transform: translateY(-50%);
    width: 3px;
    height: 0;
    border-radius: 0 4px 4px 0;
    background: #E2745A;
    transition: height 0.2s ease;
  }
  .nav-item.active::before { height: 22px; }
</style>

<aside id="sidebar" class="sidebar relative flex flex-col shrink-0 bg-gradient-to-b from-clinic-900 to-clinic-800 text-clinic-50">

  <!-- Logo -->
  <div class="flex items-center gap-3 h-20 px-5 border-b border-white/10">
    <div class="shrink-0 w-10 h-10 rounded-xl bg-gradient-to-br from-clinic-600 to-clinic-800 ring-1 ring-white/10 flex items-center justify-center">
      <svg width="18" height="19" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M18.6667 0C20.1333 0 21.3889 0.522222 22.4333 1.56667C23.4778 2.61111 24 3.86667 24 5.33333C24 5.57778 23.9833 5.90556 23.95 6.31667C23.9167 6.72778 23.8667 7.2 23.8 7.73333L21.9667 21.1667C21.8556 22.0111 21.4722 22.7 20.8167 23.2333C20.1611 23.7667 19.4111 24.0333 18.5667 24.0333C18.0556 24.0333 17.5833 23.9222 17.15 23.7C16.7167 23.4778 16.3556 23.1667 16.0667 22.7667L12.5 17.5667C12.4556 17.4778 12.3833 17.4167 12.2833 17.3833C12.1833 17.35 12.0778 17.3333 11.9667 17.3333C11.8778 17.3333 11.7 17.4333 11.4333 17.6333L7.96667 22.6667C7.65556 23.1111 7.27222 23.45 6.81667 23.6833C6.36111 23.9167 5.87778 24.0333 5.36667 24.0333C4.52222 24.0333 3.77778 23.7611 3.13333 23.2167C2.48889 22.6722 2.11111 21.9778 2 21.1333L0.2 7.73333C0.133333 7.2 0.0833333 6.72778 0.05 6.31667C0.0166667 5.90556 0 5.57778 0 5.33333C0 3.86667 0.522222 2.61111 1.56667 1.56667C2.61111 0.522222 3.86667 0 5.33333 0C6.13333 0 6.77222 0.105556 7.25 0.316667C7.72778 0.527778 8.18889 0.755556 8.63333 1C9.07778 1.24444 9.55 1.47222 10.05 1.68333C10.55 1.89444 11.2 2 12 2C12.8 2 13.45 1.89444 13.95 1.68333C14.45 1.47222 14.9222 1.24444 15.3667 1C15.8111 0.755556 16.2778 0.527778 16.7667 0.316667C17.2556 0.105556 17.8889 0 18.6667 0ZM18.6667 2.66667C18.1556 2.66667 17.7056 2.77222 17.3167 2.98333C16.9278 3.19444 16.5 3.42222 16.0333 3.66667C15.5667 3.91111 15.0222 4.13889 14.4 4.35C13.7778 4.56111 12.9778 4.66667 12 4.66667C11.0222 4.66667 10.2222 4.56111 9.6 4.35C8.97778 4.13889 8.43333 3.91111 7.96667 3.66667C7.5 3.42222 7.07222 3.19444 6.68333 2.98333C6.29444 2.77222 5.84444 2.66667 5.33333 2.66667C4.6 2.66667 3.97222 2.92778 3.45 3.45C2.92778 3.97222 2.66667 4.6 2.66667 5.33333C2.66667 5.51111 2.67778 5.76667 2.7 6.1C2.72222 6.43333 2.76667 6.82222 2.83333 7.26667L4.66667 20.7667C4.68889 20.9444 4.76667 21.0833 4.9 21.1833C5.03333 21.2833 5.18889 21.3333 5.36667 21.3333C5.47778 21.3333 5.57778 21.3111 5.66667 21.2667C5.75556 21.2222 5.82222 21.1556 5.86667 21.0667L9.23333 16.1333C9.54444 15.6889 9.94444 15.3333 10.4333 15.0667C10.9222 14.8 11.4444 14.6667 12 14.6667C12.5556 14.6667 13.0778 14.8 13.5667 15.0667C14.0556 15.3333 14.4556 15.6889 14.7667 16.1333L18.2 21.1667C18.2444 21.2333 18.3 21.2833 18.3667 21.3167C18.4333 21.35 18.5111 21.3667 18.6 21.3667C18.7778 21.3667 18.9389 21.3167 19.0833 21.2167C19.2278 21.1167 19.3111 20.9778 19.3333 20.8L21.1667 7.26667C21.2333 6.82222 21.2778 6.43333 21.3 6.1C21.3222 5.76667 21.3333 5.51111 21.3333 5.33333C21.3333 4.6 21.0722 3.97222 20.55 3.45C20.0278 2.92778 19.4 2.66667 18.6667 2.66667Z" fill="white"/>
      </svg>
    </div>
    <%
      // "Admin Portal" / "Staff Portal" depending on who's logged in.
      String userRole = String.valueOf(session.getAttribute("role"));
      String roleLabel = userRole.isEmpty() ? "" : Character.toUpperCase(userRole.charAt(0)) + userRole.substring(1);
    %>
    <div class="sidebar-label">
      <p class="font-display text-base leading-tight">Sunrise Dental Clinic</p>
      <p class="text-[11px] text-clinic-50/50 tracking-wide"><%= roleLabel %> Portal</p>
    </div>
  </div>

  <!-- Collapse/expand toggle -->
  <button id="sidebarToggle" aria-label="Toggle sidebar"
          class="absolute -right-3 top-[4.25rem] w-6 h-6 rounded-full bg-clinic-50 text-clinic-800 shadow-md ring-1 ring-black/5 flex items-center justify-center hover:bg-coral-500 hover:text-white transition-colors">
    <svg id="sidebarToggleIcon" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
      <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
    </svg>
  </button>

  <!-- Nav -->
  <nav class="flex-1 px-3.5 py-6 space-y-1 overflow-y-auto overflow-x-hidden">

    <a href="dashboard.jsp" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors <%= "dashboard".equals(activePage) ? "active bg-white/10 text-white" : "text-clinic-50/65 hover:bg-white/5 hover:text-white" %>">
      <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 0 1 6 3.75h2.25A2.25 2.25 0 0 1 10.5 6v2.25a2.25 2.25 0 0 1-2.25 2.25H6a2.25 2.25 0 0 1-2.25-2.25V6ZM3.75 15.75A2.25 2.25 0 0 1 6 13.5h2.25a2.25 2.25 0 0 1 2.25 2.25V18a2.25 2.25 0 0 1-2.25 2.25H6A2.25 2.25 0 0 1 3.75 18v-2.25ZM13.5 6a2.25 2.25 0 0 1 2.25-2.25H18A2.25 2.25 0 0 1 20.25 6v2.25A2.25 2.25 0 0 1 18 10.5h-2.25a2.25 2.25 0 0 1-2.25-2.25V6ZM13.5 15.75a2.25 2.25 0 0 1 2.25-2.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-2.25A2.25 2.25 0 0 1 13.5 18v-2.25Z" />
      </svg>
      <span class="sidebar-label">Dashboard</span>
    </a>

    <a href="#" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors <%= "staffs".equals(activePage) ? "active bg-white/10 text-white" : "text-clinic-50/65 hover:bg-white/5 hover:text-white" %>">
      <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M18 18.72a9.094 9.094 0 0 0 3.741-.479 3 3 0 0 0-4.682-2.72m.94 3.198.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0 1 12 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 0 1 6 18.719m12 0a5.971 5.971 0 0 0-.941-3.197m0 0A5.995 5.995 0 0 0 12 12.75a5.995 5.995 0 0 0-5.058 2.772m0 0a3 3 0 0 0-4.681 2.72 8.986 8.986 0 0 0 3.74.477m.94-3.197a5.971 5.971 0 0 0-.94 3.197M15 6.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm6 3a2.25 2.25 0 1 1-4.5 0 2.25 2.25 0 0 1 4.5 0Zm-13.5 0a2.25 2.25 0 1 1-4.5 0 2.25 2.25 0 0 1 4.5 0Z" />
      </svg>
      <span class="sidebar-label">Staffs</span>
    </a>

    <a href="#" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors <%= "patients".equals(activePage) ? "active bg-white/10 text-white" : "text-clinic-50/65 hover:bg-white/5 hover:text-white" %>">
      <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
      </svg>
      <span class="sidebar-label">Patients</span>
    </a>

    <a href="#" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors <%= "appointments".equals(activePage) ? "active bg-white/10 text-white" : "text-clinic-50/65 hover:bg-white/5 hover:text-white" %>">
      <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
      </svg>
      <span class="sidebar-label">Appointments</span>
    </a>

    <a href="#" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors <%= "reports".equals(activePage) ? "active bg-white/10 text-white" : "text-clinic-50/65 hover:bg-white/5 hover:text-white" %>">
      <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z" />
      </svg>
      <span class="sidebar-label">Reports</span>
    </a>

    <a href="#" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors <%= "billing".equals(activePage) ? "active bg-white/10 text-white" : "text-clinic-50/65 hover:bg-white/5 hover:text-white" %>">
      <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z" />
      </svg>
      <span class="sidebar-label">Billing</span>
    </a>
  </nav>

  <!-- Logout, pinned to the bottom and visually separated -->
  <div class="px-3.5 py-4 border-t border-white/10">
    <a href="logout" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-clinic-50/65 hover:bg-coral-500/15 hover:text-coral-300 transition-colors">
      <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3H21" />
      </svg>
      <span class="sidebar-label">Logout</span>
    </a>
  </div>
</aside>

<script>
  // Sidebar collapse state is remembered across visits via localStorage,
  // so navigating between pages doesn't reset it back to expanded.
  (function () {
    var sidebar = document.getElementById('sidebar');
    var toggleBtn = document.getElementById('sidebarToggle');
    var COLLAPSE_KEY = 'sunrise-sidebar-collapsed';

    function setCollapsed(collapsed) {
      sidebar.classList.toggle('collapsed', collapsed);
      localStorage.setItem(COLLAPSE_KEY, collapsed);
    }

    toggleBtn.addEventListener('click', function () {
      setCollapsed(!sidebar.classList.contains('collapsed'));
    });

    setCollapsed(localStorage.getItem(COLLAPSE_KEY) === 'true');
  })();
</script>
