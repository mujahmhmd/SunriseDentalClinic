// Drives the "Complete & Bill" payment popup on the appointments page.
// Opening it moves the appointment to Processing Payment (StartAppointmentPaymentServlet)
// and loads the doctor's consultation fee + the active Services catalog;
// picking treatments updates a running total; Confirm Payment is a real
// form submit (not fetch) to ConfirmAppointmentPaymentServlet, which marks
// the appointment Completed and redirects to the now-billed receipt.
// Cancelling (backdrop click, Escape, or the Cancel button) reverts the
// appointment back to Scheduled instead of leaving it stuck mid-payment.
function initAppointmentPayment(config) {
  var modal = document.getElementById(config.modalId);
  var card = modal ? modal.querySelector('.payment-modal-card') : null;
  var idInput = document.getElementById(config.idInputId);
  var feeEl = document.getElementById(config.feeElId);
  var servicesList = document.getElementById(config.servicesListId);
  var totalEl = document.getElementById(config.totalElId);
  var cancelBtn = document.getElementById(config.cancelBtnId);
  if (!modal || !card || !idInput || !feeEl || !servicesList || !totalEl || !cancelBtn) return;

  var currentAppointmentId = null;
  var consultationFee = 0;

  function formatMoney(n) {
    return 'Rs. ' + n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  function recalcTotal() {
    var total = consultationFee;
    servicesList.querySelectorAll('input[type="checkbox"]:checked').forEach(function (cb) {
      total += Number(cb.dataset.price);
    });
    totalEl.textContent = formatMoney(total);
  }

  function renderServices(services) {
    servicesList.innerHTML = '';
    if (!services || services.length === 0) {
      servicesList.innerHTML = '<p class="text-sm text-clinic-700/50 py-2">No services in the catalog yet.</p>';
      return;
    }
    services.forEach(function (service) {
      var label = document.createElement('label');
      label.className = 'flex items-center justify-between py-2 cursor-pointer';
      label.innerHTML =
        '<span class="flex items-center gap-2.5 text-sm text-clinic-900">' +
        '<input type="checkbox" name="serviceIds" value="' + service.id + '" data-price="' + service.price + '" ' +
        'class="rounded border-clinic-300 text-clinic-800 focus:ring-clinic-600 cursor-pointer">' +
        service.name + '</span>' +
        '<span class="text-sm text-clinic-700/60 shrink-0 ml-3">' + formatMoney(Number(service.price)) + '</span>';
      servicesList.appendChild(label);
    });
    servicesList.querySelectorAll('input[type="checkbox"]').forEach(function (cb) {
      cb.addEventListener('change', recalcTotal);
    });
  }

  function showModal() {
    modal.classList.remove('hidden');
    modal.classList.add('flex');
    requestAnimationFrame(function () {
      card.classList.remove('scale-95', 'opacity-0');
    });
  }

  function hideModal() {
    card.classList.add('scale-95', 'opacity-0');
    setTimeout(function () {
      modal.classList.add('hidden');
      modal.classList.remove('flex');
    }, 150);
  }

  function open(appointmentId) {
    fetch('startAppointmentPayment?id=' + appointmentId, { method: 'POST' })
      .then(function (res) { return res.json(); })
      .then(function (data) {
        currentAppointmentId = appointmentId;
        idInput.value = appointmentId;
        consultationFee = Number(data.consultationFee) || 0;
        feeEl.textContent = formatMoney(consultationFee);
        renderServices(data.services);
        recalcTotal();
        showModal();
      });
  }

  function cancel() {
    hideModal();
    if (currentAppointmentId) {
      fetch('cancelAppointmentPayment?id=' + currentAppointmentId, { method: 'POST' })
        .then(function () {
          if (typeof config.onCancelled === 'function') config.onCancelled();
        });
    }
    currentAppointmentId = null;
  }

  cancelBtn.addEventListener('click', cancel);
  modal.addEventListener('click', function (e) { if (e.target === modal) cancel(); });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && !modal.classList.contains('hidden')) cancel();
  });

  window[config.openFnName || 'openAppointmentPayment'] = open;
}
