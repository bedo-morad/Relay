<#import "footer.ftl" as loginFooter>

<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
    <!DOCTYPE html>
    <html lang="${lang}"<#if realm.internationalizationEnabled> dir="${(locale.rtl)?then('rtl','ltr')}"</#if>>

    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="color-scheme" content="light${darkMode?then(' dark', '')}">
        <title>${title!}</title>

        <link rel="icon" type="image/svg+xml" href="${url.resourcesPath}/img/favicon.svg">
        <link rel="icon" type="image/x-icon" href="${url.resourcesPath}/img/favicon.ico">

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Tajawal:wght@400;500;700&display=swap"
              rel="stylesheet">

        <link href="${url.resourcesPath}/css/styles.css" rel="stylesheet">

        <script>
            (function () {
                var d = document.documentElement, s = localStorage.getItem('relay-theme'),
                    m = s === 'light' || s === 'dark' ? s : (window.matchMedia && window.matchMedia('(prefers-color-scheme:light)').matches ? 'light' : 'dark');
                d.setAttribute('data-relay-theme', m);
                if (m === 'dark') d.classList.add('pf-v5-theme-dark');
                d.themeMode = m;
            })();
        </script>
        <style>
            .relay-theme-toggle__sun {
                display: none !important
            }

            .relay-theme-toggle__moon {
                display: block !important
            }

            [data-relay-theme="light"] .relay-theme-toggle__sun {
                display: block !important
            }

            [data-relay-theme="light"] .relay-theme-toggle__moon {
                display: none !important
            }
        </style>
    </head>

    <body class="relay-body">
    <div class="relay-page">
        <div class="relay-card">
            <header class="relay-card__header">
                <a href="${url.loginRestartFlowUrl}" class="relay-brand" aria-label="Relay">
                    <svg class="relay-brand__icon" viewBox="0 0 32 32" width="28" height="28" aria-hidden="true">
                        <rect class="relay-pill1" x="5" y="8" width="14" height="10" rx="5" fill="none"
                              stroke-width="2.2"/>
                        <rect class="relay-pill2" x="13" y="14" width="14" height="10" rx="5" fill="none"
                              stroke-width="2.2"/>
                    </svg>
                    <span class="relay-brand__wordmark">Relay</span>
                </a>
                <div class="relay-card__header-actions">
                    <#if realm.internationalizationEnabled && locale.supported?size gt 1>
                        <div class="relay-locale">
                            <label for="relay-locale-select" class="sr-only">${msg("languages")}</label>
                            <select id="relay-locale-select" class="relay-locale__select"
                                    onchange="if(this.value)window.location.href=this.value">
                                <#list locale.supported?sort_by("label") as l>
                                    <option value="${l.url}" ${(l.languageTag == locale.currentLanguageTag)?then('selected','')}>${l.label}</option>
                                </#list>
                            </select>
                        </div>
                    </#if>
                    <button type="button" class="relay-theme-toggle" aria-label="Toggle color theme">
                        <svg class="relay-theme-toggle__sun" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="12" cy="12" r="4"/>
                            <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>
                        </svg>
                        <svg class="relay-theme-toggle__moon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                        </svg>
                    </button>
                </div>
            </header>

            <main class="relay-card__main">
                <h1 class="relay-title" id="kc-page-title"><#nested "header"></h1>


                <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                    <div class="relay-alert relay-alert--${(message.type = 'error')?then('danger', message.type)}"
                         role="alert">
                        <span class="relay-alert__text">${message.summary}</span>
                    </div>
                </#if>

                <#nested "socialProviders">

                <#nested "form">

                <#if displayInfo>
                    <div class="relay-info">
                        <#nested "info">
                    </div>
                </#if>
            </main>
        </div>

        <footer class="relay-footer">
            <@loginFooter.content/>
        </footer>
    </div>
    <script src="${url.resourcesPath}/js/theme.js"></script>
    </body>
    </html>
</#macro>
