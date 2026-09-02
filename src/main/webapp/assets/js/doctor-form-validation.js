// Client-side validation for the Create Doctor and Edit Doctor forms
// (identical fields, so shared here like staff-form-validation.js).
// Server-side, DoctorValidator re-checks the same rules - this is UX only,
// never the source of truth.
//
// Fields validate on blur, not on every keystroke (see staff-form-validation.js
// for why): a strict-format field reads as "wrong" for most of the time
// you're typing it, so flagging it red mid-entry is more confusing than helpful.
//
// NIC and SLMC Reg No additionally get a live *availability* check once
// their format is valid: debounced 300ms after typing stops (and again
// immediately on blur), an AJAX call to CheckDoctorFieldServlet reports
// whether another doctor already has that value, right under the field -
// same live-check pattern as the current-password check on the Settings
// page, including the same race-condition guard (a later check's response
// can otherwise land after an earlier one's and show a stale result).
function initDoctorFormValidation(formId) {
  var NIC_PATTERN = /^(\d{9}[VXvx]|\d{12})$/;
  var PHONE_PATTERN = /^0\d{9}$/;
  var SLMC_PATTERN = /^[A-Za-z0-9-]{3,15}$/;

  // Edit form only - excludes the doctor's own record from the availability
  // check, so re-saving their unchanged NIC/SLMC isn't flagged as a clash.
  var doctorIdInput = document.getElementById('doctorId');
  var excludeId = doctorIdInput ? doctorIdInput.value : '';

  function showFieldError(id, message) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = document.getElementById(id);
    if (!errorEl || !inputEl) return;
    errorEl.textContent = message;
    errorEl.classList.remove('hidden');
    if (inputEl.type !== 'checkbox') {
      inputEl.classList.add('border-red-400');
      inputEl.classList.remove('border-clinic-100');
    }
  }

  function clearFieldError(id) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = document.getElementById(id);
    if (!errorEl || !inputEl) return;
    errorEl.classList.add('hidden');
    if (inputEl.type !== 'checkbox') {
      inputEl.classList.remove('border-red-400');
      inputEl.classList.add('border-clinic-100');
    }
  }

  function validateName() {
    var name = document.getElementById('name').value.trim();
    if (name.length < 3) {
      showFieldError('name', 'Full name must be at least 3 characters.');
      return false;
    }
    clearFieldError('name');
    return true;
  }

  function validateNic() {
    var nic = document.getElementById('nic').value.trim();
    if (!NIC_PATTERN.test(nic)) {
      showFieldError('nic', 'Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).');
      return false;
    }
    clearFieldError('nic');
    return true;
  }

  function validatePhone() {
    var phoneInput = document.getElementById('phone');
    var phone = phoneInput.value.trim().replace(/[\s-]/g, '');
    phoneInput.value = phone;
    if (!PHONE_PATTERN.test(phone)) {
      showFieldError('phone', 'Enter a valid 10-digit number starting with 0 (e.g. 0712345678).');
      return false;
    }
    clearFieldError('phone');
    return true;
  }

  function validateSlmc() {
    var slmc = document.getElementById('slmcRegNo').value.trim();
    if (!SLMC_PATTERN.test(slmc)) {
      showFieldError('slmcRegNo', 'Letters, numbers and hyphens only, 3-15 characters.');
      return false;
    }
    clearFieldError('slmcRegNo');
    return true;
  }

  // One factory covers both NIC and SLMC Reg No - same check, just a
  // different field name/format-validator/not-available message.
  function createAvailabilityChecker(config) {
    var input = document.getElementById(config.inputId);
    if (!input) return { checkNow: function () {}, isTaken: function () { return false; } };

    var debounceTimer = null;
    var requestId = 0;
    var taken = false;

    function check() {
      clearTimeout(debounceTimer);
      // Only worth asking the server once the value is actually well-formed -
      // an incomplete/invalid value can't be "taken", it's just not done yet.
      if (!config.formatValidator()) {
        taken = false;
        return;
      }
      var value = input.value.trim();
      var thisRequest = ++requestId;

      fetch('checkDoctorField', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'field=' + encodeURIComponent(config.field) + '&value=' + encodeURIComponent(value) +
              '&excludeId=' + encodeURIComponent(excludeId)
      })
        .then(function (res) { return res.json(); })
        .then(function (data) {
          if (thisRequest !== requestId) return; // a newer check has since superseded this one
          taken = !data.available;
          // Always shown once resolved, debounced or blurred - the debounce
          // itself is what already means "they've stopped typing", so by the
          // time this fires there's no more "mid-keystroke" left to protect.
          if (taken) {
            showFieldError(config.inputId, config.takenMessage);
          } else {
            clearFieldError(config.inputId);
          }
        })
        .catch(function () {
          if (thisRequest !== requestId) return;
          // Can't confirm either way - don't block submission over a network
          // hiccup, the server re-checks for real at submit time anyway.
          taken = false;
        });
    }

    input.addEventListener('input', function () {
      taken = false;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(check, 300);
    });
    input.addEventListener('blur', check);

    return { checkNow: check, isTaken: function () { return taken; } };
  }

  var nicAvailability = createAvailabilityChecker({
    inputId: 'nic', field: 'nic', formatValidator: validateNic,
    takenMessage: 'A doctor already exists with this NIC.'
  });
  var slmcAvailability = createAvailabilityChecker({
    inputId: 'slmcRegNo', field: 'slmcRegNo', formatValidator: validateSlmc,
    takenMessage: 'That SLMC registration number is already in use.'
  });

  function validateQualifications() {
    var qualifications = document.getElementById('qualifications').value.trim();
    if (qualifications.length < 2) {
      showFieldError('qualifications', "Enter the doctor's qualifications (e.g. BDS).");
      return false;
    }
    clearFieldError('qualifications');
    return true;
  }

  function validateSpecializations() {
    var checked = document.querySelectorAll('input[name="specializations"]:checked');
    if (checked.length === 0) {
      showFieldError('specializations', 'Select at least one specialization.');
      return false;
    }
    var errorEl = document.getElementById('specializationsError');
    if (errorEl) errorEl.classList.add('hidden');
    return true;
  }

  function validateExperienceYears() {
    var value = document.getElementById('experienceYears').value.trim();
    if (value === '') {
      clearFieldError('experienceYears');
      return true;
    }
    var years = Number(value);
    if (!Number.isInteger(years) || years < 0 || years > 60) {
      showFieldError('experienceYears', 'Must be a whole number between 0 and 60.');
      return false;
    }
    clearFieldError('experienceYears');
    return true;
  }

  function validateConsultationFee() {
    var value = document.getElementById('consultationFee').value.trim();
    var fee = Number(value);
    if (value === '' || isNaN(fee) || fee <= 0) {
      showFieldError('consultationFee', 'Enter a fee greater than 0.');
      return false;
    }
    clearFieldError('consultationFee');
    return true;
  }

  // A day's time-range row only shows once that day is toggled on - no point
  // asking for hours on a day the doctor doesn't visit.
  document.querySelectorAll('.day-checkbox').forEach(function (checkbox) {
    checkbox.addEventListener('change', function () {
      var row = document.querySelector('[data-day-row="' + checkbox.dataset.day + '"]');
      if (!row) return;
      row.classList.toggle('hidden', !checkbox.checked);
      validateSchedule();
    });
  });

  function checkedValue(name) {
    var checked = document.querySelector('input[name="' + name + '"]:checked');
    return checked ? checked.value : '';
  }

  function validateSchedule() {
    var scheduleError = document.getElementById('scheduleError');
    if (!scheduleError) return true;

    var checkedDays = document.querySelectorAll('.day-checkbox:checked');
    for (var i = 0; i < checkedDays.length; i++) {
      var day = checkedDays[i].dataset.day;
      var start = checkedValue('start_' + day);
      var end = checkedValue('end_' + day);

      if (!start || !end) {
        scheduleError.textContent = 'Set a visiting time range for ' + day + '.';
        scheduleError.classList.remove('hidden');
        return false;
      }
      // Redundant with the End tags already being disabled for anything
      // <= Start, but kept as a safety net.
      if (start >= end) {
        scheduleError.textContent = 'For ' + day + ', the end time must be after the start time.';
        scheduleError.classList.remove('hidden');
        return false;
      }
    }

    scheduleError.classList.add('hidden');
    return true;
  }

  // Picking a Start hour unlocks only the End hours that come after it -
  // an End tag for an earlier/equal hour stays disabled and unclickable.
  document.querySelectorAll('.start-radio').forEach(function (radio) {
    radio.addEventListener('change', function () {
      var day = radio.dataset.day;
      var startValue = radio.value;

      document.querySelectorAll('.end-radio[data-day="' + day + '"]').forEach(function (endRadio) {
        var enabled = endRadio.value > startValue;
        endRadio.disabled = !enabled;
        if (!enabled && endRadio.checked) {
          endRadio.checked = false;
        }
      });

      validateSchedule();
    });
  });

  document.querySelectorAll('.end-radio').forEach(function (radio) {
    radio.addEventListener('change', validateSchedule);
  });

  var fieldValidators = {
    name: validateName,
    nic: validateNic,
    phone: validatePhone,
    slmcRegNo: validateSlmc,
    qualifications: validateQualifications,
    experienceYears: validateExperienceYears,
    consultationFee: validateConsultationFee
  };

  Object.keys(fieldValidators).forEach(function (id) {
    var input = document.getElementById(id);
    if (input) input.addEventListener('blur', fieldValidators[id]);
  });

  document.querySelectorAll('input[name="specializations"]').forEach(function (checkbox) {
    checkbox.addEventListener('change', validateSpecializations);
  });

  var form = document.getElementById(formId);
  if (!form) return;

  form.addEventListener('submit', function (e) {
    var valid = [
      validateName(), validateNic(), validatePhone(), validateSlmc(),
      validateQualifications(), validateSpecializations(),
      validateExperienceYears(), validateConsultationFee(), validateSchedule()
    ].every(function (result) { return result; });

    // Best-effort against whatever the last availability check found - if
    // no check has resolved yet (e.g. submitting right after typing, before
    // the debounce fires), this can't catch a clash; CreateDoctorServlet/
    // EditDoctorServlet still re-check for real when the form actually posts.
    if (nicAvailability.isTaken()) {
      showFieldError('nic', 'A doctor already exists with this NIC.');
      valid = false;
    }
    if (slmcAvailability.isTaken()) {
      showFieldError('slmcRegNo', 'That SLMC registration number is already in use.');
      valid = false;
    }

    if (!valid) e.preventDefault();
  });
}
