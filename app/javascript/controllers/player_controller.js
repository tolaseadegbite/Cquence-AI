// app/javascript/controllers/player_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "player", 
    "albumArt", 
    "songTitle", 
    "songArtist",
    "playButton",
    "pauseButton",
    "progress",
    "currentTime",
    "duration"
  ]

  connect() {
    this.body = document.body
    this.audio = new Audio()

    this.audio.addEventListener("timeupdate", () => this.updateProgress())
    this.audio.addEventListener("loadedmetadata", () => {
      this.durationTarget.textContent = this.formatTime(this.audio.duration)
    })
  }

  show(event) {
    const { songUrl, title, artist, image } = event.params
    
    this.albumArtTarget.src = image
    this.songTitleTarget.textContent = title
    this.songArtistTarget.textContent = artist
    
    this.audio.src = songUrl
    this.play()

    this.playerTarget.classList.add("is-visible")
    this.body.classList.add("has-player-visible")
  }

  hide() {
    this.pause()
    this.playerTarget.classList.remove("is-visible")
    this.body.classList.remove("has-player-visible")
  }

  play() {
    this.audio.play()
    this.playButtonTarget.classList.add("hidden")
    this.pauseButtonTarget.classList.remove("hidden")
  }

  pause() {
    this.audio.pause()
    this.pauseButtonTarget.classList.add("hidden")
    this.playButtonTarget.classList.remove("hidden")
  }

  seek(event) {
    const progressBar = event.currentTarget
    const clickPosition = (event.clientX - progressBar.getBoundingClientRect().left) / progressBar.offsetWidth
    this.audio.currentTime = clickPosition * this.audio.duration
  }

  updateProgress() {
    if (isNaN(this.audio.duration)) return;
    const percentage = (this.audio.currentTime / this.audio.duration) * 100
    this.progressTarget.style.width = `${percentage}%`
    this.currentTimeTarget.textContent = this.formatTime(this.audio.currentTime)
  }

  formatTime(seconds) {
    const minutes = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${minutes}:${secs < 10 ? '0' : ''}${secs}`
  }
}