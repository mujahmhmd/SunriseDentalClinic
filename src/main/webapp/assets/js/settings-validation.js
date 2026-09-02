// Client-side validation for the Settings page's two forms: Account
// (username) and Change Password. Server-side, UpdateUsernameServlet /
// UpdateAccountPasswordServlet re-check the same rules - this is UX only,
// never the source of truth.
//
// The password form has one extra wrinkle: the New/Confirm fields start
// disabled, since a new password can't be set until the current one is
// confirmed. An AJAX check (VerifyCurrentPasswordServlet) runs as they type
// the current password (debounced, like the patient search box) and again
// on blur; get it right and the new-password fields unlock. That check is
// only ever a UX gate though; UpdateAccountPasswordServlet re-verifies the
// current password itself when the form is actually submitted, since a
// request can always skip the AJAX call and post straight to it.
function initSettingsValidation() {
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

  // --- Account form ---------------------------------------------------

  function validateUsername() {
    var username = document.getElementById('username').value.trim();
    if (!USERNAME_PATTERN.test(username)) {
      showFieldError('username', '3-16 characters: lowercase letters, numbers, dots, underscores or hyphens only (e.g. mujahith.mohamed).');
      return false;
    }
    clearFieldError('username');
    return true;
  }

  var usernameInput = document.getElementById('username');
  if (usernameInput) {
    // Usernames must be lowercase, so just force it as they type instead of
    // rejecting keystrokes after the fact.
    usernameInput.addEventListener('input', function () {
      var pos = this.selectionStart;
      this.value = this.value.toLowerCase();
      this.setSelectionRange(pos, pos);
    });
    usernameInput.addEventListener('blur', validateUsername);
  }

  var usernameForm = document.getElementById('updateUsernameForm');
  if (usernameForm) {
    usernameForm.addEventListener('submit', function (e) {
      if (!validateUsername()) e.preventDefault();
    });
  }

  // --- Change password form --------------------------------------------

  var currentPasswordInput = document.getElementById('currentPassword');
  var newPasswordInput = document.getElementById('newPassword');
  var confirmPasswordInput = document.getElementById('confirmPassword');
  var updatePasswordBtn = document.getElementById('updatePasswordBtn');
  var verifiedNote = document.getElementById('currentPasswordVerified');
  var passwordForm = document.getElementById('updatePasswordForm');

  if (!currentPasswordInput || !newPasswordInput || !confirmPasswordInput || !updatePasswordBtn || !passwordForm) {
    return;
  }

  var currentPasswordConfirmed = false;
  var verifyDebounceTimer = null;
  // Network responses aren't guaranteed to arrive in the order they were
  // sent - without this, a slow response to an earlier (wrong) attempt can
  // land after a faster response to a later (correct) one and clobber the
  // UI back to "incorrect". Each check gets a ticket; only the response
  // matching the *latest* ticket is allowed to update the UI.
  var verifyRequestId = 0;

  function lockNewPasswordFields() {
    currentPasswordConfirmed = false;
    newPasswordInput.value = '';
    confirmPasswordInput.value = '';
    newPasswordInput.disabled = true;
    confirmPasswordInput.disabled = true;
    updatePasswordBtn.disabled = true;
    verifiedNote.classList.add('hidden');
    clearFieldError('newPassword');
    clearFieldError('confirmPassword');
  }

  function unlockNewPasswordFields() {
    currentPasswordConfirmed = true;
    newPasswordInput.disabled = false;
    confirmPasswordInput.disabled = false;
    updatePasswordBtn.disabled = false;
    verifiedNote.classList.remove('hidden');
    clearFieldError('currentPassword');
  }

  /** @param silent don't nag "enter your current password" for a merely-empty field while still typing */
  function verifyCurrentPassword(silent) {
    clearTimeout(verifyDebounceTimer);
    var currentPassword = currentPasswordInput.value;
    var requestId = ++verifyRequestId;

    if (currentPassword === '') {
      lockNewPasswordFields();
      if (!silent) showFieldError('currentPassword', 'Enter your current password.');
      return;
    }

    fetch('verifyCurrentPassword', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'currentPassword=' + encodeURIComponent(currentPassword)
    })
      .then(function (res) { return res.json(); })
      .then(function (data) {
        if (requestId !== verifyRequestId) return; // a newer check has since superseded this one
        if (data.valid) {
          unlockNewPasswordFields();
        } else {
          // Always shown once resolved, debounced or blurred - the debounce
          // itself already means "they've stopped typing", so by the time
          // this fires there's no more "mid-keystroke" left to protect.
          lockNewPasswordFields();
          showFieldError('currentPassword', 'Current password is incorrect.');
        }
      })
      .catch(function () {
        if (requestId !== verifyRequestId) return;
        lockNewPasswordFields();
        showFieldError('currentPassword', "Couldn't verify your password - try again.");
      });
  }

  function validateNewPassword() {
    if (!PASSWORD_PATTERN.test(newPasswordInput.value)) {
      showFieldError('newPassword', 'Min 6 characters, with an uppercase letter, a lowercase letter, a number and a special character.');
      return false;
    }
    clearFieldError('newPassword');
    return true;
  }

  function validateConfirmPassword() {
    if (confirmPasswordInput.value !== newPasswordInput.value) {
      showFieldError('confirmPassword', "Passwords don't match.");
      return false;
    }
    clearFieldError('confirmPassword');
    return true;
  }

  // Re-checks as they type (debounced, silent - no red error mid-keystroke,
  // same reasoning as the blur-only fields below) so getting it right
  // unlocks the new-password fields without needing to click away first.
  // Blur re-checks immediately (not silent, no debounce wait) so tabbing
  // straight out after typing shows the result right away.
  currentPasswordInput.addEventListener('input', function () {
    if (currentPasswordConfirmed) lockNewPasswordFields();
    clearTimeout(verifyDebounceTimer);
    verifyDebounceTimer = setTimeout(function () { verifyCurrentPassword(true); }, 300);
  });
  currentPasswordInput.addEventListener('blur', function () { verifyCurrentPassword(false); });
  newPasswordInput.addEventListener('blur', validateNewPassword);
  confirmPasswordInput.addEventListener('blur', validateConfirmPassword);

  // Same live-check treatment for whether New Password and Confirm New
  // Password match: debounced 300ms after typing stops in *either* field
  // (editing New Password after Confirm's already filled in can make a
  // previously-matching pair stop matching, so both need to re-trigger
  // it), silent while Confirm is still empty so it doesn't nag before
  // there's been a chance to type anything into it.
  var matchDebounceTimer = null;
  function scheduleConfirmPasswordCheck() {
    clearTimeout(matchDebounceTimer);
    matchDebounceTimer = setTimeout(function () {
      if (confirmPasswordInput.value === '') {
        clearFieldError('confirmPassword');
        return;
      }
      validateConfirmPassword();
    }, 400);
  }
  newPasswordInput.addEventListener('input', scheduleConfirmPasswordCheck);
  confirmPasswordInput.addEventListener('input', scheduleConfirmPasswordCheck);

  passwordForm.addEventListener('submit', function (e) {
    var valid = currentPasswordConfirmed && [validateNewPassword(), validateConfirmPassword()]
      .every(function (result) { return result; });
    if (!valid) e.preventDefault();
  });
}

function togglePassword(id) {
  var field = document.getElementById(id);
  field.type = field.type === 'password' ? 'text' : 'password';
}
