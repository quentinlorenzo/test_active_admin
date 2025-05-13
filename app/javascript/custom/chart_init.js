document.addEventListener('DOMContentLoaded', function() {
  // Register the plugin to all charts
  Chart.register(ChartDataLabels);
  
  // Set default options for all charts
  Chart.defaults.set('plugins.datalabels', {
    color: '#000000',
    font: {
      weight: 'bold'
    },
    formatter: function(value, context) {
      return value + '%';
    }
  });
}); 