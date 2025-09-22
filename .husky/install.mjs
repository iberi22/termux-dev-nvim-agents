// Skip Husky install in production, CI, and Docker environments
if (process.env.NODE_ENV === 'production' || 
    process.env.CI === 'true' || 
    process.env.GITHUB_ACTIONS === 'true' ||
    process.env.DOCKER === 'true' ||
    process.env.HUSKY === '0') {
  console.log('Skipping Husky installation (CI/Production environment)')
  process.exit(0)
}

// Install husky in development
try {
  const husky = (await import('husky')).default
  console.log(husky())
} catch (error) {
  console.warn('Husky installation failed:', error.message)
  process.exit(0)
}