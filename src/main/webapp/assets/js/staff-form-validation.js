// Shared client-side validation for the Create Staff and Edit Staff forms
// (they have identical fields, so the rules live here once instead of being
// duplicated on both pages). Server-side, CreateStaffServlet/EditStaffServlet
// re-check the same rules — this is UX only, never the source of truth.
//
// Fields validate on blur (not on every keystroke): for a strict-format
// field like NIC or phone, the value is "wrong" for most of the time you're
// typing it, so flagging it red mid-entry reads as broken rather than
// helpful. Blur still gives near-instant feedback without that flicker.
function initStaffFormValidation(formId, options) {
  options = options || {};
  var passwordRequired = options.passwordRequired !== false; // default: required

  var NIC_PATTERN = /^(\d{9}[VXvx]|\d{12})$/;
  var PHONE_PATTERN = /^0\d{9}$/;
  var EMAIL_PATTERN = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
  // Lowercase letters/numbers, dot/underscore/hyphen allowed in the middle only, 3-16 chars total.
  var USERNAME_PATTERN = /^[a-z0-9][a-z0-9._-]{1,14}[a-z0-9]$/;
  var PASSWORD_PATTERN = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$/;

  function showFieldError(id, message) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = document.getElementById(id);
    if (!errorEl || !inputEl) return;
    errorEl.textContent = message;
    errorEl.classList.remove('hidden');
    inputEl.classList.add('border-red-400');
    inputEl.classList.remove('border-clinic-100');
  }

  function clearFieldError(id) {
    var errorEl = document.getElementById(id + 'Error');
    var inputEl = document.getElementById(id);
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
    // Spaces/hyphens are just how people naturally type a number (071 234 5678);
    // strip them before checking so what's actually stored is clean digits.
    var phone = phoneInput.value.trim().replace(/[\s-]/g, '');
    phoneInput.value = phone;
    if (!PHONE_PATTERN.test(phone)) {
      showFieldError('phone', 'Enter a valid 10-digit number starting with 0 (e.g. 0712345678).');
      return false;
    }
    clearFieldError('phone');
    return true;
  }

  function validateEmail() {
    var email = document.getElementById('email').value.trim();
    if (!EMAIL_PATTERN.test(email)) {
      showFieldError('email', 'Enter a valid email address (e.g. mujahith.mohamed@gmail.com).');
      return false;
    }
    clearFieldError('email');
    return true;
  }

  function validateUsername() {
    var username = document.getElementById('username').value.trim();
    if (!USERNAME_PATTERN.test(username)) {
      showFieldError('username', '3-16 characters: lowercase letters, numbers, dots, underscores or hyphens only (e.g. mujahith.mohamed).');
      return false;
    }
    clearFieldError('username');
    return true;
  }

  function validatePassword() {
    var password = document.getElementById('password').value;
    var passwordBlank = password.length === 0;
    if (passwordBlank && !passwordRequired) {
      // Edit form: leaving it blank means "keep the current password".
      clearFieldError('password');
      return true;
    }
    if (!PASSWORD_PATTERN.test(password)) {
      showFieldError('password', 'Min 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.');
      return false;
    }
    clearFieldError('password');
    return true;
  }

  // Usernames must be lowercase, so just force it as the admin types instead
  // of rejecting keystrokes after the fact.
  var usernameInput = document.getElementById('username');
  if (usernameInput) {
    usernameInput.addEventListener('input', function () {
      var pos = this.selectionStart;
      this.value = this.value.toLowerCase();
      this.setSelectionRange(pos, pos);
    });
  }

  var fieldValidators = {
    name: validateName,
    nic: validateNic,
    phone: validatePhone,
    email: validateEmail,
    username: validateUsername,
    password: validatePassword
  };

  Object.keys(fieldValidators).forEach(function (id) {
    var input = document.getElementById(id);
    if (input) input.addEventListener('blur', fieldValidators[id]);
  });

  var form = document.getElementById(formId);
  if (!form) return;

  form.addEventListener('submit', function (e) {
    var valid = [validateName(), validateNic(), validatePhone(), validateEmail(), validateUsername(), validatePassword()]
      .every(function (result) { return result; });

    if (!valid) e.preventDefault();
  });
}
