import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["badge", "dropdown"]

  connect() {
    console.log("Notification controller connected")
  }

  toggle() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("hidden")
    }
  }

  markAsRead(event) {
    event.preventDefault()
    const notificationId = event.currentTarget.dataset.notificationId

    // This will trigger a Turbo Stream response
    fetch(`/notifications/${notificationId}/mark_read`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
  }

  updateBadge(count) {
    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = count
      if (count === 0) {
        this.badgeTarget.classList.add("hidden")
      } else {
        this.badgeTarget.classList.remove("hidden")
      }
    }
  }
}
