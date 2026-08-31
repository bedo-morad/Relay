<#import "theme-resources.ftl" as themeResourceTags>
<!doctype html>
<html lang="${locale}" dir="${localeDir}">
  <head>
    <meta charset="utf-8">
    <#if themeResources?? && themeResources.favicons?has_content>
      <@themeResourceTags.renderFavicons themeResources.favicons resourceUrl />
    <#else>
      <link rel="icon" type="${properties.favIconType!'image/svg+xml'}" href="${resourceUrl}${properties.favIcon!'/img/favicon.svg'}">
      <link rel="icon" type="image/x-icon" href="${resourceUrl}/img/favicon.ico">
    </#if>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light${darkMode?then(' dark', '')}">
    <meta name="description" content="${properties.description!'The Account Console is a web-based interface for managing your account.'}">
    <title>${properties.title!'Account Management'}</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Tajawal:wght@400;500;700&display=swap" rel="stylesheet">

    <style>
      body {
        margin: 0;
      }
      body, #app {
        height: 100%;
      }
      .container {
        padding: 0;
        margin: 0;
        width: 100%;
      }
      .keycloak__loading-container {
        height: 100vh;
        width: 100%;
        color: #0F172A;
        background-color: #FDFBF6;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        margin: 0;
      }
      .pf-v5-theme-dark .keycloak__loading-container,
      [data-relay-theme="dark"] .keycloak__loading-container {
        color: #F8FAFC;
        background-color: #0B1220;
      }
      @media (prefers-color-scheme: dark) {
        .keycloak__loading-container {
          color: #F8FAFC;
          background-color: #0B1220;
        }
      }
      #loading-text {
        z-index: 1000;
        font-size: 20px;
        font-weight: 600;
        padding-top: 32px;
      }
    </style>

    <script type="importmap">
      {
        "imports": {
          "react": "${resourceCommonUrl}/vendor/react/react.production.min.js",
          "react/jsx-runtime": "${resourceCommonUrl}/vendor/react/react-jsx-runtime.production.min.js",
          "react-dom": "${resourceCommonUrl}/vendor/react-dom/react-dom.production.min.js"
        }
      }
    </script>

    <#-- Relay theme sync: localStorage 'relay-theme' overrides system, same as login theme -->
    <script type="module" async blocking="render">
      (function () {
        var STORAGE_KEY = 'relay-theme';
        var DARK_CLASS = "${properties.kcDarkModeClass!'pf-v5-theme-dark'}";
        var el = document.documentElement;
        var stored = null;
        try { stored = localStorage.getItem(STORAGE_KEY); } catch (e) {}
        var mode = (stored === 'light' || stored === 'dark')
          ? stored
          : (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
        el.setAttribute('data-relay-theme', mode);
        if (mode === 'dark') {
          el.classList.add(DARK_CLASS);
        } else {
          el.classList.remove(DARK_CLASS);
        }
        el.themeMode = mode;

        // If no explicit choice, follow system changes live
        if (stored !== 'light' && stored !== 'dark' && window.matchMedia) {
          var mq = window.matchMedia('(prefers-color-scheme: dark)');
          var onChange = function (e) {
            try {
              var s = null;
              try { s = localStorage.getItem(STORAGE_KEY); } catch (err) {}
              if (s === 'light' || s === 'dark') return;
            } catch (err) {}
            var m = e.matches ? 'dark' : 'light';
            el.setAttribute('data-relay-theme', m);
            if (m === 'dark') el.classList.add(DARK_CLASS); else el.classList.remove(DARK_CLASS);
            el.themeMode = m;
          };
          if (mq.addEventListener) mq.addEventListener('change', onChange);
          else if (mq.addListener) mq.addListener(onChange);
        }

        // Cross-tab sync when login theme changes localStorage
        window.addEventListener('storage', function (e) {
          if (e.key !== STORAGE_KEY) return;
          var m = (e.newValue === 'light' || e.newValue === 'dark')
            ? e.newValue
            : (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
          el.setAttribute('data-relay-theme', m);
          if (m === 'dark') el.classList.add(DARK_CLASS); else el.classList.remove(DARK_CLASS);
          el.themeMode = m;
        });
      })();
    </script>

    <#if !isSecureContext>
      <script type="module" src="${resourceCommonUrl}/vendor/web-crypto-shim/web-crypto-shim.js"></script>
    </#if>
    <#if devServerUrl?has_content>
      <script type="module">
        import { injectIntoGlobalHook } from "${devServerUrl}/@react-refresh";
        injectIntoGlobalHook(window);
        window.$RefreshReg$ = () => {};
        window.$RefreshSig$ = () => (type) => type;
      </script>
      <script type="module">
        import { inject } from "${devServerUrl}/@vite-plugin-checker-runtime";
        inject({
          overlayConfig: {},
          base: "/",
        });
      </script>
      <script type="module" src="${devServerUrl}/@vite/client"></script>
      <script type="module" src="${devServerUrl}/src/main.tsx"></script>
    </#if>
    <#if entryStyles?has_content>
      <#list entryStyles as style>
        <link rel="stylesheet" href="${resourceUrl}/${style}">
      </#list>
    </#if>
    <#if themeResources?? && themeResources.styles?has_content>
      <@themeResourceTags.renderStyles themeResources.styles resourceUrl />
    <#elseif properties.styles?has_content>
      <#list properties.styles?split(' ') as style>
        <link rel="stylesheet" href="${resourceUrl}/${style}">
      </#list>
    </#if>
    <#if entryScript?has_content>
      <script type="module" src="${resourceUrl}/${entryScript}"></script>
    </#if>
    <#if themeResources?? && themeResources.scripts?has_content>
      <@themeResourceTags.renderScripts themeResources.scripts resourceUrl "module" />
    <#elseif properties.scripts?has_content>
      <#list properties.scripts?split(' ') as script>
        <script type="module" src="${resourceUrl}/${script}"></script>
      </#list>
    </#if>
    <#if entryImports?has_content>
      <#list entryImports as import>
        <link rel="modulepreload" href="${resourceUrl}/${import}">
      </#list>
    </#if>
  </head>
  <body data-page-id="account">
    <div id="app">
      <main class="container">
        <div class="keycloak__loading-container">
          <svg class="pf-v5-c-spinner pf-m-xl" role="progressbar" aria-valuetext="Loading..." viewBox="0 0 100 100" aria-label="Contents">
            <circle class="pf-v5-c-spinner__path" cx="50" cy="50" r="45" fill="none"></circle>
          </svg>
          <div>
            <p id="loading-text">Loading the Account Console</p>
          </div>
        </div>
      </main>
    </div>
    <noscript>JavaScript is required to use the Account Console.</noscript>
    <script id="environment" type="application/json">
      {
        "serverBaseUrl": "${serverBaseUrl}",
        "authUrl": "${authUrl}",
        "authServerUrl": "${authServerUrl}",
        "realm": "${realm.name}",
        "clientId": "${clientId}",
        "resourceUrl": "${resourceUrl}",
        "logo": "${properties.logo!""}",
        "logoUrl": "${properties.logoUrl!""}",
        "baseUrl": "${baseUrl}",
        "locale": "${locale}",
        "referrerName": "${referrerName!""}",
        "referrerUrl": "${referrer_uri!""}",
        "features": {
          "isRegistrationEmailAsUsername": ${realm.registrationEmailAsUsername?c},
          "isEditUserNameAllowed": ${realm.editUsernameAllowed?c},
          "isInternationalizationEnabled": ${realm.isInternationalizationEnabled()?c},
          "isLinkedAccountsEnabled": ${isLinkedAccountsEnabled?c},
          "isMyResourcesEnabled": ${(realm.userManagedAccessAllowed && isAuthorizationEnabled)?c},
          "isViewOrganizationsEnabled": ${isViewOrganizationsEnabled?c},
          "deleteAccountAllowed": ${deleteAccountAllowed?c},
          "updateEmailFeatureEnabled": ${updateEmailFeatureEnabled?c},
          "updateEmailActionEnabled": ${updateEmailActionEnabled?c},
          "isViewApplicationsEnabled": ${isViewApplicationsEnabled?c},
          "isViewGroupsEnabled": ${isViewGroupsEnabled?c},
          "isOid4VciEnabled": ${isOid4VciEnabled?c}
        },
        "scope": "${scope!""}"
      }
    </script>
  </body>
</html>
