import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    // We can pass a custom message if we want, otherwise use a default
    message: { type: String, default: "You have unsaved changes. Are you sure you want to leave?" }
  }

  connect() {
    this.isDirty = false
    this.handleBeforeUnload = this.handleBeforeUnload.bind(this)
    this.setDirty = this.setDirty.bind(this)
    this.clearDirty = this.clearDirty.bind(this)

    // Listen for changes on any input within the form
    this.element.addEventListener("input", this.setDirty)
    // When the form is submitted successfully, Turbo will fire this event
    this.element.addEventListener("turbo:submit-end", this.clearDirty)

    window.addEventListener("beforeunload", this.handleBeforeUnload)
  }

  disconnect() {
    this.element.removeEventListener("input", this.setDirty)
    this.element.removeEventListener("turbo:submit-end", this.clearDirty)
    window.removeEventListener("beforeunload", this.handleBeforeUnload)
  }

  setDirty() {
    this.isDirty = true
  }

  clearDirty(event) {
    // Only clear the dirty flag if the submission was successful
    if (event.detail.success) {
      this.isDirty = false
    }
  }

  handleBeforeUnload(event) {
    if (this.isDirty) {
      // This is the standard way to trigger the browser's native confirmation dialog
      event.preventDefault()
      event.returnValue = this.messageValue
      return this.messageValue
    }
  }
}