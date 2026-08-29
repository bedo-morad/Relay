<#import "template.ftl" as layout>

<@layout.registrationLayout; section>
    <#if section = "header">
        ${msg("confirmLinkIdpTitle")}
    <#elseif section = "form">
        <form class="relay-form" action="${url.loginAction}" method="post">
            <#if !hideReviewButton?has_content>
                <div class="relay-form__submit">
                    <button class="relay-button relay-button--link" name="submitAction" id="updateProfile" value="updateProfile">${msg("confirmLinkIdpReviewProfile")}</button>
                </div>
            </#if>
            <div class="relay-form__submit">
                <button class="relay-button relay-button--primary" name="submitAction" id="linkAccount" value="linkAccount">${msg("confirmLinkIdpContinue", idpDisplayName)}</button>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>
