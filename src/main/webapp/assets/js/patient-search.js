// Patient search/autofill combobox for the appointment form. Typing queries
// /searchPatients (min 2 characters, debounced) and shows matches in a
// dropdown; clicking one fills the hidden id input used for submission.
// Unlike custom-select.js there's no backing <select> with a fixed option
// list — the choices are fetched live from the patients table, since an
// appointment must reference an existing patient record, never a freely
// typed one.
//
// Keyboard support: ArrowUp/ArrowDown move the highlight, Enter chooses the
// highlighted match, Escape closes the list.
function initPatientSearch(config) {
  var input = document.getElementById(config.inputId);
  var hidden = document.getElementById(config.hiddenId);
  var results = document.getElementById(config.resultsId);
  if (!input || !hidden || !results) return;

  var debounceTimer = null;
  var items = [];
  var activeIndex = -1;

  function renderResults() {
    results.innerHTML = '';
    activeIndex = -1;
    if (items.length === 0) {
      results.classList.add('hidden');
      return;
    }
    items.forEach(function (item, i) {
      var li = document.createElement('li');
      li.setAttribute('role', 'option');
      li.dataset.index = i;
      li.className = 'px-3.5 py-2 cursor-pointer hover:bg-clinic-50';
      li.innerHTML = '<span class="text-clinic-900 font-medium">' + item.name + '</span>' +
        '<span class="text-clinic-700/50"> — ' + item.phone + '</span>';
      results.appendChild(li);
    });
    results.classList.remove('hidden');
  }

  function highlight(index) {
    var rows = results.children;
    if (activeIndex >= 0 && rows[activeIndex]) rows[activeIndex].classList.remove('bg-clinic-100');
    activeIndex = index;
    if (rows[activeIndex]) {
      rows[activeIndex].classList.add('bg-clinic-100');
      rows[activeIndex].scrollIntoView({ block: 'nearest' });
    }
  }

  function search(query) {
    if (query.trim().length < 2) {
      items = [];
      renderResults();
      return;
    }
    fetch('searchPatients?q=' + encodeURIComponent(query))
      .then(function (res) { return res.json(); })
      .then(function (data) {
        items = data;
        renderResults();
      });
  }

  function choose(item) {
    hidden.value = item.id;
    hidden.dispatchEvent(new Event('change', { bubbles: true }));
    input.value = item.name + ' — ' + item.phone;
    items = [];
    results.classList.add('hidden');
  }

  input.addEventListener('input', function () {
    // Any manual edit invalidates the previous pick — a match must be
    // clicked (or chosen via Enter) again before this can be submitted.
    hidden.value = '';
    hidden.dispatchEvent(new Event('change', { bubbles: true }));
    clearTimeout(debounceTimer);
    var query = input.value;
    debounceTimer = setTimeout(function () { search(query); }, 250);
  });

  input.addEventListener('keydown', function (e) {
    if (results.classList.contains('hidden')) return;
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      highlight(Math.min(activeIndex + 1, items.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      highlight(Math.max(activeIndex - 1, 0));
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (activeIndex >= 0) choose(items[activeIndex]);
    } else if (e.key === 'Escape') {
      results.classList.add('hidden');
    }
  });

  results.addEventListener('click', function (e) {
    var li = e.target.closest('[role="option"]');
    if (!li) return;
    choose(items[Number(li.dataset.index)]);
  });

  document.addEventListener('click', function (e) {
    if (!input.contains(e.target) && !results.contains(e.target)) {
      results.classList.add('hidden');
    }
  });
}
