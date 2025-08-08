// app/javascript/controllers/track_list_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["refreshButton"]

  // The 'isLoading' flag is now less critical but still good for internal state.
  isLoading = false

  connect() {
    this.refresh = this.refresh.bind(this)
    this.refreshButtonTarget.addEventListener('click', this.refresh)
  }

  disconnect() {
    // Ensure the button is re-enabled if the controller is removed mid-request
    this.refreshButtonTarget.disabled = false
    this.refreshButtonTarget.removeEventListener('click', this.refresh)
  }
  
  async refresh(event) {
    event.preventDefault()

    // This guard is now redundant if the button is disabled, but is harmless.
    if (this.isLoading) { return }

    const generatingItems = this.element.querySelectorAll('.is-generating, .is-failed, .has-error')
    if (generatingItems.length === 0) { return }

    const songIds = Array.from(generatingItems).map(item => item.id)
    const icon = this.refreshButtonTarget.querySelector('.icon')

    try {
      this.isLoading = true
      // --- REFINEMENT 1: Directly disable the button ---
      // This provides immediate visual feedback and programmatically prevents clicks.
      this.refreshButtonTarget.disabled = true
      icon.classList.add('animate-spin')

      const url = new URL('/songs/track_list', window.location.origin)
      songIds.forEach(id => url.searchParams.append('song_ids[]', id))
      
      const response = await fetch(url.toString(), {
        headers: { 'Accept': 'text/vnd.turbo-stream.html' }
      })
      const streamMessage = await response.text()
      
      if (streamMessage) {
        Turbo.renderStreamMessage(streamMessage)
      }

    } catch (error) {
      console.error("Could not refresh the track list:", error)
    } finally {
      // The setTimeout remains the critical piece to break the race condition.
      setTimeout(() => {
        this.isLoading = false
        // --- REFINEMENT 2: Re-enable the button ---
        this.refreshButtonTarget.disabled = false
        icon.classList.remove('animate-spin')
      }, 100)
    }
  }
}