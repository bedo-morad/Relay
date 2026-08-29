<#import "template.ftl" as layout>
<#import "field.ftl" as field>

<@layout.registrationLayout displayMessage=false displayRequiredFields=true; section>
    <#if section = "header">
        ${msg("updatePasswordTitle")}
    <#elseif section = "form">
        <form class="relay-form" action="${url.loginAction}" method="post">
            <@field.password name="password-new" label=msg("passwordNew") required=true autocomplete="new-password" />
            <@field.password name="password-confirm" label=msg("passwordConfirm") required=true autocomplete="new-password" />
            <div class="relay-form__submit">
                <button class="relay-button relay-button--primary" type="submit" id="kc-submit">${msg("doSubmit")}</button>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>
