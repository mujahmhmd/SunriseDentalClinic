// Time-tag availability for the appointment form. Given the chosen doctor,
// date and (once picked) patient, re-colors and disables slots that are
// already unavailable — either because the doctor already has an
// appointment then, or because the same patient already has a *different*
// appointment at that exact date/time — instead of letting the clash
// surface only after Submit.
function initAppointmentSlots(config) {
  var doctorInput = document.getElementById(config.doctorId);
  var dateInput = document.getElementById(config.dateId);
  var patientInput = document.getElementById(config.patientId);
  var container = document.getElementById(config.tagsContainerId);
  var excludeId = config.excludeId || '';
  if (!doctorInput || !dateInput || !container) return;

  var AVAILABLE_CLASS = 'inline-flex items-center px-2.5 py-1 rounded-full text-xs border border-clinic-100 text-clinic-700 bg-white cursor-pointer peer-checked:bg-clinic-800 peer-checked:text-white peer-checked:border-clinic-800 transition-colors';
  var BOOKED_CLASS = 'inline-flex items-center px-2.5 py-1 rounded-full text-xs border border-red-200 text-red-400 bg-red-50 line-through decoration-red-300 cursor-not-allowed transition-colors';
  var CONFLICT_CLASS = 'inline-flex items-center px-2.5 py-1 rounded-full text-xs border border-amber-200 text-amber-600 bg-amber-50 cursor-not-allowed transition-colors';

  var debounceTimer = null;

  function setEveryTag(className, disabled) {
    container.querySelectorAll('label[data-time]').forEach(function (label) {
      label.querySelector('input').disabled = disabled;
      label.querySelector('span').className = className;
    });
  }

  function applyAvailability(booked, patientConflict) {
    container.querySelectorAll('label[data-time]').forEach(function (label) {
      var time = label.dataset.time;
      var input = label.querySelector('input');
      var span = label.querySelector('span');
      var isBooked = booked.indexOf(time) !== -1;
      var isConflict = !isBooked && patientConflict.indexOf(time) !== -1;

      if (isBooked || isConflict) {
        if (input.checked) {
          // The date/doctor/patient changed out from under a slot the user
          // had already picked — clear it so an unavailable time can't be
          // silently submitted.
          input.checked = false;
          input.dispatchEvent(new Event('change', { bubbles: true }));
        }
        input.disabled = true;
        span.className = isBooked ? BOOKED_CLASS : CONFLICT_CLASS;
      } else {
        input.disabled = false;
        span.className = AVAILABLE_CLASS;
      }
    });
  }

  function refresh() {
    var doctorId = doctorInput.value;
    var date = dateInput.value;
    if (!doctorId || !date) {
      // Nothing to check against yet — leave every slot pickable.
      setEveryTag(AVAILABLE_CLASS, false);
      return;
    }
    var patientId = patientInput ? patientInput.value : '';
    var url = 'appointmentSlots?doctorId=' + encodeURIComponent(doctorId) + '&date=' + encodeURIComponent(date) +
      (patientId ? '&patientId=' + encodeURIComponent(patientId) : '') +
      (excludeId ? '&excludeId=' + encodeURIComponent(excludeId) : '');
    fetch(url)
      .then(function (res) { return res.json(); })
      .then(function (data) {
        applyAvailability(data.booked || [], data.patientConflict || []);
      });
  }

  function debouncedRefresh() {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(refresh, 150);
  }

  doctorInput.addEventListener('change', debouncedRefresh);
  dateInput.addEventListener('change', debouncedRefresh);
  if (patientInput) patientInput.addEventListener('change', debouncedRefresh);

  // Doctor/date/patient may already be filled in on load — editing an
  // existing appointment, or redisplaying after a validation error — so
  // check availability immediately rather than waiting for the next change.
  refresh();
}
