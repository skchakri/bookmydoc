import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  // Comprehensive list of medical specializations in India
  static specializations = [
    // Primary Care
    "General Physician",
    "Family Medicine",
    "Internal Medicine",

    // Surgical Specialties
    "General Surgery",
    "Cardiothoracic Surgery",
    "Neurosurgery",
    "Orthopedic Surgery",
    "Plastic Surgery",
    "Pediatric Surgery",
    "Vascular Surgery",
    "Trauma Surgery",
    "Surgical Oncology",
    "Laparoscopic Surgery",

    // Medical Specialties
    "Cardiology",
    "Neurology",
    "Gastroenterology",
    "Pulmonology",
    "Nephrology",
    "Rheumatology",
    "Endocrinology",
    "Hematology",
    "Oncology",
    "Infectious Diseases",
    "Critical Care Medicine",

    // Pediatrics
    "Pediatrics",
    "Neonatology",
    "Pediatric Cardiology",
    "Pediatric Neurology",
    "Pediatric Gastroenterology",

    // Obstetrics & Gynecology
    "Obstetrics & Gynecology",
    "Gynecology",
    "Obstetrics",
    "Reproductive Medicine",
    "Maternal-Fetal Medicine",

    // Diagnostic Specialties
    "Radiology",
    "Pathology",
    "Nuclear Medicine",
    "Clinical Pathology",

    // Surgical Sub-specialties
    "Urology",
    "Ophthalmology",
    "ENT (Otorhinolaryngology)",
    "Dermatology",
    "Dentistry",
    "Oral & Maxillofacial Surgery",

    // Mental Health
    "Psychiatry",
    "Psychology",
    "Child Psychiatry",
    "Geriatric Psychiatry",

    // Specialized Fields
    "Anesthesiology",
    "Emergency Medicine",
    "Sports Medicine",
    "Geriatrics",
    "Palliative Care",
    "Pain Management",
    "Physical Medicine & Rehabilitation",
    "Occupational Medicine",

    // Alternative Medicine
    "Ayurveda",
    "Homeopathy",
    "Unani",
    "Siddha",
    "Naturopathy",
    "Yoga & Naturopathy",

    // Allied Health
    "Physiotherapy",
    "Dietetics & Nutrition",
    "Speech Therapy",
    "Audiology",

    // Specialized Clinics
    "Diabetology",
    "Allergist/Immunologist",
    "Cosmetology",
    "Sexologist",
    "Sleep Medicine",
    "Bariatric Surgery",
    "Transplant Surgery",
    "Interventional Cardiology",
    "Interventional Radiology"
  ].sort()

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  search(event) {
    const query = event.target.value.trim().toLowerCase()

    if (query.length === 0) {
      this.hideSuggestions()
      return
    }

    // Debounce the search
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.filterSuggestions(query)
    }, 200)
  }

  filterSuggestions(query) {
    const filtered = this.constructor.specializations.filter(spec =>
      spec.toLowerCase().includes(query)
    )

    if (filtered.length === 0) {
      this.hideSuggestions()
      return
    }

    this.displaySuggestions(filtered.slice(0, 10)) // Show max 10 suggestions
  }

  displaySuggestions(specializations) {
    this.suggestionsTarget.innerHTML = specializations.map(spec => `
      <div
        class="px-4 py-3 hover:bg-primary-50 cursor-pointer border-b last:border-b-0 transition-colors"
        data-action="click->specialization-autocomplete#selectSpecialization"
        data-specialization="${this.escapeHtml(spec)}"
      >
        <div class="flex items-center">
          <svg class="w-5 h-5 text-primary-600 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <div class="text-sm font-medium text-gray-900">${this.escapeHtml(spec)}</div>
        </div>
      </div>
    `).join('')

    this.showSuggestions()
  }

  selectSpecialization(event) {
    const specialization = event.currentTarget.dataset.specialization
    this.inputTarget.value = specialization
    this.hideSuggestions()

    // Dispatch custom event
    this.element.dispatchEvent(new CustomEvent('specialization-selected', {
      detail: { specialization },
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

  // Handle keyboard navigation
  handleKeydown(event) {
    // Allow user to type freely and dismiss on Escape
    if (event.key === 'Escape') {
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
