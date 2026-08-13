<%--
  Revenue stat cards + billed-appointments table + pagination. Split out from
  billing.jsp so BillingServlet can render just this fragment (no sidebar/
  header/toolbar) for the AJAX live-filter/pagination requests, while
  billing.jsp includes the same fragment for a normal full-page load. Reads
  request attributes set by BillingServlet: billingList, totalCount,
  totalPages, currentPage, pageSize, searchQuery, dateFrom, dateTo, totalRevenue.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%@ page import="java.util.List, java.util.Map, java.net.URLEncoder" %>
<%
  List<Map<String, String>> billingList = (List<Map<String, String>>) request.getAttribute("billingList");
  int totalCount = request.getAttribute("totalCount") != null ? (Integer) request.getAttribute("totalCount") : 0;
  int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
  int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
  int pageSize = request.getAttribute("pageSize") != null ? (Integer) request.getAttribute("pageSize") : 8;
  String searchQuery = request.getAttribute("searchQuery") != null ? (String) request.getAttribute("searchQuery") : "";
  String dateFrom = request.getAttribute("dateFrom") != null ? (String) request.getAttribute("dateFrom") : "";
  String dateTo = request.getAttribute("dateTo") != null ? (String) request.getAttribute("dateTo") : "";
  String totalRevenue = request.getAttribute("totalRevenue") != null ? (String) request.getAttribute("totalRevenue") : "0.00";
  String encodedQuery = URLEncoder.encode(searchQuery, "UTF-8");
  String pageQuery = "q=" + encodedQuery + "&dateFrom=" + URLEncoder.encode(dateFrom, "UTF-8") + "&dateTo=" + URLEncoder.encode(dateTo, "UTF-8");

  int rangeStart = billingList == null || billingList.isEmpty() ? 0 : (currentPage - 1) * pageSize + 1;
  int rangeEnd = billingList == null || billingList.isEmpty() ? 0 : rangeStart + billingList.size() - 1;
%>
<!-- Revenue summary for whatever's currently filtered -->
<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
  <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-5">
    <p class="text-xs text-clinic-700/50 mb-1">Total Revenue</p>
    <p class="font-display text-2xl text-clinic-900">Rs. <%= totalRevenue %></p>
  </div>
  <div class="bg-white rounded-2xl border border-clinic-100 shadow-sm p-5">
    <p class="text-xs text-clinic-700/50 mb-1">Billed Appointments</p>
    <p class="font-display text-2xl text-clinic-900"><%= totalCount %></p>
  </div>
</div>

<div class="bg-white rounded-2xl border border-clinic-100 shadow-sm overflow-hidden">
  <!-- Table -->
  <div class="overflow-x-auto px-6 pt-6">
    <table class="w-full text-sm">
      <thead>
        <tr class="text-left text-clinic-700/50 text-xs uppercase tracking-wide">
          <th class="py-3 pr-4 font-medium">Appt No.</th>
          <th class="py-3 pr-4 font-medium">Patient</th>
          <th class="py-3 pr-4 font-medium">Doctor</th>
          <th class="py-3 pr-4 font-medium">Appointment Date</th>
          <th class="py-3 pr-4 font-medium">Consultation Fee</th>
          <th class="py-3 pr-4 font-medium">Services</th>
          <th class="py-3 pr-4 font-medium">Total</th>
          <th class="py-3 pr-4 font-medium text-right">Actions</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-clinic-50">
        <% if (billingList != null) { for (Map<String, String> bill : billingList) {
             String id = bill.get("id");
             String services = bill.get("services");
        %>
        <tr class="hover:bg-clinic-50/60 transition-colors">
          <td class="py-3.5 pr-4 text-clinic-700/70 whitespace-nowrap"><%= bill.get("appointmentNumber") %></td>
          <td class="py-3.5 pr-4">
            <div class="font-medium text-clinic-900"><%= bill.get("patientName") %></div>
            <div class="text-clinic-700/50 text-xs"><%= bill.get("patientPhone") %></div>
          </td>
          <td class="py-3.5 pr-4 text-clinic-700/70">Dr. <%= bill.get("doctorName") %></td>
          <td class="py-3.5 pr-4 text-clinic-700/70 whitespace-nowrap"><%= bill.get("date") %></td>
          <td class="py-3.5 pr-4 text-clinic-700/60 whitespace-nowrap">Rs. <%= bill.get("consultationFee") %></td>
          <td class="py-3.5 pr-4 text-clinic-700/60 max-w-[12rem] truncate" title="<%= services == null || services.isEmpty() ? "None" : services %>">
            <%= services == null || services.isEmpty() ? "&mdash;" : services %>
          </td>
          <td class="py-3.5 pr-4 font-medium text-clinic-900 whitespace-nowrap">Rs. <%= bill.get("total") %></td>
          <td class="py-3.5 pr-4">
            <div class="flex items-center justify-end gap-1">
              <a href="appointmentReceipt?id=<%= id %>&from=billing" aria-label="Receipt" title="View/print receipt"
                 class="p-2 rounded-lg text-clinic-700/60 hover:bg-clinic-50 hover:text-clinic-900 transition-colors">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
                </svg>
              </a>
            </div>
          </td>
        </tr>
        <% } } %>
      </tbody>
    </table>

    <% if (billingList != null && billingList.isEmpty()) { %>
    <div class="py-14 text-center">
      <p class="text-clinic-700/60 text-sm">No billed appointments match your filters.</p>
    </div>
    <% } %>
  </div>

  <!-- Footer: count bottom-left, Prev/numbers/Next grouped bottom-right -->
  <div class="px-6 py-4 mt-3 border-t border-clinic-100 flex flex-wrap items-center justify-between gap-3">
    <p class="text-sm text-clinic-700/60">
      <% if (totalCount == 0) { %>
        No billed appointments found.
      <% } else { %>
        Showing <span class="font-medium text-clinic-900"><%= rangeStart %>&ndash;<%= rangeEnd %></span>
        of <span class="font-medium text-clinic-900"><%= totalCount %></span> appointment<%= totalCount == 1 ? "" : "s" %>
      <% } %>
    </p>

    <% if (totalCount > 0) { %>
    <div class="flex items-center gap-1">
      <a href="billing?<%= pageQuery %>&page=<%= Math.max(1, currentPage - 1) %>" data-page="<%= Math.max(1, currentPage - 1) %>"
         class="page-link inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors <%= currentPage <= 1 ? "text-clinic-700/30 pointer-events-none" : "text-clinic-700 hover:bg-clinic-50" %>">
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
        </svg>
        Prev
      </a>

      <% for (int p = 1; p <= totalPages; p++) { %>
        <a href="billing?<%= pageQuery %>&page=<%= p %>" data-page="<%= p %>"
           class="page-link w-8 h-8 flex items-center justify-center rounded-lg text-sm font-medium transition-colors <%= p == currentPage ? "bg-clinic-800 text-white" : "text-clinic-700/70 hover:bg-clinic-50" %>">
          <%= p %>
        </a>
      <% } %>

      <a href="billing?<%= pageQuery %>&page=<%= Math.min(totalPages, currentPage + 1) %>" data-page="<%= Math.min(totalPages, currentPage + 1) %>"
         class="page-link inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors <%= currentPage >= totalPages ? "text-clinic-700/30 pointer-events-none" : "text-clinic-700 hover:bg-clinic-50" %>">
        Next
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
        </svg>
      </a>
    </div>
    <% } %>
  </div>
</div>
