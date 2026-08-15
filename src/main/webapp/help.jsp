<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>How to Use System - Sunrise Dental</title>
  <link rel="icon" type="image/svg+xml" href="assets/images/favicon.svg">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;1,9..144,500&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">

  <script src="https://cdn.tailwindcss.com"></script>
  <script src="tailwind.config.js"></script>

  <style>
    body { font-family: 'Outfit', sans-serif; }
    .font-display { font-family: 'Fraunces', serif; }
    html { scroll-behavior: smooth; }

    /* Mock browser chrome around each screenshot */
    .shot-frame {
      border: 1px solid rgb(34 64 47 / 0.1);
      border-radius: 1rem;
      overflow: hidden;
      box-shadow: 0 12px 28px -12px rgb(24 46 34 / 0.18);
      background: #fff;
    }
    .shot-frame .shot-bar {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 10px 14px;
      background: #F8F4EA;
      border-bottom: 1px solid rgb(34 64 47 / 0.1);
    }
    .shot-frame .shot-dot { width: 9px; height: 9px; border-radius: 999px; }
    .shot-frame img { display: block; width: 100%; height: auto; }

    .step-num {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 2.25rem;
      height: 2.25rem;
      border-radius: 0.85rem;
      font-family: 'Fraunces', serif;
      font-weight: 600;
      flex-shrink: 0;
    }

    .toc-link {
      display: block;
      padding: 0.3rem 0 0.3rem 0.85rem;
      border-left: 2px solid transparent;
    }
    .toc-link.active {
      color: #182E22;
      font-weight: 600;
      border-left-color: #E2745A;
    }
  </style>
