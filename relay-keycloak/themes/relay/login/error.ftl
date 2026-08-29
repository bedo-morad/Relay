<#import "template.ftl" as layout>

<@layout.registrationLayout displayInfo=false; section>
    <#if section = "header">
        ${msg("errorTitle")}
    <#elseif section = "form">
        <div class="relay-form__submit">
            <a href="${url.loginUrl}" class="relay-button relay-button--primary">${msg("backToLogin")}</a>
        </div>
    </#if>
</@layout.registrationLayout>
