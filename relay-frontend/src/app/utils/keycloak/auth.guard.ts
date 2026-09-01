import { CanActivateFn } from '@angular/router';
import { inject } from '@angular/core';
import { KeycloakService } from './keycloak-service';

/**
 * Use on routes that need a User (create Note, My Notes, Pro, account).
 * Guest can still view public Notes (FR-03) — do NOT put this guard on public view routes.
 */
export const authGuard: CanActivateFn = () => {
  const kc = inject(KeycloakService);

  if (kc.keycloak.authenticated) {
    return true;
  }

  // Not authenticated — send to Keycloak login, return to this URL after.
  void kc.login();
  return false;
};

/**
 * Optional: keep Guest on public pages, redirect authenticated User elsewhere.
 */
export const guestGuard: CanActivateFn = () => {
  const kc = inject(KeycloakService);
  return !kc.keycloak.authenticated;
};
