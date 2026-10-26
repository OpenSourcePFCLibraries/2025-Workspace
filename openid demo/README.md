# OpenID Connect demo

Signs users in with an OpenID Connect identity provider, and secures the application with PFC security from the groups the provider reports. Add `openid demo.pbt` to the workspace (it is in `PFC.pbw`) and run it.

The settings are in `openiddemo.ini`: copy `openiddemo.ini.example` to it, in this folder, and fill in the values. `openiddemo.ini` is ignored by git, so its secrets stay local.

## The tabs

- **Identity Provider:** the endpoints, the client ID and secret, the scope and the claim with the groups, from the `[OpenID]` section. Change them to try other values; they aren't saved.
- **Sign In:** PFC's logon window, `w_openid_logon`, opened by `gnv_app.of_OpenIDLogonDlg`.
  - **Password grant:** the user types the user ID and password in the window.
  - **Authorization code flow with PKCE:** the user signs in in the default web browser, with MFA and single sign-on, and the redirect comes back to `http://127.0.0.1:<port>/callback`.

  The tab shows the user, the groups, the ID token's claims and the userinfo response. The groups come from the userinfo response, or else from the ID token.
- **OAuth 2.0 Flows:** the OAuth 2.0 service, `n_cst_oauth2`, which gets tokens for the application.
  - **Authorization code:** as above.
  - **Device code:** the code is put on the clipboard and the sign-in page opens. The user can also sign in on another device.
  - **Client credentials:** the application signs in with its own secret, without a user.
  - **Refresh the Token:** uses the refresh token, so the user signs in only once.
- **Groups and Security:** maps the provider's groups to PFC security groups with `n_cst_security.of_MapGroups` and the `[GroupMap]` section. A group not in the map is passed on unchanged; a group mapped to nothing (`name=`) isn't used. Type groups to try the mapping without signing in. **Apply Security** initializes PFC security for the signed-in user with the mapped groups (`of_InitSecurity`) and opens a window that applies it (`of_SetSecurity`).

## PFC security

Apply Security uses the security database in the `[Security]` section, the same database as the security administrator's `pfcsecad.ini`. Group membership comes from the identity provider, so the users don't need to be defined in the security database. The database supplies the groups and their settings.

1. Scan the demo with the security scanner: open `openid demo.pbt`. The scan adds the application `openiddemo`, and the controls of `w_openiddemo_secured` and its order columns.
2. In the security administrator, define the PFC groups that the map produces (`demo_users` and `demo_admins` in the example), or set `DefaultGroup`.
3. Set the groups' permissions on `w_openiddemo_secured`. For example, `demo_users` can't see the discount or delete orders.
4. Sign in, then click Apply Security.

## Authentik

1. Applications > Providers > Create an **OAuth2/OpenID Provider**:
   - **Client type:** Public, with no client secret.
   - **Redirect URIs:** the regular expression `http://127\.0\.0\.1:\d+/callback`.
   - **Scopes:** the openid, profile, email and offline_access scope mappings. Authentik's profile scope includes the `groups` claim.
2. Applications > Create an application with the slug `pfc-openid-demo`, using the provider. The endpoints are under `http://localhost:9000/application/o/`, as in `openiddemo.ini.example`.
3. Directory > Groups: create `pfc-demo-users` and `pfc-demo-admins`, and add users.
4. Optional extras:
   - **Device code flow:** set a device code flow in System > Brands > the brand > Default flows.
   - **Client credentials:** make the client confidential, and enter its secret.

## Microsoft Entra ID

1. In the Entra admin center, go to App registrations > New registration.
2. Authentication: add the **Mobile and desktop applications** platform with the redirect URI `http://127.0.0.1` (Entra ignores the port). Set **Allow public client flows** to Yes, for the device code flow and the password grant.
3. The groups:
   - **Token configuration:** add a groups claim (security groups). The groups are object IDs: map them in `[GroupMap]`.
   - **App roles:** alternatively, define app roles and set `GroupsClaim=roles`.
4. The endpoints are in `openiddemo.ini.example`; replace `<tenant>` with the tenant's ID or domain.
5. The password grant doesn't work for accounts that need MFA or sign in through another provider. Use the authorization code flow for them.

For client credentials:
- Add a client secret.
- Use the scope `https://graph.microsoft.com/.default`, which grants the application permissions given to the app.

## Google

1. In the Google Cloud console, go to APIs & Services > Credentials > Create credentials > OAuth client ID.
   - **Desktop app:** for the authorization code flow. Google accepts any `http://127.0.0.1` port for it.
   - **TVs and Limited Input devices:** for the device code flow.
2. Enter the client ID and the client secret. Google wants the secret in the token requests, even though a desktop app can't keep it secret.
3. On the OAuth consent screen, add the openid, profile and email scopes. Use the scope `openid profile email`: Google doesn't accept `offline_access`, and returns a refresh token without it.

Google has no groups claim, no password grant and no client credentials flow. Type the groups on the Groups and Security tab, or use `DefaultGroup`.
