/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          500: '#0284c7',
          600: '#0369a1',
          700: '#075985',
          900: '#0c4a6e',
        },
        sage: {
          50: '#f4f7f4',
          100: '#e5ece5',
          500: '#5a8264',
          600: '#47684f',
          800: '#2b3f30',
        },
        terracotta: {
          100: '#fbeae5',
          500: '#d96b43',
          600: '#b85430',
        }
      }
    },
  },
  plugins: [],
}
