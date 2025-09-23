import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 3000,
    cors: true,
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  },
  base: './',
});