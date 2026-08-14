<%--
  Doctor count + table + pagination. Split out from doctors.jsp so DoctorServlet
  can render just this fragment (no sidebar/header/html shell) for the AJAX
  live-search/pagination requests, while doctors.jsp includes the same
  fragment for a normal full-page load. Reads request attributes set by
  DoctorServlet: doctorList, totalCount, totalPages, currentPage, pageSize,
  searchQuery.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" %>
<%@ page import="java.util.List, java.util.Map, java.net.URLEncoder" %>
<%
  List<Map<String, String>> doctorList = (List<Map<String, String>>) request.getAttribute("doctorList");
  int totalCount = request.getAttribute("totalCount") != null ? (Integer) request.getAttribute("totalCount") : 0;
  int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
  int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
  int pageSize = request.getAttribute("pageSize") != null ? (Integer) request.getAttribute("pageSize") : 8;
  String searchQuery = request.getAttribute("searchQuery") != null ? (String) request.getAttribute("searchQuery") : "";
  String encodedQuery = URLEncoder.encode(searchQuery, "UTF-8");
  // Doctors is staff-visible, but deleting a doctor record is admin-only
  // (RememberMeFilter enforces it server-side too) — just hide the button.
  boolean isAdmin = "admin".equals(session.getAttribute("role"));

  int rangeStart = doctorList == null || doctorList.isEmpty() ? 0 : (currentPage - 1) * pageSize + 1;
  int rangeEnd = doctorList == null || doctorList.isEmpty() ? 0 : rangeStart + doctorList.size() - 1;
%>
<!-- Table -->
<div class="overflow-x-auto px-6 pt-3">
  <table class="w-full text-sm">
    <thead>
      <tr class="text-left text-clinic-700/50 text-xs uppercase tracking-wide">
        <th class="py-3 pr-4 font-medium">Name</th>
        <th class="py-3 pr-4 font-medium">SLMC Reg No</th>
        <th class="py-3 pr-4 font-medium">Specializations</th>
        <th class="py-3 pr-4 font-medium">Phone</th>
        <th class="py-3 pr-4 font-medium">Status</th>
        <th class="py-3 pr-4 font-medium text-right">Actions</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-clinic-50">
      <% if (doctorList != null) { for (Map<String, String> doctor : doctorList) {
           String id = doctor.get("id");
           String specializations = doctor.get("specializations");
           boolean active = "active".equals(doctor.get("status"));
      %>
      <tr class="hover:bg-clinic-50/60 transition-colors">
        <td class="py-3.5 pr-4 font-medium text-clinic-900">Dr. <%= doctor.get("name") %></td>
        <td class="py-3.5 pr-4 text-clinic-700/70"><%= doctor.get("slmcRegNo") %></td>
        <td class="py-3.5 pr-4">
          <div class="flex flex-wrap gap-1.5 max-w-xs">
            <% if (specializations != null) { for (String tag : specializations.split(", ")) { %>
              <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-clinic-600/10 text-clinic-700"><%= tag %></span>
            <% } } %>
          </div>
        </td>
        <td class="py-3.5 pr-4 text-clinic-700/60"><%= doctor.get("phone") %></td>
        <td class="py-3.5 pr-4">
          <button type="button" class="status-toggle inline-flex items-center gap-2" data-id="<%= id %>">
            <span class="relative inline-flex h-5 w-9 items-center rounded-full transition-colors <%= active ? "bg-clinic-600" : "bg-clinic-900/15" %>">
              <span class="inline-block h-3.5 w-3.5 transform rounded-full bg-white shadow transition-transform <%= active ? "translate-x-[1.125rem]" : "translate-x-1" %>"></span>
            </span>
            <span class="text-xs font-medium <%= active ? "text-clinic-700" : "text-clinic-700/50" %>"><%= active ? "Active" : "Inactive" %></span>
          </button>
        </td>
        <td class="py-3.5 pr-4">
          <div class="flex items-center justify-end gap-1">
            <a href="editDoctor?id=<%= id %>" aria-label="Edit"
               class="p-2 rounded-lg text-clinic-700/60 hover:bg-clinic-50 hover:text-clinic-900 transition-colors">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
              </svg>
            </a>
            <% if (isAdmin) { %>
            <button type="button" aria-label="Delete" onclick="confirmDeleteDoctor('<%= id %>', '<%= doctor.get("name") %>')"
                    class="p-2 rounded-lg text-clinic-700/60 hover:bg-red-50 hover:text-red-600 transition-colors">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
              </svg>
            </button>
            <% } %>
          </div>
        </td>
      </tr>
      <% } } %>
    </tbody>
  </table>

  <% if (doctorList != null && doctorList.isEmpty()) { %>
  <div class="py-14 text-center">
    <p class="text-clinic-700/60 text-sm">No doctors match your search.</p>
  </div>
  <% } %>
</div>

<!-- Footer: count bottom-left, Prev/numbers/Next grouped bottom-right -->
<div class="px-6 py-4 border-t border-clinic-100 flex flex-wrap items-center justify-between gap-3">
  <p class="text-sm text-clinic-700/60">
    <% if (totalCount == 0) { %>
      No doctors found<%= searchQuery.isEmpty() ? "" : " for “" + searchQuery + "”" %>.
    <% } else { %>
      Showing <span class="font-medium text-clinic-900"><%= rangeStart %>&ndash;<%= rangeEnd %></span>
      of <span class="font-medium text-clinic-900"><%= totalCount %></span> doctor<%= totalCount == 1 ? "" : "s" %>
    <% } %>
  </p>

  <% if (totalCount > 0) { %>
  <div class="flex items-center gap-1">
    <a href="doctors?q=<%= encodedQuery %>&page=<%= Math.max(1, currentPage - 1) %>" data-page="<%= Math.max(1, currentPage - 1) %>"
       class="page-link inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors <%= currentPage <= 1 ? "text-clinic-700/30 pointer-events-none" : "text-clinic-700 hover:bg-clinic-50" %>">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
      </svg>
      Prev
    </a>

    <% for (int p = 1; p <= totalPages; p++) { %>
      <a href="doctors?q=<%= encodedQuery %>&page=<%= p %>" data-page="<%= p %>"
         class="page-link w-8 h-8 flex items-center justify-center rounded-lg text-sm font-medium transition-colors <%= p == currentPage ? "bg-clinic-800 text-white" : "text-clinic-700/70 hover:bg-clinic-50" %>">
        <%= p %>
      </a>
    <% } %>

    <a href="doctors?q=<%= encodedQuery %>&page=<%= Math.min(totalPages, currentPage + 1) %>" data-page="<%= Math.min(totalPages, currentPage + 1) %>"
       class="page-link inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors <%= currentPage >= totalPages ? "text-clinic-700/30 pointer-events-none" : "text-clinic-700 hover:bg-clinic-50" %>">
      Next
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
      </svg>
    </a>
  </div>
  <% } %>
</div>
