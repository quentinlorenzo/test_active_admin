// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Import Chart.js
import "chart.js"
import "chartjs-plugin-datalabels"
import "./custom/chart_init"

// Import custom modules
import { filterContent } from "./custom/filter"
window.filterContent = filterContent  // Make filterContent available globally
