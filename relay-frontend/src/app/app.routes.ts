import { Routes } from '@angular/router';

export const routes: Routes = [
  // Public — Guest can view without login (FR-03). No guard.
  // {
  // path: 'notes/:id',
  // loadComponent: () => import('./features/notes/note-view.component')
  // .then(m => m.NoteViewComponent)
  // },

  // Private — needs User (FR-02, FR-05). Guard redirects to Keycloak login.
  // {
  // path: 'my-notes',
  // canActivate: [authGuard], loadComponent: () => import('./features/notes/my-notes.component')
  // .then(m => m.MyNotesComponent)
  // },
];
