import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section"]

  connect() {
    this.filterContent(this.element.value || 'all')
  }

  filter(event) {
    this.filterContent(event.target.value)
  }

  filterContent(value) {
    this.sectionTargets.forEach(section => {
      if (value === 'all' || section.id === `${value}-section`) {
        section.classList.remove('hidden')
      } else {
        section.classList.add('hidden')
      }
    })
  }
} 