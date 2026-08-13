<%--
  Shared top bar for pages that already have a logged-in session (i.e. every
  page that also includes components/sidebar.jsp). Shows the page title on
  the left and the signed-in user's name/role/initial on the right.

  Usage:
    <jsp:include page="components/header.jsp">
      <jsp:param name="title" value="Staffs" />
    </jsp:include>
--%>
<%@ page buffer="64kb" %>
<%
  String pageTitle = request.getParameter("title");
%>
<header class="sticky top-0 z-10 shrink-0 h-20 px-8 flex items-center justify-between border-b border-clinic-100 bg-white/60 backdrop-blur">
  <h2 class="font-display text-xl text-clinic-900"><%= pageTitle %></h2>
  <div class="flex items-center gap-4">
    <a href="createAppointment"
       class="inline-flex items-center gap-2 bg-clinic-800 hover:bg-clinic-900 text-clinic-50 text-sm font-medium rounded-xl px-4 py-2.5 transition shadow-sm shrink-0">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
      </svg>
      Book Appointment
    </a>
    <div class="flex items-center gap-3">
      <div class="text-right">
        <p class="text-sm font-medium text-clinic-900"><%= session.getAttribute("name") %></p>
        <p class="text-xs text-clinic-700/60 capitalize"><%= session.getAttribute("role") %></p>
      </div>
      <div class="w-9 h-9 rounded-full bg-clinic-800 text-clinic-50 flex items-center justify-center text-sm font-medium">
        <%= String.valueOf(session.getAttribute("name")).trim().charAt(0) %>
      </div>
    </div>
  </div>
</header>
