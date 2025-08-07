import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    // We only need targets for the inputs and the submit button now.
    // The tab panels and buttons are managed by the 'tabs' controller.
    "modeInput",
    "lyricsModeInput",
    "descriptionField",
    "styleField",
    "lyricsField",
    "autoLyricsButton",
    "writeLyricsButton",
    "submitButton",
    "spinnerIcon",
    "musicIcon",
    "submitButtonText"
  ]

  connect() {
    // Listen for Turbo form submission events to manage loading state
    this.element.addEventListener("turbo:submit-start", this.showLoadingState.bind(this))
    this.element.addEventListener("turbo:submit-end", this.hideLoadingState.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-start", this.showLoadingState.bind(this))
    this.element.removeEventListener("turbo:submit-end", this.hideLoadingState.bind(this))
  }

  // This action is called by the tab buttons to update our hidden field.
  // The 'tabs' controller will handle the visual changes.
  setMode(event) {
    const selectedMode = event.currentTarget.dataset.mode
    this.modeInputTarget.value = selectedMode
  }

  // Switches between "Write" and "Auto" lyrics mode in the Custom tab
  selectLyricsMode(event) {
    event.preventDefault()
    const selectedLyricsMode = event.currentTarget.dataset.lyricsMode
    this.lyricsModeInputTarget.value = selectedLyricsMode
    this.lyricsFieldTarget.value = "" // Clear lyrics on mode switch

    if (selectedLyricsMode === 'write') {
      this.writeLyricsButtonTarget.classList.add('btn--secondary')
      this.writeLyricsButtonTarget.classList.remove('btn--borderless')
      this.autoLyricsButtonTarget.classList.add('btn--borderless')
      this.autoLyricsButtonTarget.classList.remove('btn--secondary')
      this.lyricsFieldTarget.placeholder = "Add your own lyrics here"
    } else { // auto
      this.autoLyricsButtonTarget.classList.add('btn--secondary')
      this.autoLyricsButtonTarget.classList.remove('btn--borderless')
      this.writeLyricsButtonTarget.classList.add('btn--borderless')
      this.writeLyricsButtonTarget.classList.remove('btn--secondary')
      this.lyricsFieldTarget.placeholder = "Describe your lyrics..."
    }
  }

  // Appends a tag to the Simple mode description field
  addInspirationTag(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    const currentText = this.descriptionFieldTarget.value.trim()
    
    if (currentText === "") {
      this.descriptionFieldTarget.value = tag
    } else if (!currentText.split(',').map(t => t.trim()).includes(tag)) {
      this.descriptionFieldTarget.value = `${currentText}, ${tag}`
    }
  }

  // Appends a tag to the Custom mode style field
  addStyleTag(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    const currentText = this.styleFieldTarget.value.trim()

    if (currentText === "") {
      this.styleFieldTarget.value = tag
    } else if (!currentText.split(',').map(t => t.trim()).includes(tag)) {
      this.styleFieldTarget.value = `${currentText}, ${tag}`
    }
  }

  // Manages the "Create" button's loading state
  showLoadingState() {
    this.submitButtonTarget.disabled = true
    this.spinnerIconTarget.classList.remove("hidden")
    this.musicIconTarget.classList.add("hidden")
    this.submitButtonTextTarget.textContent = "Creating..."
  }

  hideLoadingState() {
    this.submitButtonTarget.disabled = false
    this.spinnerIconTarget.classList.add("hidden")
    this.musicIconTarget.classList.remove("hidden")
    this.submitButtonTextTarget.textContent = "Create"
  }
}