// app/javascript/controllers/player_controller.js

import { Controller } from "@hotwired/stimulus"

// --- Singleton Audio Instance ---
// This single audio object persists across the entire user session.
let audio;
if (!window.playerAudio) {
  window.playerAudio = new Audio();
  window.playerAudio.volume = 0.75;
}
audio = window.playerAudio;

// --- Global Event Handlers ---
// These are attached ONCE to the audio object. They find the active
// controller on the page and tell it to update its UI. This is the key
// to making the player work reliably with Turbo.

const handlePlay = () => {
  const controller = document.body.playerController;
  if (controller) {
    controller.updateAllIcons();
  }
};

const handlePause = () => {
  const controller = document.body.playerController;
  if (controller) {
    controller.updateAllIcons();
  }
};

const handleTimeUpdate = () => {
  const controller = document.body.playerController;
  if (controller) controller.updateProgress();
};

const handleLoadedMetadata = () => {
  const controller = document.body.playerController;
  if (controller) controller.updateTime();
};

const handleVolumeChange = () => {
  const controller = document.body.playerController;
  if (controller) controller.updateVolume();
};

const handleSongEnd = () => {
  const controller = document.body.playerController;
  if (controller) {
    controller.pause();
    controller.audio.currentTime = 0;
  }
};

// --- The Stimulus Controller ---
export default class extends Controller {
  static targets = [
    "player", "albumArt", "songTitle", "songArtist",
    "toggleButton", "toggleIcon",
    "progress", "currentTime", "duration",
    "volumeIcon", "volumeBar", "volumeBarContainer",
    "collapsedPlayerButton"
  ]

  connect() {
    this.audio = audio;
    // Set this instance as the globally active controller.
    document.body.playerController = this;

    // Attach the global listeners only if they haven't been attached before.
    if (!this.audio.dataset.listenersAttached) {
      this.audio.addEventListener("play", handlePlay);
      this.audio.addEventListener("pause", handlePause);
      this.audio.addEventListener("ended", handleSongEnd);
      this.audio.addEventListener("timeupdate", handleTimeUpdate);
      this.audio.addEventListener("loadedmetadata", handleLoadedMetadata);
      this.audio.addEventListener("volumechange", handleVolumeChange);
      this.audio.dataset.listenersAttached = 'true';
    }

    // On page load, sync the UI with the player's current state.
    this.restorePlayerState();
    this.updateAllSongCardIcons();
  }

  disconnect() {
    // When navigating away, remove the global reference if it points to this instance.
    if (document.body.playerController === this) {
      document.body.playerController = null;
    }
  }

  // --- Player State Management ---

  show(event) {
    event.preventDefault();
    const { url, title, artist, artwork } = event.params;
    const isSameSong = this.audio.src.endsWith(encodeURI(url));

    if (isSameSong) {
      this.togglePlay();
    } else {
      this.audio.src = url;
      if (this.hasAlbumArtTarget) this.albumArtTarget.src = artwork || 'default_album_art.png';
      if (this.hasSongTitleTarget) this.songTitleTarget.textContent = title;
      if (this.hasSongArtistTarget) this.songArtistTarget.textContent = artist;
      this.play();
    }
    this.expand();
  }

  stop() {
    this.pause();
    this.audio.src = "";
    if (this.hasPlayerTarget) this.playerTarget.classList.remove("is-visible");
    if (this.hasCollapsedPlayerButtonTarget) this.collapsedPlayerButtonTarget.classList.add("is-hidden");
    document.body.classList.remove("has-player-visible");
    this.updateAllSongCardIcons();
  }

  collapse() {
    if (this.hasPlayerTarget) {
      this.playerTarget.classList.remove("is-visible");
      this.playerTarget.dataset.collapsed = "true";
    }
    if (this.audio.src && this.hasCollapsedPlayerButtonTarget) {
      this.collapsedPlayerButtonTarget.classList.remove("is-hidden");
    }
  }

  expand() {
    if (!this.audio.src) return;
    if (this.hasPlayerTarget) {
      this.playerTarget.classList.add("is-visible");
      this.playerTarget.dataset.collapsed = "false";
    }
    if (this.hasCollapsedPlayerButtonTarget) {
      this.collapsedPlayerButtonTarget.classList.add("is-hidden");
    }
    document.body.classList.add("has-player-visible");
  }

