<template>
  <div class="app-shell">
    <Sidebar />
    <main class="app-main">
      <RouterView />

      <footer class="app-footer">
        <hr class="app-footer__divider" />
        <div class="app-footer__content">
          <p>
            FAIRTerm 2.0 is the result of a joint collaboration between the
            <a href="https://www.disll.unipd.it/" target="_blank" rel="noopener">Department of Linguistic and Literary Studies (DiSLL)</a>
            and the
            <a href="https://www.dei.unipd.it/" target="_blank" rel="noopener">Department of Information Engineering (DEI)</a>
            of the
            <a href="https://www.unipd.it" target="_blank" rel="noopener" class="app-footer__university">
              <img :src="unipdLogo" alt="" class="app-footer__university-logo" />
              University of Padova
            </a>.
          </p>
          <p>
            This project has been carried out within the activities of the Centre of Studies for Computational Terminology (CENTRICO) of the
            <a href="https://www.unipd.it" target="_blank" rel="noopener" class="app-footer__university">
              <img :src="unipdLogo" alt="" class="app-footer__university-logo" />
              University of Padova
            </a>.
          </p>
          <p>
            © Giorgio Maria Di Nunzio and Federica Vezzani. This work is licensed under a
            <a href="https://creativecommons.org/licenses/by/4.0/" target="_blank" rel="noopener">Creative Commons Attribution 4.0 International License</a>.
          </p>
        </div>
      </footer>

    </main>
  </div>
</template>

<script setup>
import { RouterView } from 'vue-router'
import Sidebar from './components/layout/Sidebar.vue'
import unipdLogo from './assets/unipd.svg'
</script>

<style scoped>
.app-shell {
  min-height: 100vh;
}

.app-main {
  margin-left: var(--sidebar-width);
  min-height: 100vh;
}
</style>
