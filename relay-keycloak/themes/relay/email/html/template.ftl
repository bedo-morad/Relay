<#macro emailLayout>
<!DOCTYPE html>
<html lang="${locale.language}" dir="${(ltr)?then('ltr','rtl')}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>${subject!""}</title>
</head>
<body style="margin:0;padding:0;background-color:#F5F1EB;font-family:Arial,Helvetica,sans-serif;-webkit-font-smoothing:antialiased;-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%;">

<table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:#F5F1EB;">
  <tr>
    <td align="center" style="padding:48px 16px 40px;">

      <table role="presentation" width="600" cellspacing="0" cellpadding="0" border="0" style="max-width:600px;width:100%;">

        <tr>
          <td style="background-color:#0B1220;border-radius:16px 16px 0 0;padding:28px 36px 24px;">
            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
              <tr>
                <td valign="middle">
                  <svg width="36" height="36" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" style="display:block;border:0;outline:none;text-decoration:none;">
                    <rect width="32" height="32" rx="6" fill="#0B1220"/>
                    <rect x="5" y="8" width="14" height="10" rx="5" fill="none" stroke="#F8FAFC" stroke-width="2.6"/>
                    <rect x="13" y="14" width="14" height="10" rx="5" fill="none" stroke="#E8A42C" stroke-width="2.6"/>
                  </svg>
                </td>
                <td valign="middle" style="padding-left:14px;">
                  <span style="font-family:Arial,Helvetica,sans-serif;font-size:22px;font-weight:800;color:#F8FAFC;letter-spacing:-0.5px;text-decoration:none;">Relay</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <tr>
          <td style="background-color:#E8A42C;height:3px;font-size:0;line-height:0;">&nbsp;</td>
        </tr>

        <tr>
          <td style="background-color:#FFFFFF;padding:40px 40px 36px;border-radius:0 0 16px 16px;">
            <#nested>
          </td>
        </tr>

      </table>

      <table role="presentation" width="600" cellspacing="0" cellpadding="0" border="0" style="max-width:600px;width:100%;">
        <tr>
          <td style="padding:28px 16px 0;text-align:center;font-family:Arial,Helvetica,sans-serif;font-size:12px;line-height:1.6;color:#94A3B8;">
            <p style="margin:0;">This is an automated email. Please do not reply.</p>
          </td>
        </tr>
      </table>

    </td>
  </tr>
</table>

</body>
</html>
</#macro>
