import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "latitude", "longitude", "city", "pincode"]
  static values = {
    debounceDelay: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
    this.abortController = null
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.abortController) this.abortController.abort()
  }

  search(event) {
    const query = event.target.value.trim()

    if (query.length < 3) {
      this.hideSuggestions()
      return
    }

    // Debounce the search
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.fetchSuggestions(query)
    }, this.debounceDelayValue)
  }

  async fetchSuggestions(query) {
    // Cancel previous request
    if (this.abortController) {
      this.abortController.abort()
    }

    this.abortController = new AbortController()

    try {
      // Using Nominatim (OpenStreetMap) - Free, no API key required
      // Restrict to India for better results
      const url = `https://nominatim.openstreetmap.org/search?` + new URLSearchParams({
        q: query,
        format: 'json',
        addressdetails: 1,
        limit: 5,
        countrycodes: 'in' // Restrict to India
      })

      const response = await fetch(url, {
        signal: this.abortController.signal,
        headers: {
          'User-Agent': 'BookMyDoc Healthcare Platform'
        }
      })

      if (!response.ok) throw new Error('Search failed')

      const data = await response.json()
      this.displaySuggestions(data)
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Address search error:', error)
      }
    }
  }

  displaySuggestions(places) {
    if (!places || places.length === 0) {
      this.hideSuggestions()
      return
    }

    this.suggestionsTarget.innerHTML = places.map((place, index) => `
      <div
        class="px-4 py-3 hover:bg-primary-50 cursor-pointer border-b last:border-b-0 transition-colors"
        data-action="click->address-autocomplete#selectPlace"
        data-index="${index}"
        data-lat="${place.lat}"
        data-lon="${place.lon}"
        data-display-name="${this.escapeHtml(place.display_name)}"
        data-city="${this.escapeHtml(place.address?.city || place.address?.town || place.address?.village || '')}"
        data-postcode="${this.escapeHtml(place.address?.postcode || '')}"
      >
        <div class="flex items-start">
          <svg class="w-5 h-5 text-primary-600 mr-2 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <div class="flex-1">
            <div class="text-sm font-medium text-gray-900">${this.escapeHtml(place.display_name)}</div>
            ${place.address?.postcode ? `<div class="text-xs text-gray-500 mt-1">PIN: ${this.escapeHtml(place.address.postcode)}</div>` : ''}
          </div>
        </div>
      </div>
    `).join('')

    this.showSuggestions()
  }

  selectPlace(event) {
    const element = event.currentTarget
    const displayName = element.dataset.displayName
    const lat = element.dataset.lat
    const lon = element.dataset.lon
    const city = element.dataset.city
    const postcode = element.dataset.postcode

    // Update form fields
    this.inputTarget.value = displayName

    if (this.hasLatitudeTarget) {
      this.latitudeTarget.value = lat
    }

    if (this.hasLongitudeTarget) {
      this.longitudeTarget.value = lon
    }

    if (this.hasCityTarget && city) {
      this.cityTarget.value = city
    }

    if (this.hasPincodeTarget && postcode) {
      this.pincodeTarget.value = postcode
    }

    this.hideSuggestions()

    // Dispatch custom event for other controllers to listen to
    this.element.dispatchEvent(new CustomEvent('address-selected', {
      detail: { lat, lon, address: displayName, city, postcode },
      bubbles: true
    }))
  }

  showSuggestions() {
    this.suggestionsTarget.classList.remove('hidden')
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add('hidden')
  }

  // Hide suggestions when clicking outside
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }

  // Escape HTML to prevent XSS
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text || ''
    return div.innerHTML
  }
}
