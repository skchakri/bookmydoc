import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "dateInput", "timeSlots"]

  connect() {
    console.log("Appointment controller connected")
  }

  selectSlot(event) {
    event.preventDefault()
    const button = event.currentTarget
    const startTime = button.dataset.startTime
    const endTime = button.dataset.endTime

    // Update hidden form fields
    const startInput = this.formTarget.querySelector('[name="appointment[scheduled_start]"]')
    const endInput = this.formTarget.querySelector('[name="appointment[scheduled_end]"]')

    if (startInput && endInput) {
      startInput.value = startTime
      endInput.value = endTime
    }

    // Highlight selected slot
    this.timeSlotsTarget.querySelectorAll('button').forEach(btn => {
      btn.classList.remove('bg-primary-600', 'text-white')
      btn.classList.add('bg-gray-200', 'text-gray-900')
    })

    button.classList.remove('bg-gray-200', 'text-gray-900')
    button.classList.add('bg-primary-600', 'text-white')

    // Enable submit button
    const submitButton = this.formTarget.querySelector('[type="submit"]')
    if (submitButton) {
      submitButton.disabled = false
    }
  }

  reschedule(event) {
    event.preventDefault()
    // Open reschedule modal
    const modal = document.getElementById('rescheduleModal')
    if (modal) {
      modal.classList.remove('hidden')
    }
  }
}
