<#import "field.ftl" as field>
<#macro userProfileFormFields>
	<#list profile.attributes as attribute>
		<#if attribute.name=='locale' && realm.internationalizationEnabled && locale.currentLanguageTag?has_content>
			<input type="hidden" id="${attribute.name}" name="${attribute.name}" value="${locale.currentLanguageTag}"/>
		<#else>
			<@field.group name=attribute.name label=advancedMsg(attribute.displayName!'') error=messagesPerField.get(attribute.name) required=attribute.required>
				<@inputFieldByType attribute=attribute/>
			</@field.group>
		</#if>
	</#list>
</#macro>

<#macro inputFieldByType attribute>
	<#switch attribute.annotations.inputType!''>
	<#case 'textarea'>
		<@textareaTag attribute=attribute/>
		<#break>
	<#case 'select'>
	<#case 'multiselect'>
		<@selectTag attribute=attribute/>
		<#break>
	<#case 'select-radiobuttons'>
	<#case 'multiselect-checkboxes'>
		<@inputTagSelects attribute=attribute/>
		<#break>
	<#default>
		<#if attribute.multivalued && attribute.values?has_content>
			<#list attribute.values as value>
				<@inputTag attribute=attribute value=value!''/>
			</#list>
		<#else>
			<@inputTag attribute=attribute value=(attribute.value!attribute.defaultValue!'')/>
		</#if>
	</#switch>
</#macro>

<#macro inputTag attribute value>
	<input type="<@inputTagType attribute=attribute/>" id="${attribute.name}" name="${attribute.name}" value="${(value!'')}" class="relay-field__input"
		aria-invalid="<#if messagesPerField.existsError(attribute.name)>true</#if>"
		<#if attribute.readOnly>disabled</#if>
		<#if attribute.autocomplete??>autocomplete="${attribute.autocomplete}"</#if>
		<#if attribute.annotations.inputTypePlaceholder??>placeholder="${advancedMsg(attribute.annotations.inputTypePlaceholder)}"</#if>
		<#if attribute.annotations.inputTypePattern??>pattern="${attribute.annotations.inputTypePattern}"</#if>
		<#if attribute.annotations.inputTypeSize??>size="${attribute.annotations.inputTypeSize}"</#if>
		<#if attribute.annotations.inputTypeMaxlength??>maxlength="${attribute.annotations.inputTypeMaxlength}"</#if>
		<#if attribute.annotations.inputTypeMinlength??>minlength="${attribute.annotations.inputTypeMinlength}"</#if>
		<#if attribute.annotations.inputTypeMax??>max="${attribute.annotations.inputTypeMax}"</#if>
		<#if attribute.annotations.inputTypeMin??>min="${attribute.annotations.inputTypeMin}"</#if>
		<#if attribute.annotations.inputTypeStep??>step="${attribute.annotations.inputTypeStep}"</#if>
		<#list attribute.html5DataAnnotations as key, value>
			data-${key}="${value}"
		</#list>
	/>
</#macro>

<#macro inputTagType attribute>
	<#compress>
	<#if attribute.annotations.inputType??>
		<#if attribute.annotations.inputType?starts_with("html5-")>
			${attribute.annotations.inputType[6..]}
		<#else>
			${attribute.annotations.inputType}
		</#if>
	<#else>
	text
	</#if>
	</#compress>
</#macro>

<#macro textareaTag attribute>
	<textarea id="${attribute.name}" name="${attribute.name}" class="relay-field__input"
		aria-invalid="<#if messagesPerField.existsError(attribute.name)>true</#if>"
		<#if attribute.readOnly>disabled</#if>
		<#if attribute.annotations.inputTypeCols??>cols="${attribute.annotations.inputTypeCols}"</#if>
		<#if attribute.annotations.inputTypeRows??>rows="${attribute.annotations.inputTypeRows}"</#if>
		<#if attribute.annotations.inputTypeMaxlength??>maxlength="${attribute.annotations.inputTypeMaxlength}"</#if>
	>${(attribute.value!attribute.defaultValue!'')}</textarea>
</#macro>

<#macro selectTag attribute>
	<select id="${attribute.name}" name="${attribute.name}" class="relay-field__input"
		aria-invalid="<#if messagesPerField.existsError(attribute.name)>true</#if>"
		<#if attribute.readOnly>disabled</#if>
		<#if attribute.annotations.inputType=='multiselect'>multiple</#if>
		<#if attribute.annotations.inputTypeSize??>size="${attribute.annotations.inputTypeSize}"</#if>
	>
		<#if attribute.annotations.inputType=='select'>
			<option value=""></option>
		</#if>
		<#if attribute.annotations.inputOptionsFromValidation?? && attribute.validators[attribute.annotations.inputOptionsFromValidation]?? && attribute.validators[attribute.annotations.inputOptionsFromValidation].options??>
			<#assign options=attribute.validators[attribute.annotations.inputOptionsFromValidation].options>
		<#elseif attribute.validators.options?? && attribute.validators.options.options??>
			<#assign options=attribute.validators.options.options>
		<#else>
			<#assign options=[]>
		</#if>
		<#assign selectedValues = attribute.values![]>
		<#if !selectedValues?has_content && (attribute.defaultValue??)>
			<#assign selectedValues = [attribute.defaultValue]>
		</#if>
		<#list options as option>
			<option value="${option}" <#if selectedValues?seq_contains(option)>selected</#if>><@selectOptionLabelText attribute=attribute option=option/></option>
		</#list>
	</select>
</#macro>

<#macro inputTagSelects attribute>
	<#if attribute.annotations.inputType=='select-radiobuttons'>
		<#assign inputType='radio'>
	<#else>
		<input type="hidden" id="${attribute.name}-empty" name="${attribute.name}" value=""/>
		<#assign inputType='checkbox'>
	</#if>
	<#if attribute.annotations.inputOptionsFromValidation?? && attribute.validators[attribute.annotations.inputOptionsFromValidation]?? && attribute.validators[attribute.annotations.inputOptionsFromValidation].options??>
		<#assign options=attribute.validators[attribute.annotations.inputOptionsFromValidation].options>
	<#elseif attribute.validators.options?? && attribute.validators.options.options??>
		<#assign options=attribute.validators.options.options>
	<#else>
		<#assign options=[]>
	</#if>
	<#assign selectedValues = attribute.values![]>
	<#if !selectedValues?has_content && (attribute.defaultValue??)>
		<#assign selectedValues = [attribute.defaultValue]>
	</#if>
	<#list options as option>
		<label class="relay-checkbox" for="${attribute.name}-${option}">
			<input type="${inputType}" id="${attribute.name}-${option}" name="${attribute.name}" value="${option}" class="relay-checkbox__input"
				aria-invalid="<#if messagesPerField.existsError(attribute.name)>true</#if>"
				<#if attribute.readOnly>disabled</#if>
				<#if selectedValues?seq_contains(option)>checked</#if>
			/>
			<span class="relay-checkbox__label"><@selectOptionLabelText attribute=attribute option=option/></span>
		</label>
	</#list>
</#macro>

<#macro selectOptionLabelText attribute option>
	<#compress>
	<#if attribute.annotations.inputOptionLabels??>
		${advancedMsg(attribute.annotations.inputOptionLabels[option]!option)}
	<#else>
		<#if attribute.annotations.inputOptionLabelsI18nPrefix??>
			${msg(attribute.annotations.inputOptionLabelsI18nPrefix + '.' + option)}
		<#else>
			${option}
		</#if>
	</#if>
	</#compress>
</#macro>
