export function filterContent(value) {
  const sections = document.querySelectorAll('.data-section');
  sections.forEach(section => {
    section.classList.remove('active');
  });

  if (value === 'all') {
    sections.forEach(section => {
      section.classList.add('active');
    });
  } else {
    const selectedSection = document.getElementById(`${value}-section`);
    if (selectedSection) {
      selectedSection.classList.add('active');
    }
  }

  // Forcer le re-rendu des graphiques visibles
  setTimeout(() => {
    if (window.chartInstances) {
      Object.values(window.chartInstances).forEach(chart => {
        if (chart) {
          chart.resize();
        }
      });
    }
  }, 100); // Petit délai pour laisser le temps aux transitions CSS
}

// Initialisation
document.addEventListener('DOMContentLoaded', () => {
  const select = document.querySelector('.filter-select');
  if (select) {
    filterContent(select.value || 'all');
  }
});

// Pour Turbo
document.addEventListener('turbo:load', () => {
  const select = document.querySelector('.filter-select');
  if (select) {
    filterContent(select.value || 'all');
  }
}); 