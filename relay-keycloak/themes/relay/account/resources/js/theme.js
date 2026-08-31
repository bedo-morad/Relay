(function () {
  'use strict';

  var STORAGE_KEY = 'relay-theme';
  var DARK_CLASS = 'pf-v5-theme-dark';

  function getStoredTheme() {
    try { return localStorage.getItem(STORAGE_KEY); } catch (e) { return null; }
  }

  function resolveTheme() {
    var s = getStoredTheme();
    if (s === 'light' || s === 'dark') return s;
    return (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) ? 'light' : 'dark';
  }

  function applyTheme(mode) {
    var el = document.documentElement;
    el.setAttribute('data-relay-theme', mode);
    if (mode === 'dark') el.classList.add(DARK_CLASS);
    else el.classList.remove(DARK_CLASS);
    el.themeMode = mode;
    updateLogo(mode);
  }

  function updateLogo(mode) {
    var brand = document.querySelector('.pf-v5-c-brand');
    if (!brand) brand = document.querySelector('.pf-v5-c-masthead__brand img');
    if (!brand) brand = document.querySelector('header img');
    if (!brand || !brand.getAttribute('src')) return;
    var src = brand.getAttribute('src');
    var isKeycloak = src.toLowerCase().indexOf('keycloak') !== -1;
    var isLightLogo = src.indexOf('relay-logo-light') !== -1;
    var isRelayLogo = src.indexOf('relay-logo') !== -1;
    var base = src.substring(0, src.lastIndexOf('/') + 1);
    var targetSrc = null;

    if (isKeycloak) {
      // Replace Keycloak default logo with Relay logo matching current theme
      targetSrc = base + (mode === 'light' ? 'relay-logo-light.svg' : 'relay-logo.svg');
      // If base looks wrong (e.g., absolute keycloak public assets), use our resourceUrl
      if (base.indexOf('keycloak') !== -1 || base.indexOf('public') !== -1) {
        // Try to infer resourceUrl from environment or from styles
        var envEl = document.getElementById('environment');
        if (envEl) {
          try {
            var env = JSON.parse(envEl.textContent);
            if (env.resourceUrl) targetSrc = env.resourceUrl + '/img/' + (mode === 'light' ? 'relay-logo-light.svg' : 'relay-logo.svg');
          } catch (e) {}
        }
        if (!targetSrc || targetSrc.indexOf('keycloak') !== -1) {
          // fallback to relative
          targetSrc = './resources/img/' + (mode === 'light' ? 'relay-logo-light.svg' : 'relay-logo.svg');
        }
      }
      brand.setAttribute('src', targetSrc);
      brand.setAttribute('alt', 'Relay');
      return;
    }

    if (!isRelayLogo) return;

    if (mode === 'light' && !isLightLogo) {
      targetSrc = src.replace('relay-logo.svg', 'relay-logo-light.svg');
      if (targetSrc === src) targetSrc = base + 'relay-logo-light.svg';
      brand.setAttribute('src', targetSrc);
    } else if (mode === 'dark' && isLightLogo) {
      targetSrc = src.replace('relay-logo-light.svg', 'relay-logo.svg');
      brand.setAttribute('src', targetSrc);
    }
  }

  function watchBrandLogo() {
    var observer = new MutationObserver(function () {
      var mode = document.documentElement.getAttribute('data-relay-theme') || resolveTheme();
      updateLogo(mode);
    });
    var app = document.getElementById('app') || document.body;
    if (app) observer.observe(app, { childList: true, subtree: true });
  }

  function syncFromStorage() {
    applyTheme(resolveTheme());
  }

  // Keep data-relay-theme and PF class in sync if something else toggles PF class
  function observeClassChanges() {
    var el = document.documentElement;
    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (m) {
        if (m.attributeName !== 'class') return;
        var hasDark = el.classList.contains(DARK_CLASS);
        var current = el.getAttribute('data-relay-theme');
        var expected = hasDark ? 'dark' : 'light';
        // Only correct if mismatch and no explicit storage (avoid fighting user toggle from other tab)
        var stored = getStoredTheme();
        if (stored === 'light' || stored === 'dark') {
          if (current !== stored) applyTheme(stored);
          return;
        }
        if (current !== expected) el.setAttribute('data-relay-theme', expected);
      });
    });
    observer.observe(el, { attributes: true, attributeFilter: ['class'] });
  }

  function init() {
    syncFromStorage();
    observeClassChanges();
    watchBrandLogo();
    // try again shortly after React mounts
    setTimeout(function () { updateLogo(resolveTheme()); }, 800);
    setTimeout(function () { updateLogo(resolveTheme()); }, 2000);

    // Follow system changes when no explicit preference stored
    if (window.matchMedia) {
      var mq = window.matchMedia('(prefers-color-scheme: dark)');
      var handler = function (e) {
        var stored = getStoredTheme();
        if (stored === 'light' || stored === 'dark') return;
        applyTheme(e.matches ? 'dark' : 'light');
      };
      if (mq.addEventListener) mq.addEventListener('change', handler);
      else if (mq.addListener) mq.addListener(handler);
    }

    // Cross-tab sync when login page writes localStorage
    window.addEventListener('storage', function (e) {
      if (e.key !== STORAGE_KEY) return;
      syncFromStorage();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
