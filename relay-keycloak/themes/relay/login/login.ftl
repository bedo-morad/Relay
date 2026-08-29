<#import "template.ftl" as layout>
<#import "field.ftl" as field>
<#import "social-providers.ftl" as identityProviders>

<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>

    <#if section = "header">
        ${msg("loginAccountTitle")}

    <#elseif section = "form">
        <#if realm.password>
            <form id="kc-form-login" class="relay-form" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post" novalidate="novalidate">
                <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>

                <#if !usernameHidden??>
                    <#assign label>
                        <#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>
                    </#assign>
                    <@field.input name="username" label=label error=messagesPerField.getFirstError('username','password')
                        autofocus=true autocomplete="${(enableWebAuthnConditionalUI?has_content)?then('username webauthn', 'username')}" value="${login.username!''}" />

                    <@field.password name="password" label=msg("password") error="" autofocus=usernameHidden?? autocomplete="current-password">
                        <@field.helpers>
                            <#if realm.resetPasswordAllowed>
                                <a href="${url.loginResetCredentialsUrl}" class="relay-field__link">${msg("doForgotPassword")}</a>
                            </#if>
                            <#if realm.rememberMe && !usernameHidden??>
                                <@field.checkbox name="rememberMe" label=msg("rememberMe") value=login.rememberMe?? />
                            </#if>
                        </@field.helpers>
                    </@field.password>
                <#else>
                    <@field.password name="password" label=msg("password") error="" autofocus=true autocomplete="current-password">
                        <@field.helpers>
                            <#if realm.resetPasswordAllowed>
                                <a href="${url.loginResetCredentialsUrl}" class="relay-field__link">${msg("doForgotPassword")}</a>
                            </#if>
                            <#if realm.rememberMe && !usernameHidden??>
                                <@field.checkbox name="rememberMe" label=msg("rememberMe") value=login.rememberMe?? />
                            </#if>
                        </@field.helpers>
                    </@field.password>
                </#if>

                <div class="relay-form__submit">
                    <button id="kc-login" name="login" type="submit" class="relay-button relay-button--primary">${msg("doLogIn")}</button>
                </div>
            </form>
        </#if>

    <#elseif section = "socialProviders">
        <#if realm.password && social.providers?? && social.providers?has_content>
            <@identityProviders.show social=social/>
        </#if>

    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div class="relay-info__register">
                ${msg("noAccount")} <a href="${url.registrationUrl}">${msg("doRegister")}</a>
            </div>
        </#if>
    </#if>

</@layout.registrationLayout>
