<%--
  Appointment count + table + pagination. Split out from appointments.jsp so
  AppointmentServlet can render just this fragment (no sidebar/header/html
  shell) for the AJAX live-search/pagination requests, while appointments.jsp
  includes the same fragment for a normal full-page load. Reads request
  attributes set by AppointmentServlet: appointmentList, totalCount,
  totalPages, currentPage, pageSize, searchQuery.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%@ page import="java.util.List, java.util.Map, java.net.URLEncoder" %>
<%
  List<Map<String, String>> appointmentList = (List<Map<String, String>>) request.getAttribute("appointmentList");
  int totalCount = request.getAttribute("totalCount") != null ? (Integer) request.getAttribute("totalCount") : 0;
  int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
  int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
  int pageSize = request.getAttribute("pageSize") != null ? (Integer) request.getAttribute("pageSize") : 8;
  String searchQuery = request.getAttribute("searchQuery") != null ? (String) request.getAttribute("searchQuery") : "";
  String encodedQuery = URLEncoder.encode(searchQuery, "UTF-8");

  int rangeStart = appointmentList == null || appointmentList.isEmpty() ? 0 : (currentPage - 1) * pageSize + 1;
  int rangeEnd = appointmentList == null || appointmentList.isEmpty() ? 0 : rangeStart + appointmentList.size() - 1;
%>
<!-- Table -->
<div class="overflow-x-auto px-6 pt-3">
  <table class="w-full text-sm">
    <thead>
      <tr class="text-left text-clinic-700/50 text-xs uppercase tracking-wide">
        <th class="py-3 pr-4 font-medium">Appt No.</th>
        <th class="py-3 pr-4 font-medium">Patient</th>
        <th class="py-3 pr-4 font-medium">Doctor</th>
        <th class="py-3 pr-4 font-medium">Date &amp; Time</th>
        <th class="py-3 pr-4 font-medium">Reason</th>
        <th class="py-3 pr-4 font-medium">Status</th>
        <th class="py-3 pr-4 font-medium text-right">Actions</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-clinic-50">
      <% if (appointmentList != null) { for (Map<String, String> appt : appointmentList) {
           String id = appt.get("id");
           String status = appt.get("status");
           boolean scheduled = "Scheduled".equals(status);
           boolean processingPayment = "Processing Payment".equals(status);
           String badgeClass;
           if ("Completed".equals(status)) badgeClass = "bg-clinic-600/10 text-clinic-700";
           else if ("Cancelled".equals(status)) badgeClass = "bg-red-50 text-red-600";
           else if ("Processing Payment".equals(status)) badgeClass = "bg-amber-50 text-amber-600";
           else badgeClass = "bg-coral-500/10 text-coral-500";
      %>
      <tr class="hover:bg-clinic-50/60 transition-colors">
        <td class="py-3.5 pr-4 text-clinic-700/70 whitespace-nowrap"><%= appt.get("appointmentNumber") %></td>
        <td class="py-3.5 pr-4">
          <div class="font-medium text-clinic-900"><%= appt.get("patientName") %></div>
          <div class="text-clinic-700/50 text-xs"><%= appt.get("patientPhone") %></div>
        </td>
        <td class="py-3.5 pr-4 text-clinic-700/70">Dr. <%= appt.get("doctorName") %></td>
        <td class="py-3.5 pr-4 text-clinic-700/70 whitespace-nowrap">
          <%= appt.get("date") %><br><span class="text-xs text-clinic-700/50"><%= appt.get("time") %></span>
        </td>
        <td class="py-3.5 pr-4 text-clinic-700/60 max-w-[12rem] truncate"><%= appt.get("reason") %></td>
        <td class="py-3.5 pr-4">
          <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium <%= badgeClass %>"><%= status %></span>
        </td>
        <td class="py-3.5 pr-4">
          <div class="flex items-center justify-end gap-1">
            <a href="appointmentReceipt?id=<%= id %>" aria-label="Receipt" title="View/print receipt"
               class="p-2 rounded-lg text-clinic-700/60 hover:bg-clinic-50 hover:text-clinic-900 transition-colors">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
              </svg>
            </a>
            <% if (scheduled || processingPayment) { %>
            <button type="button" class="complete-appointment p-2 rounded-lg text-clinic-700/60 hover:bg-clinic-600/10 hover:text-clinic-700 transition-colors" data-id="<%= id %>" aria-label="<%= processingPayment ? "Resume payment" : "Complete & bill" %>" title="<%= processingPayment ? "Resume payment" : "Complete & bill" %>">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
              </svg>
            </button>
            <% } %>
            <% if (scheduled) { %>
            <button type="button" class="cancel-appointment p-2 rounded-lg text-clinic-700/60 hover:bg-red-50 hover:text-red-600 transition-colors" data-id="<%= id %>" aria-label="Cancel appointment" title="Cancel appointment">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
              </svg>
            </button>
            <% } %>
            <a href="editAppointment?id=<%= id %>" aria-label="Edit" title="Edit"
               class="p-2 rounded-lg text-clinic-700/60 hover:bg-clinic-50 hover:text-clinic-900 transition-colors">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
              </svg>
            </a>
            <button type="button" aria-label="Delete" title="Delete" onclick="confirmDeleteAppointment('<%= id %>')"
                    class="p-2 rounded-lg text-clinic-700/60 hover:bg-red-50 hover:text-red-600 transition-colors">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
              </svg>
            </button>
          </div>
        </td>
      </tr>
      <% } } %>
    </tbody>
  </table>

  <% if (appointmentList != null && appointmentList.isEmpty()) { %>
  <div class="py-14 text-center">
    <p class="text-clinic-700/60 text-sm">No appointments match your search.</p>
  </div>
  <% } %>
