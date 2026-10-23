# SMTP demo

Sends mail with `n_smtpclient`, authenticating with an OAuth 2.0 access token from `n_cst_oauth2`. Open the `smtp demo` target in `PFC.pbw` and run it, or build it with `pwsh -File tools\build.ps1 -Target "smtp demo"`.

The window shows the three ways to get a token:

- **Authorization code (browser):** the user signs in in the default web browser, and the redirect comes back to `http://127.0.0.1:<port>/callback` (`n_cst_redirectlistener`). The app uses PKCE.
- **Device code:** the code is put on the clipboard and the sign-in page opens. The user can also sign in on another device.
- **Client credentials:** the application signs in with its own secret, without a user. This is Microsoft only.

The client keeps its token between messages. When the token expires, it uses the refresh token, so the user signs in only once. **Sign Out** forgets the tokens.

## Settings

**Save Settings** keeps the settings in the registry, so the demo can be shared without them. They are stored under `HKEY_CURRENT_USER\Software\PFC\SMTP Demo\microsoft` (or `\google`) as the values `Tenant`, `ClientID`, `ClientSecret`, `Mailbox` and `Recipient`. The client secret is stored as typed: this is a demo.

Leave **Host** empty to use the provider's server (`smtp.office365.com` or `smtp.gmail.com`, port 587, STARTTLS). **Log the SMTP session** writes the conversation with the server to `smtpdemo.log`.

## Microsoft Entra ID

1. In the Entra admin center, go to App registrations > New registration.
   - For a single tenant, enter its ID or domain in **Tenant**.
   - For a multitenant app, leave **Tenant** empty to use `common`.
2. Authentication: add the **Mobile and desktop applications** platform with the redirect URI `http://127.0.0.1` (Entra ignores the port). Also set **Allow public client flows** to Yes, for the device code flow.
3. API permissions: add **Office 365 Exchange Online > SMTP.Send** (delegated). The scope requested is `https://outlook.office.com/SMTP.Send offline_access`.
4. The mailbox must allow SMTP AUTH (Exchange admin center > the mailbox > Manage email apps > Authenticated SMTP).

For client credentials:

1. Add a client secret.
2. Add the application permission **Office 365 Exchange Online > SMTP.SendAsApp**, and grant admin consent.
3. Register the app's service principal in Exchange Online, and give it access to the mailbox (`New-ServicePrincipal`, `Add-MailboxPermission`).

The scope requested is `https://outlook.office365.com/.default`.

## Google

1. In the Google Cloud console, go to APIs & Services > Credentials > Create credentials > OAuth client ID. Choose the type **Desktop app**.
2. The Desktop app type has no redirect URI setting. Google accepts any `http://127.0.0.1` port for it.
3. Enter the client ID and the client secret. Google wants the secret in the token requests, even though it isn't secret in a desktop app.
4. OAuth consent screen: add the scope `https://mail.google.com/`. While the app is in Testing, add the mailbox as a test user.

Use the authorization code flow. Google's device code flow doesn't allow the Gmail scope, and Gmail has no client credentials flow.
