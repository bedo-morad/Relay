import {Service} from '@angular/core';
import Keycloak from 'keycloak-js';
import {env} from '../env';

@Service()
export class KeycloakService {
  private _keycloak: Keycloak | undefined;

  constructor() {}

  get keycloak() {
    if (!this._keycloak) {
      this._keycloak = new Keycloak({
        url: env.keycloakUrl,
        realm: env.keycloakRealm,
        clientId: env.keycloakClientId,
      });
    }
    return this._keycloak;
  }

  /**
   * check-sso = do NOT force login. Guest can view public Notes (FR-03/FR-04).
   * Authenticated routes will call login() themselves when they need a User.
   */
  async init() {
    return await this.keycloak.init({
      onLoad: 'check-sso',
      pkceMethod: 'S256',
      checkLoginIframe: false,
    });
  }

  async login() {
    await this.keycloak.login();
  }

  get userId(): string {
    return this.keycloak?.tokenParsed?.sub as string;
  }

  get isTokenValid() {
    return this.keycloak?.authenticated && !this.keycloak.isTokenExpired();
  }

  get fullName(): string {
    return (this.keycloak?.tokenParsed?.['name'] as string) ?? 'User';
  }

  logout() {
    return this.keycloak.logout({ redirectUri: env.frontendUrl });
  }

  accountManagement() {
    return this.keycloak.accountManagement();
  }
}
