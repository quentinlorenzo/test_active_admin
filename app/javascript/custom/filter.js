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
}

// Initialisation
document.addEventListener('DOMContentLoaded', () => {
  const select = document.querySelector('.filter-select');
  if (select) {
    filterContent(select.value || 'all');
  }
}); 