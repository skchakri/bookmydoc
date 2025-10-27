import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    this.timeout = null
    this.selectedIndex = -1
  }

  search() {
    clearTimeout(this.timeout)
    
    const query = this.inputTarget.value.trim()
    
    if (query.length < 3) {
      this.hideResults()
      return
    }

    this.timeout = setTimeout(() => {
      this.fetchResults(query)
    }, 300)
  }

  async fetchResults(query) {
    try {
      const url = `/api/autocomplete/specializations?q=${encodeURIComponent(query)}`
      const response = await fetch(url)
      const data = await response.json()
      
      this.displayResults(data)
    } catch (error) {
      console.error("Autocomplete error:", error)
    }
  }

  displayResults(results) {
    if (results.length === 0) {
      this.hideResults()
      return
    }

    this.resultsTarget.innerHTML = results.map((result, index) => `
      <div class="autocomplete-item px-4 py-2 hover:bg-primary-50 cursor-pointer ${index === this.selectedIndex ? 'bg-primary-50' : ''}" 
           data-action="click->specialization-search#select"
           data-value="${this.escapeHtml(result.value)}"
           data-index="${index}">
        <div class="text-gray-900">${this.escapeHtml(result.label)}</div>
      </div>
    `).join("")

    this.showResults()
  }

  select(event) {
    const item = event.currentTarget
    const value = item.dataset.value
    
    this.inputTarget.value = value
    this.hideResults()
  }

  handleKeydown(event) {
    const items = this.resultsTarget.querySelectorAll('.autocomplete-item')
    
    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateSelection(items)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.updateSelection(items)
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
          items[this.selectedIndex].click()
        }
        break
      case 'Escape':
        this.hideResults()
        break
    }
  }

  updateSelection(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-primary-50')
        item.scrollIntoView({ block: 'nearest' })
      } else {
        item.classList.remove('bg-primary-50')
      }
    })
  }

  showResults() {
    this.resultsTarget.classList.remove('hidden')
  }

  hideResults() {
    this.resultsTarget.classList.add('hidden')
    this.selectedIndex = -1
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
