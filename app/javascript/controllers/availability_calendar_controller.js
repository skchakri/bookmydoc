import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  selectDate(event) {
    const date = event.currentTarget.dataset.date
    const isAvailable = event.currentTarget.dataset.available === "true"

    if (isAvailable) {
      // Navigate to appointment booking page with selected date
      const doctorId = window.location.pathname.split('/').pop()
      window.location.href = `/appointments/new?doctor_id=${doctorId}&date=${date}`
    }
  }
}