</head>
<body class="min-h-screen bg-clinic-50">

  <!-- Top bar -->
  <header class="sticky top-0 z-30 bg-clinic-900 text-clinic-50">
    <div class="max-w-6xl mx-auto px-5 sm:px-8 py-3.5 flex items-center justify-between gap-4">
      <div class="flex items-center gap-2.5">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-clinic-600 to-clinic-800 flex items-center justify-center shrink-0">
          <svg width="14" height="15" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M18.6667 0C20.1333 0 21.3889 0.522222 22.4333 1.56667C23.4778 2.61111 24 3.86667 24 5.33333C24 5.57778 23.9833 5.90556 23.95 6.31667C23.9167 6.72778 23.8667 7.2 23.8 7.73333L21.9667 21.1667C21.8556 22.0111 21.4722 22.7 20.8167 23.2333C20.1611 23.7667 19.4111 24.0333 18.5667 24.0333C18.0556 24.0333 17.5833 23.9222 17.15 23.7C16.7167 23.4778 16.3556 23.1667 16.0667 22.7667L12.5 17.5667C12.4556 17.4778 12.3833 17.4167 12.2833 17.3833C12.1833 17.35 12.0778 17.3333 11.9667 17.3333C11.8778 17.3333 11.7 17.4333 11.4333 17.6333L7.96667 22.6667C7.65556 23.1111 7.27222 23.45 6.81667 23.6833C6.36111 23.9167 5.87778 24.0333 5.36667 24.0333C4.52222 24.0333 3.77778 23.7611 3.13333 23.2167C2.48889 22.6722 2.11111 21.9778 2 21.1333L0.2 7.73333C0.133333 7.2 0.0833333 6.72778 0.05 6.31667C0.0166667 5.90556 0 5.57778 0 5.33333C0 3.86667 0.522222 2.61111 1.56667 1.56667C2.61111 0.522222 3.86667 0 5.33333 0C6.13333 0 6.77222 0.105556 7.25 0.316667C7.72778 0.527778 8.18889 0.755556 8.63333 1C9.07778 1.24444 9.55 1.47222 10.05 1.68333C10.55 1.89444 11.2 2 12 2C12.8 2 13.45 1.89444 13.95 1.68333C14.45 1.47222 14.9222 1.24444 15.3667 1C15.8111 0.755556 16.2778 0.527778 16.7667 0.316667C17.2556 0.105556 17.8889 0 18.6667 0ZM18.6667 2.66667C18.1556 2.66667 17.7056 2.77222 17.3167 2.98333C16.9278 3.19444 16.5 3.42222 16.0333 3.66667C15.5667 3.91111 15.0222 4.13889 14.4 4.35C13.7778 4.56111 12.9778 4.66667 12 4.66667C11.0222 4.66667 10.2222 4.56111 9.6 4.35C8.97778 4.13889 8.43333 3.91111 7.96667 3.66667C7.5 3.42222 7.07222 3.19444 6.68333 2.98333C6.29444 2.77222 5.84444 2.66667 5.33333 2.66667C4.6 2.66667 3.97222 2.92778 3.45 3.45C2.92778 3.97222 2.66667 4.6 2.66667 5.33333C2.66667 5.51111 2.67778 5.76667 2.7 6.1C2.72222 6.43333 2.76667 6.82222 2.83333 7.26667L4.66667 20.7667C4.68889 20.9444 4.76667 21.0833 4.9 21.1833C5.03333 21.2833 5.18889 21.3333 5.36667 21.3333C5.47778 21.3333 5.57778 21.3111 5.66667 21.2667C5.75556 21.2222 5.82222 21.1556 5.86667 21.0667L9.23333 16.1333C9.54444 15.6889 9.94444 15.3333 10.4333 15.0667C10.9222 14.8 11.4444 14.6667 12 14.6667C12.5556 14.6667 13.0778 14.8 13.5667 15.0667C14.0556 15.3333 14.4556 15.6889 14.7667 16.1333L18.2 21.1667C18.2444 21.2333 18.3 21.2833 18.3667 21.3167C18.4333 21.35 18.5111 21.3667 18.6 21.3667C18.7778 21.3667 18.9389 21.3167 19.0833 21.2167C19.2278 21.1167 19.3111 20.9778 19.3333 20.8L21.1667 7.26667C21.2333 6.82222 21.2778 6.43333 21.3 6.1C21.3222 5.76667 21.3333 5.51111 21.3333 5.33333C21.3333 4.6 21.0722 3.97222 20.55 3.45C20.0278 2.92778 19.4 2.66667 18.6667 2.66667Z" fill="white"/>
          </svg>
        </div>
        <div class="leading-tight">
          <p class="text-sm font-semibold">Sunrise Dental Clinic</p>
          <p class="text-[11px] text-clinic-50/60">Staff Guide</p>
        </div>
      </div>
      <a href="login.jsp" class="flex items-center gap-1.5 text-xs font-medium bg-white/10 hover:bg-white/15 rounded-full px-3.5 py-2 transition">
        <svg xmlns="http://www.w3.org/2000/svg" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
        </svg>
        Back to Login
      </a>
    </div>
  </header>

  <!-- Hero -->
  <div class="border-b border-clinic-100 bg-white">
    <div class="max-w-6xl mx-auto px-5 sm:px-8 py-10 sm:py-12">
      <p class="text-xs font-semibold tracking-widest text-coral-500 uppercase mb-3">New staff onboarding</p>
      <h1 class="font-display text-3xl sm:text-4xl text-clinic-900 mb-3">How to use the portal</h1>
      <p class="text-sm sm:text-base text-clinic-700/75 max-w-2xl leading-relaxed">
        A walkthrough of the day-to-day screens a front-desk or clinical staff account uses -
        logging in, adding patients, booking appointments, and taking payment - with real
        screenshots from the system so you know exactly what to expect.
      </p>
    </div>
  </div>

  <div class="max-w-6xl mx-auto px-5 sm:px-8 py-10 sm:py-12 flex flex-col lg:flex-row gap-10 lg:gap-14 items-start">

    <!-- Table of contents -->
    <nav aria-label="Table of contents" class="hidden lg:block w-56 shrink-0 sticky top-24">
      <p class="text-xs font-semibold tracking-widest text-clinic-700/50 uppercase mb-3">On this page</p>
      <ol class="text-sm">
        <li><a href="#logging-in" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">1. Logging in</a></li>
        <li><a href="#forgot-password" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">2. Forgot your password?</a></li>
        <li><a href="#settings" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">3. Your account settings</a></li>
        <li><a href="#dashboard" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">4. The dashboard</a></li>
        <li><a href="#patients" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">5. Managing patients</a></li>
        <li><a href="#doctors" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">6. Doctors</a></li>
        <li><a href="#booking" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">7. Booking an appointment</a></li>
        <li><a href="#appointments" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">8. The appointments list</a></li>
        <li><a href="#billing-appt" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">9. Complete &amp; bill</a></li>
        <li><a href="#reopen" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">10. Reopening a visit</a></li>
        <li><a href="#admin-only" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">11. Admin-only areas</a></li>
        <li><a href="#need-help" class="toc-link text-clinic-700/70 hover:text-clinic-900 transition">12. Getting help</a></li>
      </ol>
    </nav>

    <!-- Content -->
    <div class="flex-1 min-w-0 space-y-16 sm:space-y-20">

      <!-- 1. Logging in -->
      <section id="logging-in" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">1</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Logging in</h2>
            <p class="text-sm text-clinic-700/70 mt-1">The first screen everyone sees.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/01-login.png" alt="Sunrise Dental login screen with username, password and Login to Dashboard button">
          </div>
          <ul class="space-y-2.5 text-sm text-clinic-700/85 list-disc pl-5">
            <li>Enter the <strong class="text-clinic-900">username and password</strong> your admin gave you.</li>
            <li>Tick <strong class="text-clinic-900">Keep me logged in</strong> if this is your own device, so you don't have to sign in every visit.</li>
            <li>Click <strong class="text-clinic-900">Login to Dashboard</strong>.</li>
            <li>Forgot your password? Click <strong class="text-clinic-900">Forgot?</strong> next to the Password field, enter your email, and a
              6-digit code will arrive shortly - it expires after a few minutes, so use it quickly.</li>
          </ul>
        </div>
      </section>

      <!-- 2. Forgot password -->
      <section id="forgot-password" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">2</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Forgot your password?</h2>
            <p class="text-sm text-clinic-700/70 mt-1">A self-service 3-step reset, no admin needed.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="grid sm:grid-cols-3 gap-4">
            <div class="shot-frame">
              <div class="shot-bar">
                <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
              </div>
              <img src="assets/images/help/11-forgot-password.png" alt="Forgot Password screen with an email field and Send Reset Code button">
            </div>
            <div class="shot-frame">
              <div class="shot-bar">
                <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
              </div>
              <img src="assets/images/help/12-verify-otp.png" alt="Enter Reset Code screen showing a 6-digit code field">
            </div>
            <div class="shot-frame">
              <div class="shot-bar">
                <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
              </div>
              <img src="assets/images/help/13-reset-password.png" alt="Reset Password screen with New Password and Confirm New Password fields">
            </div>
          </div>
          <ol class="space-y-2.5 text-sm text-clinic-700/85 list-decimal pl-5">
            <li>On the login screen, click <strong class="text-clinic-900">Forgot?</strong> next to the Password field, then enter the
              <strong class="text-clinic-900">email</strong> on your account and click <strong class="text-clinic-900">Send Reset Code</strong>.</li>
            <li>Check your inbox for a <strong class="text-clinic-900">6-digit code</strong> and enter it on the next screen. It
              <strong class="text-clinic-900">expires in 3 minutes</strong>, so use it quickly - if it expires, go back and resend a fresh one.</li>
            <li>Choose a <strong class="text-clinic-900">new password</strong>, confirm it, and you're straight back on the login screen ready to sign in.</li>
          </ol>
          <p class="text-sm text-clinic-700/70">No email on your account, or the reset email never arrives? Ask an admin to check or update your email under Staffs.</p>
        </div>
      </section>

      <!-- 3. Settings -->
      <section id="settings" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">3</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Your account settings</h2>
            <p class="text-sm text-clinic-700/70 mt-1">Update your own username or password any time, from inside the portal.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="grid sm:grid-cols-2 gap-4">
            <div class="shot-frame">
              <div class="shot-bar">
                <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
              </div>
              <img src="assets/images/help/14-settings.png" alt="Settings page with an Account card for the username and a Change Password card">
            </div>
            <div class="shot-frame">
              <div class="shot-bar">
                <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
              </div>
              <img src="assets/images/help/15-settings-password-verified.png" alt="Change Password card after the current password is verified, with the New Password fields unlocked">
            </div>
          </div>
          <p class="text-sm text-clinic-700/85">Click <strong class="text-clinic-900">Settings</strong> at the bottom of the sidebar. There are two independent cards:</p>
          <ul class="space-y-2.5 text-sm text-clinic-700/85 list-disc pl-5">
            <li><strong class="text-clinic-900">Account</strong> - change the username you sign in with, then click <strong class="text-clinic-900">Update Username</strong>.</li>
            <li><strong class="text-clinic-900">Change password</strong> - type your <strong class="text-clinic-900">current password</strong> first. The New Password fields stay locked
              until it's confirmed correct; get it wrong and you'll see <em>"Current password is incorrect"</em> right there instead of losing anything you'd already typed.</li>
            <li>Once verified, enter a <strong class="text-clinic-900">new password</strong> and <strong class="text-clinic-900">confirm</strong> it - they have to match - then click
              <strong class="text-clinic-900">Update Password</strong>.</li>
          </ul>
        </div>
      </section>

      <!-- 4. Dashboard -->
      <section id="dashboard" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">4</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">The dashboard</h2>
            <p class="text-sm text-clinic-700/70 mt-1">Your home screen after logging in.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/02-dashboard.png" alt="Dashboard with today's appointments, total patients, active doctors stats and quick actions">
          </div>
          <ul class="space-y-2.5 text-sm text-clinic-700/85 list-disc pl-5">
            <li>The cards at the top show <strong class="text-clinic-900">today's appointments</strong>, <strong class="text-clinic-900">total patients</strong> and
              <strong class="text-clinic-900">active doctors</strong> at a glance. (The revenue card only appears for admin accounts.)</li>
            <li><strong class="text-clinic-900">Today's Schedule</strong> lists everyone booked in for today, so you can see the day at a glance.</li>
            <li><strong class="text-clinic-900">Quick Actions</strong> on the right jump straight to booking an appointment or adding a patient/doctor.</li>
            <li>The left <strong class="text-clinic-900">sidebar</strong> is how you get to every other page - it's the same on every screen.</li>
          </ul>
        </div>
      </section>

      <!-- 5. Patients -->
      <section id="patients" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">5</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Managing patients</h2>
            <p class="text-sm text-clinic-700/70 mt-1">Every patient the clinic has ever seen, in one list.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/03-patients.png" alt="Patients list with patient ID, name, age, gender, phone, NIC and action icons">
          </div>
          <ul class="space-y-2.5 text-sm text-clinic-700/85 list-disc pl-5">
            <li>Use the <strong class="text-clinic-900">search box</strong> to find someone by name, phone number or NIC - or their
              printed <strong class="text-clinic-900">Patient ID</strong> (the <em>SDCP000xxx</em> code).</li>
            <li>The icons on the right of each row: <strong class="text-clinic-900">ID card</strong> (print a patient ID card),
              <strong class="text-clinic-900">pencil</strong> (edit details), <strong class="text-clinic-900">trash</strong> (delete).</li>
          </ul>
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/04-create-patient.png" alt="Create Patient form with name, date of birth, contact number, optional email, NIC, gender and address">
          </div>
          <ul class="space-y-2.5 text-sm text-clinic-700/85 list-disc pl-5">
            <li>Click <strong class="text-clinic-900">Create Patient</strong> to add someone new. Only <strong class="text-clinic-900">Full Name</strong>,
              <strong class="text-clinic-900">Date of Birth</strong> and <strong class="text-clinic-900">Contact Number</strong> are required - everything else is optional.</li>
            <li>If you add an <strong class="text-clinic-900">email</strong>, that patient automatically gets an emailed confirmation whenever
              you book them an appointment, and an emailed receipt when their visit is billed. No email on file just means those emails are skipped -
              nothing breaks.</li>
            <li>Patients are clinic records only - they never log into the portal themselves.</li>
          </ul>
        </div>
      </section>

      <!-- 6. Doctors -->
      <section id="doctors" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">6</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Doctors</h2>
            <p class="text-sm text-clinic-700/70 mt-1">The clinic's visiting doctors and their fees.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/08-doctors.png" alt="Doctors list with name, SLMC registration number, specializations, phone and active/inactive status">
          </div>
          <ul class="space-y-2.5 text-sm text-clinic-700/85 list-disc pl-5">
            <li>Staff accounts can view the full doctor directory, <strong class="text-clinic-900">add a new doctor</strong> and
              <strong class="text-clinic-900">edit</strong> their details, specializations or active/inactive status.</li>
            <li>Only an <strong class="text-clinic-900">Active</strong> doctor shows up as a choice when booking an appointment.</li>
            <li><strong class="text-clinic-900">Deleting</strong> a doctor is admin-only - ask an admin if one needs to be removed.</li>
          </ul>
        </div>
      </section>

      <!-- 7. Booking an appointment -->
      <section id="booking" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">7</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Booking an appointment</h2>
            <p class="text-sm text-clinic-700/70 mt-1">The most common task on the portal.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/06-book-appointment.png" alt="Book Appointment form with patient search, doctor dropdown, date picker and a grid of time slot tags">
          </div>
          <ol class="space-y-2.5 text-sm text-clinic-700/85 list-decimal pl-5">
            <li>Click <strong class="text-clinic-900">Book Appointment</strong> (top-right of any page, or from the Appointments list).</li>
            <li>Search for the <strong class="text-clinic-900">patient</strong> by name, phone or NIC and pick them from the dropdown.
              Not registered yet? Use the "Add them as a patient first" link.</li>
            <li>Choose a <strong class="text-clinic-900">doctor</strong> and a <strong class="text-clinic-900">date</strong>.</li>
            <li>Pick a <strong class="text-clinic-900">time slot</strong> from the tags. The colors tell you what's available:
              <span class="inline-flex items-center gap-1 ml-1"><span class="w-2 h-2 rounded-full bg-clinic-800 inline-block"></span>Selected</span>,
              <span class="inline-flex items-center gap-1 ml-1"><span class="w-2 h-2 rounded-full border border-clinic-300 inline-block"></span>Available</span>,
              <span class="inline-flex items-center gap-1 ml-1"><span class="w-2 h-2 rounded-full bg-red-400 inline-block"></span>Already Booked</span>,
              <span class="inline-flex items-center gap-1 ml-1"><span class="w-2 h-2 rounded-full bg-amber-400 inline-block"></span>Patient Already Booked</span>,
              <span class="inline-flex items-center gap-1 ml-1"><span class="w-2 h-2 rounded-full bg-slate-300 inline-block"></span>Doctor Not Visiting</span>.
            </li>
            <li>Optionally add a <strong class="text-clinic-900">reason for visit</strong> and any internal <strong class="text-clinic-900">notes</strong> (notes are never shown to the patient).</li>
            <li>Click <strong class="text-clinic-900">Book Appointment</strong>. If the patient has an email on file, they're sent a confirmation automatically.</li>
          </ol>
        </div>
      </section>

      <!-- 8. Appointments list -->
      <section id="appointments" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">8</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">The appointments list</h2>
            <p class="text-sm text-clinic-700/70 mt-1">Where you manage every booking, from scheduling to payment.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/05-appointments.png" alt="Appointments list showing appointment number, patient, doctor, date, status badges and action icons">
          </div>
          <ul class="space-y-2.5 text-sm text-clinic-700/85 list-disc pl-5">
            <li>Each row has an <strong class="text-clinic-900">appointment number</strong> (<em>SDC000xxx</em>) you can search by, print, or read back to a patient over the phone.</li>
            <li>The <strong class="text-clinic-900">status</strong> badge shows where the visit stands: Scheduled &rarr; Completed (or Cancelled).</li>
            <li>Action icons, left to right: <strong class="text-clinic-900">print</strong> receipt, <strong class="text-clinic-900">✓ complete &amp; bill</strong>,
              <strong class="text-clinic-900">✕ cancel</strong>, <strong class="text-clinic-900">pencil</strong> edit, <strong class="text-clinic-900">trash</strong> delete.
              A completed row instead shows a <strong class="text-clinic-900">↺ reopen</strong> icon.</li>
          </ul>
        </div>
      </section>

      <!-- 9. Complete & bill -->
      <section id="billing-appt" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">9</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Completing &amp; billing a visit</h2>
            <p class="text-sm text-clinic-700/70 mt-1">Once the patient has been seen.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <div class="shot-frame">
            <div class="shot-bar">
              <span class="shot-dot bg-red-300"></span><span class="shot-dot bg-amber-300"></span><span class="shot-dot bg-green-300"></span>
            </div>
            <img src="assets/images/help/07-complete-bill.png" alt="Complete and Bill Appointment popup with consultation fee, a checklist of treatments and their prices, and a total">
          </div>
          <ol class="space-y-2.5 text-sm text-clinic-700/85 list-decimal pl-5">
            <li>On the Appointments list, click the <strong class="text-clinic-900">✓ (Complete &amp; Bill)</strong> icon on that patient's row.</li>
            <li>Tick every <strong class="text-clinic-900">treatment or service</strong> that was actually performed during the visit - the
              consultation fee is always included.</li>
            <li>Check the <strong class="text-clinic-900">Total</strong> at the bottom, then click <strong class="text-clinic-900">Confirm Payment</strong>.</li>
            <li>The appointment moves to <strong class="text-clinic-900">Completed</strong>, and a receipt is emailed to the patient automatically if they have an email on file.
              Prices are locked in at the moment you confirm, so a later change to a doctor's fee or a service's price never rewrites an old bill.</li>
          </ol>
        </div>
      </section>

      <!-- 10. Reopen -->
      <section id="reopen" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-clinic-800 text-clinic-50">10</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Made a mistake? Reopen the visit</h2>
            <p class="text-sm text-clinic-700/70 mt-1">Fixing a Completed or Cancelled appointment.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem] space-y-5">
          <p class="text-sm text-clinic-700/85">
            Marked the wrong appointment as complete, ticked the wrong services, or the patient asked to reschedule after
            checkout? Click the <strong class="text-clinic-900">↺ reopen</strong> icon on that row (it replaces the ✓ icon
            once a visit is Completed or Cancelled - see the reopened example in the appointments screenshot above).
          </p>
          <ol class="space-y-2.5 text-sm text-clinic-700/85 list-decimal pl-5">
            <li>Click <strong class="text-clinic-900">↺ Reopen</strong>.</li>
            <li>Pick the reason that fits - <em>marked complete/cancelled by mistake</em>, <em>wrong service(s) or amount billed</em>,
              <em>payment wasn't actually completed</em>, <em>patient requested to reschedule</em>, or <em>Other</em> (with a short note).</li>
            <li>Confirm. The appointment goes back to <strong class="text-clinic-900">Scheduled</strong> with its billing cleared, ready to be
              completed and billed correctly. Who reopened it, when, and why stays visible on the row so there's always a clear trail.</li>
          </ol>
        </div>
      </section>

      <!-- 11. Admin-only -->
      <section id="admin-only" class="scroll-mt-24">
        <div class="flex items-start gap-4 mb-5">
          <span class="step-num bg-coral-500 text-white">11</span>
          <div>
            <h2 class="font-display text-2xl text-clinic-900">Admin-only areas</h2>
            <p class="text-sm text-clinic-700/70 mt-1">A few sidebar items are only visible to admin accounts.</p>
          </div>
        </div>
        <div class="pl-0 sm:pl-[3.25rem]">
          <p class="text-sm text-clinic-700/85 mb-4">
            If you're logged in as staff, you won't see these in your sidebar at all - that's expected, not a bug.
            Ask an admin if you need something changed in one of them:
          </p>
          <div class="grid sm:grid-cols-3 gap-3.5">
            <div class="bg-white rounded-xl border border-clinic-100 p-4">
              <p class="text-sm font-semibold text-clinic-900 mb-1">Staffs</p>
              <p class="text-xs text-clinic-700/70">Creating and managing staff/admin logins.</p>
            </div>
            <div class="bg-white rounded-xl border border-clinic-100 p-4">
              <p class="text-sm font-semibold text-clinic-900 mb-1">Services</p>
              <p class="text-xs text-clinic-700/70">The treatment catalog and its prices.</p>
            </div>
            <div class="bg-white rounded-xl border border-clinic-100 p-4">
              <p class="text-sm font-semibold text-clinic-900 mb-1">Billing</p>
              <p class="text-xs text-clinic-700/70">The clinic's full revenue ledger across all appointments.</p>
            </div>
          </div>
        </div>
      </section>

      <!-- 12. Need help -->
      <section id="need-help" class="scroll-mt-24">
        <div class="bg-clinic-900 rounded-2xl p-7 sm:p-9 text-center">
          <h2 class="font-display text-2xl text-white mb-2">Still stuck on something?</h2>
          <p class="text-sm text-clinic-50/70 max-w-md mx-auto mb-6">
            Ask the admin who set up your account - they can check your permissions, reset your password, or walk you
            through anything this guide didn't cover.
          </p>
          <a href="login.jsp" class="inline-flex items-center gap-2 bg-white text-clinic-900 text-sm font-medium rounded-xl px-5 py-2.5 hover:bg-clinic-50 transition">
            Back to Login
            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M17.25 8.25 21 12m0 0-3.75 3.75M21 12H3" />
            </svg>
          </a>
        </div>
      </section>

    </div>
  </div>

  <script>
    // Scroll-spy for the "On this page" nav. Rather than IntersectionObserver
    // (whose fixed viewport band misses short sections and races with the
    // click handler's own state), this tracks which section's top has most
    // recently passed a fixed reference line near the top of the viewport -
    // the same logic drives both scrolling and clicking, so nothing fights.
    (function () {
      var tocLinks = Array.prototype.slice.call(document.querySelectorAll('.toc-link'));
      var sections = tocLinks
        .map(function (link) { return document.querySelector(link.getAttribute('href')); })
        .filter(Boolean);
      if (!sections.length) return;

      var REFERENCE_OFFSET = 130; // px from the top of the viewport (clears the sticky header)

      function setActive(id) {
        tocLinks.forEach(function (link) {
          link.classList.toggle('active', link.getAttribute('href') === '#' + id);
        });
      }

      function updateActiveFromScroll() {
        var scrollY = window.scrollY;
        // The last section(s) can be too short/near the bottom of the page for
        // their top to ever reach REFERENCE_OFFSET (there's no more room to
        // scroll past them) - cap each section's activation point at the page's
        // max scroll so they still get picked up once the user reaches the bottom.
        var maxScroll = document.documentElement.scrollHeight - window.innerHeight;
        var current = sections[0];
        for (var i = 0; i < sections.length; i++) {
          var sectionTop = sections[i].getBoundingClientRect().top + scrollY;
          var activationY = Math.min(sectionTop - REFERENCE_OFFSET, maxScroll);
          if (scrollY >= activationY) {
            current = sections[i];
          } else {
            break;
          }
        }
        setActive(current.id);
      }

      var ticking = false;
      window.addEventListener('scroll', function () {
        if (ticking) return;
        ticking = true;
        window.requestAnimationFrame(function () {
          updateActiveFromScroll();
          ticking = false;
        });
      }, { passive: true });

      tocLinks.forEach(function (link) {
        link.addEventListener('click', function () {
          setActive(link.getAttribute('href').slice(1));
        });
      });

      updateActiveFromScroll();
    })();
  </script>

</body>
</html>
