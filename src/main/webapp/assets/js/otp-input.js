// Reusable 6-digit OTP input: a row of single-character boxes that behaves
// like the ones in banking/2FA apps, while keeping one hidden <input> in
// sync so the surrounding form still just posts a single "otp" field - no
// server-side change needed for this.
//
// Keyboard support:
//   digit               - fills the box and jumps to the next one
//   Backspace           - clears the box; pressed again on an already-empty
//                         box jumps back and clears the previous one too
//                         (the usual OTP-box feel, not just a plain input)
//   ArrowLeft/ArrowRight - move focus between boxes without touching values
//   paste               - a pasted code (digits extracted from anywhere in
//                         the clipboard text) fills all boxes from the start
//
// Usage: initOtpInput({ containerId, hiddenInputId, onComplete }) - boxes
// are every ".otp-box" input inside the container, in DOM order.
function initOtpInput(config) {
  var container = document.getElementById(config.containerId);
  var hidden = document.getElementById(config.hiddenInputId);
  if (!container || !hidden) return;
  var boxes = Array.prototype.slice.call(container.querySelectorAll('.otp-box'));
  if (!boxes.length) return;

  function sync() {
    hidden.value = boxes.map(function (b) { return b.value; }).join('');
    hidden.dispatchEvent(new Event('input', { bubbles: true }));
  }

  function focusBox(i) {
    var box = boxes[i];
    if (box) {
      box.focus();
      box.select();
    }
  }

  function isComplete() {
    return boxes.every(function (b) { return b.value !== ''; });
  }

  boxes.forEach(function (box, i) {
    box.addEventListener('input', function () {
      // Keeps only the last typed character - covers both a fresh digit and
      // a digit typed over an already-selected (pre-filled) one.
      var digit = box.value.replace(/\D/g, '').slice(-1);
      box.value = digit;
      sync();

      if (digit && i < boxes.length - 1) {
        focusBox(i + 1);
      } else if (digit && i === boxes.length - 1 && isComplete()) {
        if (typeof config.onComplete === 'function') config.onComplete();
      }
    });

    box.addEventListener('keydown', function (e) {
      if (e.key === 'Backspace') {
        if (!box.value && i > 0) {
          e.preventDefault();
          boxes[i - 1].value = '';
          sync();
          focusBox(i - 1);
        }
        // Box still has a value: let the native clear fire, the 'input'
        // handler above re-syncs - no jump, matches how these normally feel.
      } else if (e.key === 'ArrowLeft' && i > 0) {
        e.preventDefault();
        focusBox(i - 1);
      } else if (e.key === 'ArrowRight' && i < boxes.length - 1) {
        e.preventDefault();
        focusBox(i + 1);
      }
    });

    box.addEventListener('paste', function (e) {
      e.preventDefault();
      var clipboard = (e.clipboardData || window.clipboardData);
      var pasted = clipboard ? clipboard.getData('text').replace(/\D/g, '') : '';
      if (!pasted) return;
      boxes.forEach(function (b, j) { b.value = pasted[j] || ''; });
      sync();
      var nextEmptyIndex = boxes.findIndex(function (b) { return b.value === ''; });
      focusBox(nextEmptyIndex === -1 ? boxes.length - 1 : nextEmptyIndex);
      if (isComplete() && typeof config.onComplete === 'function') config.onComplete();
    });

    // A fresh click/tab into a filled box selects its digit, so typing
    // replaces it instead of silently doing nothing (maxlength=1 already
    // blocks appending, which without this would make retyping feel stuck).
    box.addEventListener('focus', function () { box.select(); });
  });

  focusBox(0);
}
