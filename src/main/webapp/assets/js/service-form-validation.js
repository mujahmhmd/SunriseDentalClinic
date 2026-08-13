// Client-side validation for the Create Service and Edit Service forms
// (identical fields, so shared here like staff/doctor-form-validation.js).
// Server-side, ServiceValidator re-checks the same rules — this is UX only,
// never the source of truth.
function initServiceFormValidation(formId) {
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
      showFieldError('name', 'Service name must be at least 3 characters.');
      return false;
    }
    clearFieldError('name');
    return true;
  }

  function validatePrice() {
    var priceInput = document.getElementById('price');
    var price = priceInput.value.trim();
    var value = Number(price);
    if (price === '' || isNaN(value) || value <= 0) {
      showFieldError('price', 'Enter a price greater than 0.');
      return false;
    }
    clearFieldError('price');
    return true;
  }

  var fieldValidators = {
    name: validateName,
    price: validatePrice
  };

  Object.keys(fieldValidators).forEach(function (id) {
    var input = document.getElementById(id);
    if (input) input.addEventListener('blur', fieldValidators[id]);
  });

  var form = document.getElementById(formId);
  if (!form) return;

  form.addEventListener('submit', function (e) {
    var valid = [validateName(), validatePrice()].every(function (result) { return result; });
    if (!valid) e.preventDefault();
  });
}
