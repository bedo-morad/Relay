<#import "template.ftl" as layout>
<#import "field.ftl" as field>

<@layout.registrationLayout displayMessage=messagesPerField.exists('global') displayRequiredFields=true; section>

    <#if section = "header">
        ${msg("registerTitle")}

    <#elseif section = "form">
        <form id="kc-register-form" class="relay-form" action="${url.registrationAction}" method="post" novalidate="novalidate">

            <@field.input name="firstName" label=msg("firstName") autocomplete="given-name" required=true error=messagesPerField.get('firstName') autofocus=true />

            <@field.input name="lastName" label=msg("lastName") autocomplete="family-name" required=true error=messagesPerField.get('lastName') />

            <#if realm.registrationEmailAsUsername>
                <@field.input name="email" label=msg("email") autocomplete="email" required=true error=messagesPerField.get('email') />
            <#else>
                <@field.input name="username" label=msg("username") autocomplete="username" required=true error=messagesPerField.get('username') />
            </#if>

            <div class="relay-form__submit">
                <button class="relay-button relay-button--primary" type="submit" id="kc-submit">${msg("doRegister")}</button>
            </div>

            <div class="relay-info">
                <span class="relay-info__register">
                    <a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </span>
            </div>
        </form>
    </#if>

</@layout.registrationLayout>
