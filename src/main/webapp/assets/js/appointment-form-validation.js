// Client-side validation for the Create Appointment and Edit Appointment
// forms (identical fields, so shared here like patient-form-validation.js).
// Server-side, AppointmentValidator re-checks the same rules — this is UX
// only, never the source of truth.
function initAppointmentFormValidation(formId) {
  // custom-select.js/custom-date.js hide the real field and build a visible
  // "<id>-trigger" element in its place — that's what needs the red border,
  // since styling the hidden original element wouldn't be seen.
  function fieldDisplayEl(id) {
    return document.getElementById(id + '-trigger') || document.getElementById(id);
  }

  function showFieldError(id, message, displayEl) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = displayEl || fieldDisplayEl(id);
    if (!errorEl || !inputEl) return;
    errorEl.textContent = message;
    errorEl.classList.remove('hidden');
    inputEl.classList.add('border-red-400');
    inputEl.classList.remove('border-clinic-100');
  }

  function clearFieldError(id, displayEl) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = displayEl || fieldDisplayEl(id);
    if (!errorEl || !inputEl) return;
    errorEl.classList.add('hidden');
    inputEl.classList.remove('border-red-400');
    inputEl.classList.add('border-clinic-100');
  }

  // Patient isn't a native select/date field — it's the search box wired up
  // by patient-search.js — so its display element is patientQuery, not a
  // "-trigger" element.
  function validatePatient() {
    var hidden = document.getElementById('patientId');
    var display = document.getElementById('patientQuery');
    if (!hidden || !hidden.value) {
      showFieldError('patientId', 'Search and select a patient.', display);
      return false;
    }
    clearFieldError('patientId', display);
    return true;
  }

  function validateDoctor() {
    var value = document.getElementById('doctorId').value;
    if (!value) {
      showFieldError('doctorId', 'Select a doctor.');
      return false;
    }
    clearFieldError('doctorId');
    return true;
  }

  function validateDate() {
    var value = document.getElementById('appointmentDate').value;
    if (!value) {
      showFieldError('appointmentDate', 'Select an appointment date.');
      return false;
    }
    var today = new Date();
    today.setHours(0, 0, 0, 0);
    var date = new Date(value + 'T00:00:00');
    if (date < today) {
      showFieldError('appointmentDate', "Appointment date can't be in the past.");
      return false;
    }
    clearFieldError('appointmentDate');
    return true;
  }

  // Time is a group of radio tags (see appointment-slots.js), not a single
  // element — there's no "-trigger" to target, just the shared error text
  // under the tag row.
  function validateTime() {
    var checked = document.querySelector('input[name="appointmentTime"]:checked');
    var errorEl = document.getElementById('appointmentTimeError');
    if (!checked) {
      if (errorEl) { errorEl.textContent = 'Select an appointment time.'; errorEl.classList.remove('hidden'); }
      return false;
    }
    if (errorEl) errorEl.classList.add('hidden');
    return true;
  }

  var fieldValidators = {
    patientId: validatePatient,
    doctorId: validateDoctor,
    appointmentDate: validateDate
  };

  Object.keys(fieldValidators).forEach(function (id) {
    var input = document.getElementById(id);
    if (!input) return;
    input.addEventListener('blur', fieldValidators[id]);
    // doctorId/appointmentDate are hidden once custom-select.js/custom-date.js
    // enhance them, so they never get a real blur — but those scripts dispatch
    // 'change' when a value is picked, which this also catches. patientId
    // (hidden, set by patient-search.js) only ever fires 'change'.
    input.addEventListener('change', fieldValidators[id]);
  });

  document.querySelectorAll('input[name="appointmentTime"]').forEach(function (input) {
    input.addEventListener('change', validateTime);
  });

  var form = document.getElementById(formId);
  if (!form) return;

  form.addEventListener('submit', function (e) {
    var valid = [validatePatient(), validateDoctor(), validateDate(), validateTime()]
      .every(function (result) { return result; });

    if (!valid) e.preventDefault();
  });
}
