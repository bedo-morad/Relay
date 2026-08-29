<#macro actionGroup horizontal=false>
<div class="relay-form__actions">
  <#nested>
</div>
</#macro>

<#macro button label id="" name="" type="primary" fullWidth=true class=[]>
<button class="relay-button relay-button--${type}" name="${name}" id="${id}" type="submit">
  ${msg(label)}
</button>
</#macro>

<#macro buttonLink href label id="" class=[]>
<a id="${id}" href="${href}" class="relay-button relay-button--link">${msg(label)}</a>
</#macro>

<#macro loginButton>
<@actionGroup>
  <@button id="kc-login" name="login" label="doLogIn" />
</@actionGroup>
</#macro>
