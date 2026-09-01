import { Component, computed, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { KeycloakService } from './utils/keycloak/keycloak-service';
import { env } from './utils/env';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  private readonly kc = inject(KeycloakService);

  // Expose Keycloak state for the test harness card (we keep this until real pages exist)
  protected readonly isAuthenticated = computed(() => this.kc.keycloak.authenticated ?? false);
  protected readonly userName = computed(() => (this.kc.keycloak.tokenParsed?.['preferred_username'] as string) ?? this.kc.keycloak.tokenParsed?.['email'] as string ?? '');
  protected readonly sub = computed(() => this.kc.keycloak.tokenParsed?.sub as string ?? '');
  protected readonly accountUrl = `${env.keycloakUrl}/realms/${env.keycloakRealm}/account/`;

  protected signIn(): void {
    void this.kc.login();
  }

  protected signOut(): void {
    void this.kc.logout();
  }

  protected manageAccount(): void {
    void this.kc.accountManagement();
  }
}
