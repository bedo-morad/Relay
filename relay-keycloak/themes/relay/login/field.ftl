<#macro group name label error="" required=false>
<div class="relay-field">
  <label for="${name}" class="relay-field__label">
    <span>${label}</span>
    <#if required>
      <span class="relay-field__required" aria-hidden="true">*</span>
    </#if>
  </label>
  <#nested>
  <#if error?has_content>
    <span class="relay-field__error">${error}</span>
  </#if>
</div>
</#macro>

<#macro input name label value="" required=false autocomplete="off" fieldName=name error=messagesPerField.get(fieldName) autofocus=false>
<div class="relay-field">
  <label for="${name}" class="relay-field__label">${label}</label>
  <input id="${name}" name="${name}" value="${value}" type="text" autocomplete="${autocomplete}" <#if autofocus>autofocus</#if> class="relay-field__input" aria-invalid="<#if error?has_content>true</#if>">
  <#if error?has_content>
    <span class="relay-field__error">${error}</span>
  </#if>
</div>
</#macro>

<#macro password name label value="" required=false autocomplete="off" fieldName=name error=messagesPerField.get(fieldName) autofocus=false>
<div class="relay-field">
  <label for="${name}" class="relay-field__label">${label}</label>
  <div class="relay-field__input-wrap">
    <input id="${name}" name="${name}" value="${value}" type="password" autocomplete="${autocomplete}" <#if autofocus>autofocus</#if> class="relay-field__input" aria-invalid="<#if error?has_content>true</#if>">
    <button type="button" class="relay-field__toggle" tabindex="-1" aria-label="${msg("showPassword")}" data-password-toggle data-target="${name}">
      <svg class="relay-field__eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
      </svg>
      <svg class="relay-field__eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
        <line x1="1" y1="1" x2="23" y2="23"/>
      </svg>
    </button>
  </div>
  <#if error?has_content>
    <span class="relay-field__error">${error}</span>
  </#if>
  <#nested>
</div>
</#macro>

<#macro helpers>
<div class="relay-field__helpers">
  <#nested>
</div>
</#macro>

<#macro checkbox name label value=false required=false>
<label class="relay-checkbox" for="${name}">
  <input type="checkbox" id="${name}" name="${name}" <#if value>checked</#if> class="relay-checkbox__input">
  <span class="relay-checkbox__label">${label}</span>
  <#if required>
    <span class="relay-checkbox__required" aria-hidden="true">*</span>
  </#if>
</label>
</#macro>
