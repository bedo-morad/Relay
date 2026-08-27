import { Component, signal } from '@angular/core';

interface TokenClaims {
  sub?: string;
  email?: string;
  preferred_username?: string;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  private readonly keycloakBase = 'http://localhost:9090';
  private readonly realm = 'relay';
  private readonly clientId = 'relay-frontend';
  private readonly redirectUri = `${window.location.origin}/`;

  protected readonly user = signal<TokenClaims | null>(null);
  protected readonly status = signal<string>('');

  constructor() {
    const params = new URLSearchParams(window.location.search);
    const code = params.get('code');
    if (code) {
      window.history.replaceState({}, '', this.redirectUri);
      void this.exchangeCode(code);
    } else if (params.get('error')) {
      this.status.set(`Login failed: ${params.get('error_description') ?? params.get('error')}`);
    }
  }

  protected async signIn(): Promise<void> {
    const verifier = this.randomString(64);
    sessionStorage.setItem('pkce_verifier', verifier);

    const challenge = await this.pkceChallenge(verifier);
    const url = new URL(
      `${this.keycloakBase}/realms/${this.realm}/protocol/openid-connect/auth`,
    );
    url.searchParams.set('client_id', this.clientId);
    url.searchParams.set('response_type', 'code');
    url.searchParams.set('scope', 'openid');
    url.searchParams.set('redirect_uri', this.redirectUri);
    url.searchParams.set('code_challenge', challenge);
    url.searchParams.set('code_challenge_method', 'S256');
    window.location.assign(url.toString());
  }

  private async exchangeCode(code: string): Promise<void> {
    const verifier = sessionStorage.getItem('pkce_verifier');
    if (!verifier) {
      this.status.set('No PKCE verifier stored - start the flow again.');
      return;
    }

    try {
      const response = await fetch(
        `${this.keycloakBase}/realms/${this.realm}/protocol/openid-connect/token`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams({
            grant_type: 'authorization_code',
            client_id: this.clientId,
            code,
            redirect_uri: this.redirectUri,
            code_verifier: verifier,
          }),
        },
      );

      if (!response.ok) {
        this.status.set(`Token exchange failed (${response.status}).`);
        return;
      }

      const tokens = (await response.json()) as { access_token?: string };
      const payload = tokens.access_token?.split('.')[1];
      if (!payload) {
        this.status.set('No access token returned.');
        return;
      }

      this.user.set(JSON.parse(atob(payload)) as TokenClaims);
    } catch {
      this.status.set('Token exchange request failed - is Keycloak running?');
    }
  }

  private randomString(length: number): string {
    const bytes = crypto.getRandomValues(new Uint8Array(length));
    return Array.from(bytes, (b) => b.toString(36).padStart(2, '0')).join('').slice(0, length);
  }

  private async pkceChallenge(verifier: string): Promise<string> {
    const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier));
    return btoa(String.fromCharCode(...new Uint8Array(digest)))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  }
}
