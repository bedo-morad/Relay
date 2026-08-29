<#import "template.ftl" as layout>

<@layout.registrationLayout displayInfo=true displayMessage=false; section>
    <#if section = "header">
        ${msg("welcomeTitle")!''}
    <#elseif section = "info">
        <#if messageHeader??>
            <span class="relay-info__text">${msg(messageHeader)}</span>
        <#elseif properties?? && properties.message??>
            <span class="relay-info__text">${properties.message}</span>
        </#if>
    </#if>
</@layout.registrationLayout>