</div>

<!-- Footer: count bottom-left, Prev/numbers/Next grouped bottom-right -->
<div class="px-6 py-4 border-t border-clinic-100 flex flex-wrap items-center justify-between gap-3">
  <p class="text-sm text-clinic-700/60">
    <% if (totalCount == 0) { %>
      No appointments found<%= searchQuery.isEmpty() ? "" : " for “" + searchQuery + "”" %>.
    <% } else { %>
      Showing <span class="font-medium text-clinic-900"><%= rangeStart %>&ndash;<%= rangeEnd %></span>
      of <span class="font-medium text-clinic-900"><%= totalCount %></span> appointment<%= totalCount == 1 ? "" : "s" %>
    <% } %>
  </p>

  <% if (totalCount > 0) { %>
  <div class="flex items-center gap-1">
    <a href="appointments?q=<%= encodedQuery %>&page=<%= Math.max(1, currentPage - 1) %>" data-page="<%= Math.max(1, currentPage - 1) %>"
       class="page-link inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors <%= currentPage <= 1 ? "text-clinic-700/30 pointer-events-none" : "text-clinic-700 hover:bg-clinic-50" %>">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
      </svg>
      Prev
    </a>

    <% for (int p = 1; p <= totalPages; p++) { %>
      <a href="appointments?q=<%= encodedQuery %>&page=<%= p %>" data-page="<%= p %>"
         class="page-link w-8 h-8 flex items-center justify-center rounded-lg text-sm font-medium transition-colors <%= p == currentPage ? "bg-clinic-800 text-white" : "text-clinic-700/70 hover:bg-clinic-50" %>">
        <%= p %>
      </a>
    <% } %>

    <a href="appointments?q=<%= encodedQuery %>&page=<%= Math.min(totalPages, currentPage + 1) %>" data-page="<%= Math.min(totalPages, currentPage + 1) %>"
       class="page-link inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors <%= currentPage >= totalPages ? "text-clinic-700/30 pointer-events-none" : "text-clinic-700 hover:bg-clinic-50" %>">
      Next
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
      </svg>
    </a>
  </div>
  <% } %>
</div>
