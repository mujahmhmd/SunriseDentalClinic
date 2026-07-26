// Tailwind theme customization for the Play CDN build (no Node build step)
tailwind.config = {
  theme: {
    extend: {
      colors: {
        clinic: {
          50: '#F8F4EA',
          100: '#EFE7D3',
          600: '#3F6E56',
          700: '#2E5342',
          800: '#22402F',
          900: '#182E22'
        },
        coral: {
          400: '#EA8B6F',
          500: '#E2745A'
        }
      },
      fontFamily: {
        display: ['Fraunces', 'serif'],
        body: ['Outfit', 'sans-serif']
      }
    }
  }
}
