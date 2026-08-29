(function () {
  'use strict';

  var STORAGE_KEY = 'relay-theme';
  var DARK_CLASS  = 'pf-v5-theme-dark';

  /* ── Theme toggle ───────────────────────────────────────────── */

  function getTheme() {
    return document.documentElement.getAttribute('data-relay-theme') || 'dark';
  }

  function applyTheme(mode) {
    var el = document.documentElement;
    el.setAttribute('data-relay-theme', mode);
    if (mode === 'dark') {
      el.classList.add(DARK_CLASS);
    } else {
      el.classList.remove(DARK_CLASS);
    }
  }

  function bindThemeToggle() {
    var btn = document.querySelector('.relay-theme-toggle');
    if (!btn) return;
    btn.addEventListener('click', function () {
      var next = getTheme() === 'dark' ? 'light' : 'dark';
      applyTheme(next);
      forceIcons(next);
      try { localStorage.setItem(STORAGE_KEY, next); } catch (e) {}
    });
  }

  /* ── Password visibility ────────────────────────────────────── */

  function bindPasswordToggles() {
    document.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-password-toggle]');
      if (!btn) return;
      var target = btn.getAttribute('data-target');
      var input = target ? document.getElementById(target) : btn.closest('.relay-field__input-wrap')?.querySelector('input');
      if (!input) return;
      var isPassword = input.type === 'password';
      input.type = isPassword ? 'text' : 'password';
      btn.setAttribute('aria-label', isPassword ? 'Hide password' : 'Show password');
      var openEye  = btn.querySelector('.relay-field__eye-open');
      var closedEye = btn.querySelector('.relay-field__eye-closed');
      if (openEye && closedEye) {
        openEye.style.display  = isPassword ? 'none' : 'block';
        closedEye.style.display = isPassword ? 'block' : 'none';
      }
    });
  }

  /* ── Init ───────────────────────────────────────────────────── */

  function forceIcons(mode) {
    var sun  = document.querySelector('.relay-theme-toggle__sun');
    var moon = document.querySelector('.relay-theme-toggle__moon');
    if (sun)  sun.style.display  = mode === 'light' ? 'block' : 'none';
    if (moon) moon.style.display = mode === 'light' ? 'none'  : 'block';
    document.querySelectorAll('.relay-field__eye-closed').forEach(function(e) {
      e.style.display = 'none';
    });
    document.querySelectorAll('.relay-field__eye-open').forEach(function(e) {
      e.style.display = 'block';
    });
  }

  function init() {
    var stored = null;
    try { stored = localStorage.getItem(STORAGE_KEY); } catch (e) {}
    var mode = (stored === 'light' || stored === 'dark') ? stored : getTheme();
    applyTheme(mode);
    forceIcons(mode);
    bindThemeToggle();
    bindPasswordToggles();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