  restorePlayerState() {
    if (!this.hasPlayerTarget) return;
    if (this.audio.src && this.playerTarget.dataset.collapsed !== "true") {
      this.expand();
      this.updateProgress();
      this.updateTime();
      this.updatePlayIcon();
      this.updateVolume();
    } else if (this.audio.src) {
      this.collapse();
    }
  }

  // --- Core Audio Actions ---

  play() {
    if (this.audio.src) {
      this.audio.play().catch(e => console.error("Player was interrupted:", e));
    }
  }

  pause() {
    this.audio.pause();
  }

  togglePlay() {
    if (!this.audio.src) return;
    this.audio.paused ? this.play() : this.pause();
  }

  // --- Control Button Actions (Called by data-action) ---

  rewind() {
    if (!this.audio.src) return;
    this.audio.currentTime = Math.max(0, this.audio.currentTime - 10);
  }

  fastForward() {
    if (!this.audio.src) return;
    this.audio.currentTime += 10;
  }

  seek(event) {
    if (!this.audio.src || isNaN(this.audio.duration)) return;
    const bar = event.currentTarget;
    const clickPosition = (event.clientX - bar.getBoundingClientRect().left) / bar.offsetWidth;
    this.audio.currentTime = clickPosition * this.audio.duration;
  }

  toggleMute() {
    if (!this.audio.src) return;
    this.audio.muted = !this.audio.muted;
  }

  setVolume(event) {
    if (!this.audio.src || !this.hasVolumeBarContainerTarget) return;
    const bar = this.volumeBarContainerTarget;
    let volume = (event.clientX - bar.getBoundingClientRect().left) / bar.offsetWidth;
    volume = Math.max(0, Math.min(1, volume));
    this.audio.muted = false;
    this.audio.volume = volume;
  }

  // --- UI Update Methods (Called by Global Handlers) ---

  updateAllIcons() {
    this.updatePlayIcon();
    this.updateAllSongCardIcons();
  }

  updatePlayIcon() {
    if (!this.hasToggleButtonTarget) return;
    const isPaused = this.audio.paused;
    this.toggleIconTarget.classList.toggle("icon--play", isPaused);
    this.toggleIconTarget.classList.toggle("icon--pause", !isPaused);
    this.toggleButtonTarget.title = isPaused ? "Play" : "Pause";
  }

  updateAllSongCardIcons() {
    const allCards = document.querySelectorAll('[data-song-card]');
    allCards.forEach(card => {
      const icon = card.querySelector('[data-song-icon]');
      if (!icon) return;
      const cardUrl = card.dataset.songUrl;
      const isCurrentlyPlayingSong = this.audio.src.endsWith(encodeURI(cardUrl)) && this.audio.src !== "";
      icon.classList.toggle('icon--pause', isCurrentlyPlayingSong && !this.audio.paused);
      icon.classList.toggle('icon--play', !isCurrentlyPlayingSong || this.audio.paused);
    });
  }
  
  updateProgress() {
    if (!this.hasProgressTarget || !this.audio.duration) return;
    const percentage = (this.audio.currentTime / this.audio.duration) * 100;
    this.progressTarget.style.width = `${percentage}%`;
    this.currentTimeTarget.textContent = this.formatTime(this.audio.currentTime);
  }

  updateTime() {
    if (!this.hasDurationTarget || !this.audio.duration) return;
    this.durationTarget.textContent = this.formatTime(this.audio.duration);
  }
  
  updateVolume() {
    if (!this.hasVolumeBarTarget) return;
    this.volumeBarTarget.style.width = this.audio.muted ? '0%' : `${this.audio.volume * 100}%`;
    this.updateVolumeIcon();
  }
  
  updateVolumeIcon() {
    if (!this.hasVolumeIconTarget) return;
    this.volumeIconTarget.classList.remove("icon--volume-2", "icon--volume-1", "icon--volume-x");
    if (this.audio.muted || this.audio.volume === 0) {
      this.volumeIconTarget.classList.add("icon--volume-x");
    } else if (this.audio.volume < 0.5) {
      this.volumeIconTarget.classList.add("icon--volume-1");
    } else {
      this.volumeIconTarget.classList.add("icon--volume-2");
    }
  }
  
  formatTime(seconds) {
    if (isNaN(seconds)) return "0:00";
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  }
}