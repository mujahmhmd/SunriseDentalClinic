// Client-side validation for the Create Doctor and Edit Doctor forms
// (identical fields, so shared here like staff-form-validation.js).
// Server-side, DoctorValidator re-checks the same rules — this is UX only,
// never the source of truth.
//
// Fields validate on blur, not on every keystroke (see staff-form-validation.js
// for why): a strict-format field reads as "wrong" for most of the time
// you're typing it, so flagging it red mid-entry is more confusing than helpful.
function initDoctorFormValidation(formId) {
  var NIC_PATTERN = /^(\d{9}[VXvx]|\d{12})$/;
  var PHONE_PATTERN = /^0\d{9}$/;
  var SLMC_PATTERN = /^[A-Za-z0-9-]{3,15}$/;

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
    if (value === '') {
      clearFieldError('consultationFee');
      return true;
    }
    var fee = Number(value);
    if (isNaN(fee) || fee < 0) {
      showFieldError('consultationFee', "Can't be negative.");
      return false;
    }
    clearFieldError('consultationFee');
    return true;
  }

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
      validateExperienceYears(), validateConsultationFee()
    ].every(function (result) { return result; });

    if (!valid) e.preventDefault();
  });
}
