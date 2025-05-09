// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Import Chart.js
import Chart from 'chart.js/auto'
window.Chart = Chart  // Make Chart available globally
