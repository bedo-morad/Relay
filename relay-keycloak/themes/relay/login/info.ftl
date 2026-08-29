<#import "template.ftl" as layout>

<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        <#if messageHeader??>
            ${kcSanitize(msg(messageHeader))?no_esc}
        <#else>
            ${message.summary}
        </#if>
    <#elseif section = "form">
        <div id="kc-info-message">
            <p class="relay-info__text">${message.summary}<#if requiredActions??><#list requiredActions>: <b><#items as reqActionItem>${kcSanitize(msg("requiredAction.${reqActionItem}"))?no_esc}<#sep>, </#items></b></#list></#if></p>
            <#if skipLink??>
            <#else>
                <#if pageRedirectUri?has_content>
                    <p><a href="${pageRedirectUri}" class="relay-info__register">${msg("backToApplication")}</a></p>
                <#elseif actionUri?has_content>
                    <p><a href="${actionUri}" class="relay-info__register">${msg("proceedWithAction")}</a></p>
                <#elseif (client.baseUrl)?has_content>
                    <p><a href="${client.baseUrl}" class="relay-info__register">${msg("backToApplication")}</a></p>
                </#if>
            </#if>
        </div>
    </#if>
</@layout.registrationLayout>
