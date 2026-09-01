import {ApplicationConfig, inject, provideAppInitializer, provideBrowserGlobalErrorListeners} from '@angular/core';
import {provideRouter} from '@angular/router';
import {routes} from './app.routes';
import {provideHotToastConfig} from '@ngxpert/hot-toast';
import {keycloakHttpInterceptor} from './utils/http/keycloak-http-interceptor';
import {provideHttpClient, withInterceptors} from '@angular/common/http';
import {KeycloakService} from './utils/keycloak/keycloak-service';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideHotToastConfig(),
    provideHttpClient(
      withInterceptors([keycloakHttpInterceptor])
    ),
    provideAppInitializer(() => {
      const initFunction = ((key: KeycloakService) => {
        return () => key.init();
      })(inject(KeycloakService));
      return initFunction()
    })
  ],
};
