<template>
  <aside class="sidebar">
    <div class="sidebar__brand">
      <!-- Logo -->
      <span class="sidebar__brand-mark" aria-hidden="true">
      </span>
      <!-- Site name -->
      <span class="sidebar__brand-name">FAIRterm <span class="sidebar__brand-version">2.0</span></span>
    </div>

    <RouterLink to="/concepts/new" class="sidebar__cta" active-class="sidebar__cta--active">
      <!-- New concept button -->
      <span class="sidebar__cta-label">
        <span class="sidebar__cta-icon" aria-hidden="true">
        <svg xmlns="http://www.w3.org/2000/svg" height="22px" viewBox="0 -960 960 960" width="22px" fill="currentColor">
            <path d="M440-440H200v-80h240v-240h80v240h240v80H520v240h-80v-240Z" />
        </svg>
        </span>
        New concept
    </span>
    </RouterLink>

    <nav class="sidebar__nav">
      <RouterLink to="/concepts" class="sidebar__nav-item" active-class="sidebar__nav-item--active">
        <!-- Concepts link -->
        <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor">
            <path d="M491-339q70 0 119-45t49-109q0-57-36.5-96.5T534-629q-47 0-79.5 30T422-525q0 19 7.5 37t21.5 33l57-57q-3-2-4.5-5t-1.5-7q0-11 9-17.5t23-6.5q20 0 33 16.5t13 39.5q0 31-25.5 52.5T492-418q-47 0-79.5-38T380-549q0-29 11-55.5t31-46.5l-57-57q-32 31-49 72t-17 86q0 88 56 149.5T491-339ZM240-80v-172q-57-52-88.5-121.5T120-520q0-150 105-255t255-105q125 0 221.5 73.5T827-615l52 205q5 19-7 34.5T840-360h-80v120q0 33-23.5 56.5T680-160h-80v80h-80v-160h160v-200h108l-38-155q-23-91-98-148t-172-57q-116 0-198 81t-82 197q0 60 24.5 114t69.5 96l26 24v208h-80Zm254-360Z"/>
        </svg>
        Concepts
      </RouterLink>

      <!-- Import / Export link [Non ancora una pagina reale: nessuna route dietro] -->
      <span class="sidebar__nav-item sidebar__nav-item--disabled" title="Not yet available">
            <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor">
                <path d="M440-320v-326L336-542l-56-58 200-200 200 200-56 58-104-104v326h-80ZM240-160q-33 0-56.5-23.5T160-240v-120h80v120h480v-120h80v120q0 33-23.5 56.5T720-160H240Z"/>
            </svg>
        Import / Export
      </span>
    </nav>

    <!-- User icon [Placeholder statico: l'autenticazione non è collegata, current user è hardcoded lato backend a "user0"] -->
    <div class="sidebar__account">
      <div class="sidebar__account-avatar">U0</div>
      <div>
        <div class="sidebar__account-name">user0</div>
        <div class="sidebar__account-role">Editor</div>
      </div>
    </div>
  </aside>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>

<style scoped>
.sidebar {
  width: var(--sidebar-width);
  height: 100vh;
  position: fixed;
  flex-shrink: 0;
  background: var(--color-ink);
  color: #F4EFE6;
  display: flex;
  flex-direction: column;
  padding: 20px 16px;
}

.sidebar__brand {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 4px 8px 24px;
}

.sidebar__brand-mark {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  flex-shrink: 0;
}

.sidebar__brand-name {
  font-weight: 700;
  font-size: 20px;
}

.sidebar__brand-version {
  color: var(--color-accent);
}

.sidebar__cta {
  display: flex;
  align-items: center;
  gap: 5px;
  justify-content: center;
  background: transparent;
  border: 1.5px solid var(--color-accent);
  color: var(--color-accent);
  padding: 10px 14px;
  border-radius: var(--radius, 10px);
  font-weight: 400;
  font-size: 15px;
  text-decoration: none;
  margin-bottom: 20px;
}

.sidebar__cta-label {
  position: relative;
  display: inline-block;
}

.sidebar__cta-icon {
  position: absolute;
  right: 100%;
  margin-right: 5px;
  top: 50%;
  transform: translateY(-50%);
  display: inline-flex;
}

.sidebar__cta:hover,
.sidebar__cta--active {
  background: var(--color-accent);
  color: #fff;
}

.sidebar__cta:hover .sidebar__cta-label,
.sidebar__cta--active .sidebar__cta-label {
  font-weight: 600;
}

.sidebar__nav {
  display: flex;
  flex-direction: column;
  gap: 3px;
  flex: 1;
}

.sidebar__nav-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 10px;
  border-radius: 8px;
  color: #D9CFC2;
  text-decoration: none;
  font-size: 15px;
  cursor: pointer;
}

.sidebar__nav-item:hover {
  background: rgba(255, 255, 255, 0.06);
}

.sidebar__nav-item--active {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.sidebar__nav-item--disabled {
  opacity: 0.45;
  cursor: default;
}

.sidebar__nav-item--disabled:hover {
  background: none;
}

.sidebar__account {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 8px 4px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  margin-top: 12px;
}

.sidebar__account-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--color-accent-green);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
}

.sidebar__account-name {
  font-size: 15px;
  font-weight: 600;
  color: #fff;
}

.sidebar__account-role {
  font-size: 12px;
  color: #B8AC9C;
}
</style>