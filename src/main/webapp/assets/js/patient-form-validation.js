// Client-side validation for the Create Patient and Edit Patient forms
// (identical fields, so shared here like staff/doctor-form-validation.js).
// Server-side, PatientValidator re-checks the same rules — this is UX only,
// never the source of truth.
//
// Fields validate on blur, not on every keystroke — see staff-form-validation.js
// for why (flagging a strict-format field red mid-entry is more confusing
// than helpful).
function initPatientFormValidation(formId) {
  var NIC_PATTERN = /^(\d{9}[VXvx]|\d{12})$/;
  var PHONE_PATTERN = /^0\d{9}$/;
  var MAX_AGE_YEARS = 120;

  // custom-select.js/custom-date.js hide the real field and build a visible
  // "<id>-trigger" element in its place — that's what needs the red border,
  // since styling the hidden original element wouldn't be seen.
  function fieldDisplayEl(id) {
    return document.getElementById(id + '-trigger') || document.getElementById(id);
  }

  function showFieldError(id, message) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = fieldDisplayEl(id);
    if (!errorEl || !inputEl) return;
    errorEl.textContent = message;
    errorEl.classList.remove('hidden');
    inputEl.classList.add('border-red-400');
    inputEl.classList.remove('border-clinic-100');
  }

  function clearFieldError(id) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = fieldDisplayEl(id);
    if (!errorEl || !inputEl) return;
    errorEl.classList.add('hidden');
    inputEl.classList.remove('border-red-400');
    inputEl.classList.add('border-clinic-100');
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

  function validateDateOfBirth() {
    var value = document.getElementById('dateOfBirth').value;
    if (!value) {
      showFieldError('dateOfBirth', 'Date of birth is required.');
      return false;
    }
    var dob = new Date(value + 'T00:00:00');
    var today = new Date();
    today.setHours(0, 0, 0, 0);
    var minDate = new Date(today);
    minDate.setFullYear(minDate.getFullYear() - MAX_AGE_YEARS);

    if (dob > today || dob < minDate) {
      showFieldError('dateOfBirth', 'Enter a valid date of birth.');
      return false;
    }
    clearFieldError('dateOfBirth');
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

  function validateNic() {
    var nic = document.getElementById('nic').value.trim();
    if (nic === '') {
      // Optional — children don't have one yet.
      clearFieldError('nic');
      return true;
    }
    if (!NIC_PATTERN.test(nic)) {
      showFieldError('nic', 'Enter a valid NIC: 9 digits + V/X (e.g. 912345678V) or 12 digits (e.g. 200012345678).');
      return false;
    }
    clearFieldError('nic');
    return true;
  }

  var fieldValidators = {
    name: validateName,
    dateOfBirth: validateDateOfBirth,
    phone: validatePhone,
    nic: validateNic
  };

  Object.keys(fieldValidators).forEach(function (id) {
    var input = document.getElementById(id);
    if (!input) return;
    input.addEventListener('blur', fieldValidators[id]);
    // dateOfBirth is hidden once custom-date.js enhances it, so it never
    // gets a real blur — but the calendar dispatches 'change' when a date
    // is picked, which this also catches.
    input.addEventListener('change', fieldValidators[id]);
  });

  var form = document.getElementById(formId);
  if (!form) return;

  form.addEventListener('submit', function (e) {
    var valid = [validateName(), validateDateOfBirth(), validatePhone(), validateNic()]
      .every(function (result) { return result; });

    if (!valid) e.preventDefault();
  });
}
