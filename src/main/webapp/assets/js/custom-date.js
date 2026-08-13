// Reusable date picker. Progressively enhances any
// <input type="date" data-custom-date> into a styled calendar dropdown
// matching the app's design (the native date input's calendar popup can't
// be restyled with CSS at all — it's OS/browser chrome — so this replaces
// just the visible parts while leaving the real <input> in the DOM, hidden,
// so form submission and any existing 'change' listeners keep working
// unchanged).
//
// Usage: add data-custom-date to any <input type="date">, include this
// script once. No per-instance JS wiring needed. Respects min/max
// attributes on the input if present (dates outside that range are
// disabled in the grid, same as a native date input would do).
//
// Click the "Month Year" header label to zoom out to a month grid for that
// year, and the year in that view to zoom out further to a 12-year grid —
// lets you jump decades in a couple of clicks instead of hammering
// prev/next-month (useful for e.g. a date of birth far in the past).
//
// Keyboard support, following the standard WAI-ARIA date-picker grid pattern:
//   ArrowLeft/ArrowRight - previous/next day
//   ArrowUp/ArrowDown    - previous/next week
//   Home/End              - start/end of the current week
//   PageUp/PageDown       - previous/next month
//   Shift+PageUp/PageDown - previous/next year
//   Enter/Space            - choose the focused day
//   Escape                 - close without changing the value
// (the month/year zoom-out grids are plain tabbable buttons — Tab + native
// Enter/Space activation, no dedicated arrow-key scheme)
(function () {
  var MONTH_NAMES = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'];
  var WEEKDAY_LABELS = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  // Local-time formatting throughout (never toISOString/`new Date(str)`
  // directly — both go through UTC and can land on the wrong day depending
  // on the browser's timezone).
  function toIso(date) {
    return date.getFullYear() + '-' + pad(date.getMonth() + 1) + '-' + pad(date.getDate());
  }

  function parseIso(value) {
    if (!value) return null;
    var parts = value.split('-');
    if (parts.length !== 3) return null;
    return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  }

  function sameDay(a, b) {
    return !!a && !!b && a.getFullYear() === b.getFullYear()
      && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
  }

  function formatDisplay(date) {
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }

  function enhance(input) {
    if (input.dataset.enhanced) return;
    input.dataset.enhanced = 'true';

    var minDate = parseIso(input.min);
    var maxDate = parseIso(input.max);

    var wrapper = document.createElement('div');
    wrapper.className = 'relative';
    input.parentNode.insertBefore(wrapper, input);
    wrapper.appendChild(input);
    input.classList.add('hidden');

    var triggerId = input.id ? input.id + '-trigger' : '';
    var trigger = document.createElement('button');
    trigger.type = 'button';
    if (triggerId) trigger.id = triggerId;
    trigger.className = 'w-full flex items-center gap-2.5 border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-left focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition';
    trigger.setAttribute('aria-haspopup', 'dialog');
    trigger.setAttribute('aria-expanded', 'false');
    trigger.innerHTML =
      '<svg class="w-4 h-4 text-clinic-700/40 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">' +
      '<path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" /></svg>' +
      '<span class="truncate"></span>';
    wrapper.appendChild(trigger);

    // Clicking the field's <label> should focus our trigger, not the now-hidden input.
    if (input.id) {
      var label = document.querySelector('label[for="' + input.id + '"]');
      if (label) label.setAttribute('for', triggerId);
    }

    var labelSpan = trigger.querySelector('span');

    var panel = document.createElement('div');
    panel.setAttribute('role', 'dialog');
    panel.className = 'hidden absolute z-20 mt-1.5 w-72 bg-white border border-clinic-100 rounded-xl shadow-lg p-3';
    wrapper.appendChild(panel);

    var selected = parseIso(input.value);
    var focused = selected || new Date();
    var view = 'days'; // 'days' | 'months' | 'years' — header label zooms out a level at a time
    var grid; // populated by render()
    var CHEVRON_LEFT = '<svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" /></svg>';
    var CHEVRON_RIGHT = '<svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" /></svg>';
    var NAV_BTN_CLASS = 'p-1.5 rounded-lg text-clinic-700/60 hover:bg-clinic-50 hover:text-clinic-900 transition-colors';

    function isDisabled(date) {
      return (minDate && date < minDate) || (maxDate && date > maxDate);
    }

    function syncLabel() {
      labelSpan.textContent = selected ? formatDisplay(selected) : 'Select date';
      labelSpan.classList.toggle('text-clinic-700/40', !selected);
      labelSpan.classList.toggle('text-clinic-900', !!selected);
    }

    function render() {
      if (view === 'months') renderMonths();
      else if (view === 'years') renderYears();
      else renderDays();
    }

    function renderDays() {
      var year = focused.getFullYear();
      var month = focused.getMonth();
      var firstOfMonth = new Date(year, month, 1);
      var gridStart = new Date(year, month, 1 - firstOfMonth.getDay());

      var html = '<div class="flex items-center justify-between mb-2">' +
        '<button type="button" data-nav="prev-month" aria-label="Previous month" class="' + NAV_BTN_CLASS + '">' + CHEVRON_LEFT + '</button>' +
        '<button type="button" data-nav="show-months" class="text-sm font-medium text-clinic-900 hover:text-clinic-600 rounded-lg px-2 py-1 transition-colors">' + MONTH_NAMES[month] + ' ' + year + '</button>' +
        '<button type="button" data-nav="next-month" aria-label="Next month" class="' + NAV_BTN_CLASS + '">' + CHEVRON_RIGHT + '</button>' +
        '</div>' +
        '<div class="grid grid-cols-7 gap-y-1 text-center">';

      WEEKDAY_LABELS.forEach(function (w) {
        html += '<span class="text-[11px] font-medium text-clinic-700/40 py-1">' + w + '</span>';
      });

      var today = new Date();
      for (var i = 0; i < 42; i++) {
        var cellDate = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + i);
        var outOfMonth = cellDate.getMonth() !== month;
        var disabled = isDisabled(cellDate);
        var isSelected = sameDay(cellDate, selected);
        var isFocused = sameDay(cellDate, focused);
        var isToday = sameDay(cellDate, today);

        var cellClass = 'w-8 h-8 mx-auto flex items-center justify-center text-sm rounded-lg transition-colors ';
        if (disabled) {
          cellClass += 'text-clinic-700/20 cursor-not-allowed';
        } else if (isSelected) {
          cellClass += 'bg-clinic-800 text-white font-medium cursor-pointer';
        } else if (outOfMonth) {
          cellClass += 'text-clinic-700/25 hover:bg-clinic-50 cursor-pointer';
        } else {
          cellClass += 'text-clinic-900 hover:bg-clinic-50 cursor-pointer';
        }
        // Today gets its own ring so it reads clearly even when unselected —
        // skipped when selected since the solid fill already stands out and
        // stacking both would be visual noise.
        if (isToday && !isSelected) {
          cellClass += ' font-semibold ring-1 ring-inset ring-clinic-600 text-clinic-700';
        }

        html += '<button type="button" data-day="' + toIso(cellDate) + '"' +
          (disabled ? ' disabled' : '') +
          ' tabindex="' + (isFocused ? '0' : '-1') + '"' +
          ' class="' + cellClass + '">' + cellDate.getDate() + '</button>';
      }

      html += '</div>';
      panel.innerHTML = html;
      grid = panel;
    }

    // Zoomed-out month grid for the focused year — lets you jump straight to
    // a month instead of clicking prev/next-month repeatedly.
    function renderMonths() {
      var year = focused.getFullYear();
      var today = new Date();

      var html = '<div class="flex items-center justify-between mb-2">' +
        '<button type="button" data-nav="prev-year" aria-label="Previous year" class="' + NAV_BTN_CLASS + '">' + CHEVRON_LEFT + '</button>' +
        '<button type="button" data-nav="show-years" class="text-sm font-medium text-clinic-900 hover:text-clinic-600 rounded-lg px-2 py-1 transition-colors">' + year + '</button>' +
        '<button type="button" data-nav="next-year" aria-label="Next year" class="' + NAV_BTN_CLASS + '">' + CHEVRON_RIGHT + '</button>' +
        '</div>' +
        '<div class="grid grid-cols-3 gap-1.5">';

      for (var m = 0; m < 12; m++) {
        var lastDayOfMonth = new Date(year, m + 1, 0);
        var firstDayOfMonth = new Date(year, m, 1);
        var disabled = (maxDate && firstDayOfMonth > maxDate) || (minDate && lastDayOfMonth < minDate);
        var isSelected = !!selected && selected.getFullYear() === year && selected.getMonth() === m;
        var isCurrentMonth = today.getFullYear() === year && today.getMonth() === m;

        var cellClass = 'py-2.5 rounded-lg text-sm transition-colors ';
        if (disabled) cellClass += 'text-clinic-700/20 cursor-not-allowed';
        else if (isSelected) cellClass += 'bg-clinic-800 text-white font-medium cursor-pointer';
        else cellClass += 'text-clinic-900 hover:bg-clinic-50 cursor-pointer';
        if (isCurrentMonth && !isSelected) cellClass += ' font-semibold ring-1 ring-inset ring-clinic-600 text-clinic-700';

        html += '<button type="button" data-month="' + m + '"' + (disabled ? ' disabled' : '') +
          ' class="' + cellClass + '">' + MONTH_NAMES[m].slice(0, 3) + '</button>';
      }

      html += '</div>';
      panel.innerHTML = html;
      grid = panel;
    }

    // Zoomed-out year grid (12 years at a time) — one more level out from months.
    function renderYears() {
      var startYear = Math.floor(focused.getFullYear() / 12) * 12;
      var today = new Date();

      var html = '<div class="flex items-center justify-between mb-2">' +
        '<button type="button" data-nav="prev-decade" aria-label="Previous years" class="' + NAV_BTN_CLASS + '">' + CHEVRON_LEFT + '</button>' +
        '<span class="text-sm font-medium text-clinic-900">' + startYear + ' - ' + (startYear + 11) + '</span>' +
        '<button type="button" data-nav="next-decade" aria-label="Next years" class="' + NAV_BTN_CLASS + '">' + CHEVRON_RIGHT + '</button>' +
        '</div>' +
        '<div class="grid grid-cols-3 gap-1.5">';

      for (var i = 0; i < 12; i++) {
        var y = startYear + i;
        var disabled = (maxDate && y > maxDate.getFullYear()) || (minDate && y < minDate.getFullYear());
        var isSelected = !!selected && selected.getFullYear() === y;
        var isCurrentYear = today.getFullYear() === y;

        var cellClass = 'py-2.5 rounded-lg text-sm transition-colors ';
        if (disabled) cellClass += 'text-clinic-700/20 cursor-not-allowed';
        else if (isSelected) cellClass += 'bg-clinic-800 text-white font-medium cursor-pointer';
        else cellClass += 'text-clinic-900 hover:bg-clinic-50 cursor-pointer';
        if (isCurrentYear && !isSelected) cellClass += ' font-semibold ring-1 ring-inset ring-clinic-600 text-clinic-700';

        html += '<button type="button" data-year="' + y + '"' + (disabled ? ' disabled' : '') +
          ' class="' + cellClass + '">' + y + '</button>';
      }

      html += '</div>';
      panel.innerHTML = html;
      grid = panel;
    }

    function isOpen() {
      return !panel.classList.contains('hidden');
    }

    function open() {
      focused = selected || new Date();
      view = 'days';
      render();
      panel.classList.remove('hidden');
      trigger.setAttribute('aria-expanded', 'true');
      focusCell();
    }

    function close(returnFocus) {
      panel.classList.add('hidden');
      trigger.setAttribute('aria-expanded', 'false');
      if (returnFocus) trigger.focus();
    }

    function focusCell() {
      var cell = grid.querySelector('[data-day="' + toIso(focused) + '"]');
      if (cell) cell.focus();
    }

    function focusMonthCell() {
      var cell = grid.querySelector('[data-month="' + focused.getMonth() + '"]');
      if (cell) cell.focus();
    }

    function focusYearCell() {
      var cell = grid.querySelector('[data-year="' + focused.getFullYear() + '"]');
      if (cell) cell.focus();
    }

    // Moving between months/years can land on a day that doesn't exist in
    // the new month (e.g. focused on the 31st, jump to a 30-day month) —
    // clamp instead of letting Date roll over into the following month.
    function daysIn(year, month) {
      return new Date(year, month + 1, 0).getDate();
    }

    function moveFocus(newDate) {
      focused = newDate;
      render();
      focusCell();
    }

    function choose(date) {
      if (isDisabled(date)) return;
      selected = date;
      input.value = toIso(date);
      syncLabel();
      input.dispatchEvent(new Event('change', { bubbles: true }));
      close(true);
    }

    trigger.addEventListener('click', function () {
      isOpen() ? close(false) : open();
    });

    panel.addEventListener('click', function (e) {
      // Nav/month/year clicks re-render panel.innerHTML, which detaches the
      // element that was actually clicked. If this click were left to bubble,
      // the document "click outside" listener below would then see a
      // detached e.target — wrapper.contains(e.target) is false for a node
      // no longer in the DOM — and treat it as an outside click, closing the
      // panel mid-navigation. Stop it here since this handler already deals
      // with every click that lands inside the panel.
      e.stopPropagation();
      var nav = e.target.closest('[data-nav]');
      if (nav) {
        var type = nav.dataset.nav;
        if (type === 'prev-month') moveFocus(new Date(focused.getFullYear(), focused.getMonth() - 1, focused.getDate()));
        else if (type === 'next-month') moveFocus(new Date(focused.getFullYear(), focused.getMonth() + 1, focused.getDate()));
        else if (type === 'prev-year') { focused = new Date(focused.getFullYear() - 1, focused.getMonth(), 1); render(); focusMonthCell(); }
        else if (type === 'next-year') { focused = new Date(focused.getFullYear() + 1, focused.getMonth(), 1); render(); focusMonthCell(); }
        else if (type === 'prev-decade') { focused = new Date(focused.getFullYear() - 12, focused.getMonth(), 1); render(); focusYearCell(); }
        else if (type === 'next-decade') { focused = new Date(focused.getFullYear() + 12, focused.getMonth(), 1); render(); focusYearCell(); }
        else if (type === 'show-months') { view = 'months'; render(); focusMonthCell(); }
        else if (type === 'show-years') { view = 'years'; render(); focusYearCell(); }
        return;
      }
      var monthBtn = e.target.closest('[data-month]');
      if (monthBtn && !monthBtn.disabled) {
        var newMonth = Number(monthBtn.dataset.month);
        focused = new Date(focused.getFullYear(), newMonth, Math.min(focused.getDate(), daysIn(focused.getFullYear(), newMonth)));
        view = 'days';
        render();
        focusCell();
        return;
      }
      var yearBtn = e.target.closest('[data-year]');
      if (yearBtn && !yearBtn.disabled) {
        var newYear = Number(yearBtn.dataset.year);
        focused = new Date(newYear, focused.getMonth(), Math.min(focused.getDate(), daysIn(newYear, focused.getMonth())));
        view = 'months';
        render();
        focusMonthCell();
        return;
      }
      var dayBtn = e.target.closest('[data-day]');
      if (dayBtn && !dayBtn.disabled) {
        var parts = dayBtn.dataset.day.split('-');
        choose(new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2])));
      }
    });

    panel.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') { e.preventDefault(); close(true); return; }
      if (e.key === 'Tab') { close(false); return; }
      // The month/year grids are plain tabbable buttons — native Enter/Space
      // activation and Tab order are enough there. The arrow/page-key scheme
      // below is specific to navigating the day grid.
      if (view !== 'days') return;
      var d = focused;
      if (e.key === 'ArrowLeft') { e.preventDefault(); moveFocus(new Date(d.getFullYear(), d.getMonth(), d.getDate() - 1)); }
      else if (e.key === 'ArrowRight') { e.preventDefault(); moveFocus(new Date(d.getFullYear(), d.getMonth(), d.getDate() + 1)); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); moveFocus(new Date(d.getFullYear(), d.getMonth(), d.getDate() - 7)); }
      else if (e.key === 'ArrowDown') { e.preventDefault(); moveFocus(new Date(d.getFullYear(), d.getMonth(), d.getDate() + 7)); }
      else if (e.key === 'Home') { e.preventDefault(); moveFocus(new Date(d.getFullYear(), d.getMonth(), d.getDate() - d.getDay())); }
      else if (e.key === 'End') { e.preventDefault(); moveFocus(new Date(d.getFullYear(), d.getMonth(), d.getDate() + (6 - d.getDay()))); }
      else if (e.key === 'PageUp') { e.preventDefault(); moveFocus(new Date(d.getFullYear() - (e.shiftKey ? 1 : 0), d.getMonth() - (e.shiftKey ? 0 : 1), d.getDate())); }
      else if (e.key === 'PageDown') { e.preventDefault(); moveFocus(new Date(d.getFullYear() + (e.shiftKey ? 1 : 0), d.getMonth() + (e.shiftKey ? 0 : 1), d.getDate())); }
      else if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); choose(focused); }
    });

    document.addEventListener('click', function (e) {
      if (!wrapper.contains(e.target)) close(false);
    });

    syncLabel();
  }

  document.querySelectorAll('input[type="date"][data-custom-date]').forEach(enhance);
})();
