<#import "template.ftl" as layout>
<#import "user-profile-commons.ftl" as userProfileCommons>

<@layout.registrationLayout displayMessage=messagesPerField.exists('global') displayRequiredFields=true; section>
    <#if section = "header">
        ${msg("loginIdpReviewProfileTitle")}
    <#elseif section = "form">
        <form id="kc-idp-review-profile-form" class="relay-form" action="${url.loginAction}" method="post">
            <@userProfileCommons.userProfileFormFields/>
            <div class="relay-form__submit">
                <button class="relay-button relay-button--primary" type="submit">${msg("doSubmit")}</button>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>
