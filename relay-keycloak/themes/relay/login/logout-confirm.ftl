<#import "template.ftl" as layout>

<@layout.registrationLayout displayMessage=false; section>
    <#if section = "header">
        ${msg("logoutConfirmTitle")}
    <#elseif section = "form">
        <div class="relay-alert relay-alert--warning">
            <span class="relay-alert__text">${msg("logoutConfirmHeader")}</span>
        </div>

        <form class="relay-form" action="${url.logoutConfirmAction}" onsubmit="confirmLogout.disabled = true; return true;" method="POST">
            <input type="hidden" name="session_code" value="${logoutConfirm.code}">
            <div class="relay-form__submit">
                <button class="relay-button relay-button--primary" name="confirmLogout" id="kc-logout" type="submit">${msg("doLogout")}</button>
            </div>
        </form>

        <#if logoutConfirm.skipLink>
        <#else>
            <#if (client.baseUrl)?has_content>
                <div class="relay-info">
                    <span class="relay-info__register">
                        <a href="${client.baseUrl}">${msg("backToApplication")}</a>
                    </span>
                </div>
            </#if>
        </#if>
    </#if>
</@layout.registrationLayout>
