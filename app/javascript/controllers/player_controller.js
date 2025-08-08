import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "player", "albumArt", "songTitle", "songArtist",
    "playButton", "pauseButton", "progress", "currentTime", "duration"
  ]

  connect() {
    this.body = document.body
    this.audio = new Audio()

    this.audio.addEventListener("timeupdate", this.updateProgress.bind(this))
    this.audio.addEventListener("loadedmetadata", this.updateTime.bind(this))
    this.audio.addEventListener("play", this.updatePlayIcon.bind(this))
    this.audio.addEventListener("pause", this.updatePlayIcon.bind(this))
    this.audio.addEventListener("ended", this.pause.bind(this)) // When song ends, go to pause state
  }

  // This is called directly by any button with `data-action="player#show"`
  show(event) {
    // Data comes directly from the button's `data-player-*` attributes
    const { url, title, artist, artwork } = event.params

    if (!url) {
      console.error("Player Error: No URL provided.");
      return
    }

    // If the user clicks the same song that's already playing, pause it.
    // Otherwise, load and play the new song.
    if (this.audio.src === url && !this.audio.paused) {
      this.pause()
    } else {
      this.audio.src = url
      this.albumArtTarget.src = artwork || 'https://i.imgur.com/GzQ5Z2s.jpeg'
      this.songTitleTarget.textContent = title
      this.songArtistTarget.textContent = artist
      this.play()
    }

    this.playerTarget.classList.add("is-visible")
    this.body.classList.add("has-player-visible")
  }

  hide() {
    this.pause()
    this.playerTarget.classList.remove("is-visible")
    this.body.classList.remove("has-player-visible")
  }

  play() {
    if (this.audio.src) {
      this.audio.play()
    }
  }

  pause() {
    this.audio.pause()
  }
  
  togglePlay() {
    if (!this.audio.src) return; // Don't do anything if no song is loaded
    if (this.audio.paused) {
      this.play()
    } else {
      this.pause()
    }
  }

  seek(event) {
    if (!this.audio.src || isNaN(this.audio.duration)) return;
    const bar = event.currentTarget
    const clickPosition = (event.clientX - bar.getBoundingClientRect().left) / bar.offsetWidth
    this.audio.currentTime = clickPosition * this.audio.duration
  }
  
  // --- Helper Methods ---
  
  updatePlayIcon() {
    const isPaused = this.audio.paused
    this.playButtonTarget.classList.toggle("hidden", !isPaused)
    this.pauseButtonTarget.classList.toggle("hidden", isPaused)
  }
  
  updateTime() {
    if (isNaN(this.audio.duration)) return
    this.durationTarget.textContent = this.formatTime(this.audio.duration)
  }

  updateProgress() {
    if (isNaN(this.audio.duration)) return
    const percentage = (this.audio.currentTime / this.audio.duration) * 100
    this.progressTarget.style.width = `${percentage}%`
    this.currentTimeTarget.textContent = this.formatTime(this.audio.currentTime)
  }

  formatTime(seconds) {
    const minutes = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${minutes}:${secs.toString().padStart(2, '0')}`
  }
}