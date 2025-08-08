import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebarLoader", "mainLoader"]

  connect() {
    setTimeout(() => {
      this.hideLoaders()
    }, 200) // 200ms delay, adjust as needed.
  }

  hideLoaders() {
    if (this.hasSidebarLoaderTarget) {
      this.sidebarLoaderTarget.classList.add("hidden")
    }
    if (this.hasMainLoaderTarget) {
      this.mainLoaderTarget.classList.add("hidden")
    }
  }
}