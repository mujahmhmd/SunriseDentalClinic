// Reusable custom dropdown. Progressively enhances any
// <select data-custom-select> into a styled, fully keyboard-accessible
// dropdown that matches the app's design (the native select's open option
// list can't be restyled with CSS at all — it's OS/browser chrome, not
// something a page can control — so this replaces just the visible parts
// while leaving the real <select> in the DOM, hidden, so form submission
// and any existing 'change' listeners keep working unchanged).
//
// Usage: add data-custom-select to any <select>, include this script once.
// No per-instance JS wiring needed — every matching select on the page is
// enhanced automatically. An <option value=""> (the usual empty default) is
// treated as a placeholder: it shows muted in the closed trigger, and in the
// open list it's pinned first, styled distinctly (muted/italic, separated by
// a divider) so it reads as a "clear selection" row rather than a normal choice.
//
// Keyboard support (same as a native select):
//   ArrowUp/ArrowDown - move highlight / open if closed
//   Home/End          - jump to first/last option
//   Enter/Space        - choose the highlighted option
//   Escape             - close without changing the value
//   Tab                - close and move focus on
//   letter keys         - type-ahead, jumps to the next option starting with it
(function () {
  function enhance(select) {
    if (select.dataset.enhanced) return;
    select.dataset.enhanced = 'true';

    var options = Array.prototype.slice.call(select.options);

    // Position in this array is what the open list actually renders/navigates;
    // .index is the matching real <option> index in the select for that row.
    // The placeholder (value="") stays included, at position 0, as a "clear
    // selection" row rather than being left out of the list entirely.
    var listItems = options.map(function (opt, i) {
      return { text: opt.textContent, index: i, isPlaceholder: opt.value === '' };
    });

    var wrapper = document.createElement('div');
    wrapper.className = 'relative';
    select.parentNode.insertBefore(wrapper, select);
    wrapper.appendChild(select);
    select.classList.add('hidden');

    var triggerId = select.id ? select.id + '-trigger' : '';
    var trigger = document.createElement('button');
    trigger.type = 'button';
    if (triggerId) trigger.id = triggerId;
    trigger.className = 'w-full flex items-center justify-between border border-clinic-100 bg-clinic-50/50 rounded-xl px-3.5 py-2.5 text-sm text-left focus:outline-none focus:ring-2 focus:ring-clinic-600 focus:border-transparent transition';
    trigger.setAttribute('role', 'combobox');
    trigger.setAttribute('aria-haspopup', 'listbox');
    trigger.setAttribute('aria-expanded', 'false');
    trigger.innerHTML =
      '<span class="truncate"></span>' +
      '<svg class="w-4 h-4 text-clinic-700/40 shrink-0 ml-2 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">' +
      '<path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" /></svg>';
    wrapper.appendChild(trigger);

    // Clicking the field's <label> should focus our trigger, not the now-hidden select.
    if (select.id) {
      var label = document.querySelector('label[for="' + select.id + '"]');
      if (label) label.setAttribute('for', triggerId);
    }

    var labelSpan = trigger.querySelector('span');
    var chevron = trigger.querySelector('svg');

    var listbox = document.createElement('ul');
    listbox.setAttribute('role', 'listbox');
    listbox.className = 'hidden absolute z-20 mt-1.5 w-full max-h-56 overflow-auto bg-white border border-clinic-100 rounded-xl shadow-lg py-1.5 text-sm';
    wrapper.appendChild(listbox);

    var activeIndex = -1; // position within listItems / listbox.children, not the real select index

    function renderOptions() {
      listbox.innerHTML = '';
      listItems.forEach(function (item, i) {
        var li = document.createElement('li');
        li.setAttribute('role', 'option');
        li.dataset.listIndex = i;
        if (triggerId) li.id = triggerId + '-option-' + i;
        li.textContent = item.text;
        li.className = item.isPlaceholder
          ? 'px-3.5 py-2 cursor-pointer italic text-clinic-700/50 hover:bg-clinic-50 border-b border-clinic-100 mb-1'
          : 'px-3.5 py-2 cursor-pointer text-clinic-900 hover:bg-clinic-50';
        listbox.appendChild(li);
      });
    }

    function syncLabel() {
      var selected = options[select.selectedIndex];
      var isPlaceholder = !selected || selected.value === '';
      labelSpan.textContent = selected ? selected.textContent : '';
      labelSpan.classList.toggle('text-clinic-700/40', isPlaceholder);
      labelSpan.classList.toggle('text-clinic-900', !isPlaceholder);
    }

    // Where the currently-selected real option sits within listItems, so
    // opening the list highlights it (or the first row, if it's the
    // placeholder — there's no list row for that to land on).
    function currentListIndex() {
      for (var i = 0; i < listItems.length; i++) {
        if (listItems[i].index === select.selectedIndex) return i;
      }
      return 0;
    }

    function highlight(listIndex) {
      var rows = listbox.children;
      if (activeIndex >= 0 && rows[activeIndex]) rows[activeIndex].classList.remove('bg-clinic-100');
      activeIndex = listIndex;
      if (rows[activeIndex]) {
        rows[activeIndex].classList.add('bg-clinic-100');
        rows[activeIndex].scrollIntoView({ block: 'nearest' });
        trigger.setAttribute('aria-activedescendant', rows[activeIndex].id);
      }
    }

    function isOpen() {
      return !listbox.classList.contains('hidden');
    }

    function open() {
      renderOptions();
      listbox.classList.remove('hidden');
      trigger.setAttribute('aria-expanded', 'true');
      chevron.style.transform = 'rotate(180deg)';
      highlight(currentListIndex());
    }

    function close() {
      listbox.classList.add('hidden');
      trigger.setAttribute('aria-expanded', 'false');
      chevron.style.transform = '';
      activeIndex = -1;
    }

    function selectListIndex(listIndex) {
      select.selectedIndex = listItems[listIndex].index;
      syncLabel();
      // So any existing validation/logic bound to the real select's
      // 'change' event keeps working without needing to know this exists.
      select.dispatchEvent(new Event('change', { bubbles: true }));
    }

    trigger.addEventListener('click', function () {
      isOpen() ? close() : open();
    });

    listbox.addEventListener('click', function (e) {
      var li = e.target.closest('[role="option"]');
      if (!li) return;
      selectListIndex(Number(li.dataset.listIndex));
      close();
      trigger.focus();
    });

    var typeahead = '';
    var typeaheadTimer = null;

    trigger.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (!isOpen()) { open(); return; }
        highlight(Math.min(activeIndex + 1, listItems.length - 1));
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (!isOpen()) { open(); return; }
        highlight(Math.max(activeIndex - 1, 0));
      } else if (e.key === 'Home' && isOpen()) {
        e.preventDefault();
        highlight(0);
      } else if (e.key === 'End' && isOpen()) {
        e.preventDefault();
        highlight(listItems.length - 1);
      } else if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        if (isOpen()) {
          if (activeIndex >= 0) selectListIndex(activeIndex);
          close();
        } else {
          open();
        }
      } else if (e.key === 'Escape' && isOpen()) {
        e.preventDefault();
        close();
      } else if (e.key === 'Tab') {
        close();
      } else if (e.key.length === 1 && /[a-z0-9]/i.test(e.key)) {
        typeahead += e.key.toLowerCase();
        clearTimeout(typeaheadTimer);
        typeaheadTimer = setTimeout(function () { typeahead = ''; }, 600);

        var startIndex = (isOpen() ? activeIndex : currentListIndex()) + 1;
        var match = -1;
        for (var i = 0; i < listItems.length; i++) {
          var idx = (startIndex + i) % listItems.length;
          if (listItems[idx].text.toLowerCase().indexOf(typeahead) === 0) {
            match = idx;
            break;
          }
        }
        if (match >= 0) {
          if (isOpen()) highlight(match); else selectListIndex(match);
        }
      }
    });

    document.addEventListener('click', function (e) {
      if (!wrapper.contains(e.target)) close();
    });

    syncLabel();
  }

  document.querySelectorAll('select[data-custom-select]').forEach(enhance);
})();
