module SongsHelper
  def floating_status_button_data(songs)
    # Priority 1: Check if any songs are actively processing.
    if songs.any? { |s| s.pending? || s.processing? }
      return {
        css_class: "btn--highlight", # A color for "in progress"
        icon: "icon--loading",
        text: "Processing...",
        animate: true
      }
    end

    # Priority 2: Check for a "no credits" error, which is a specific failure state.
    if songs.any?(&:no_credits?)
      return {
        css_class: "btn--negative",
        icon: "icon--circle-alert",
        text: "No Credits",
        animate: false
      }
    end

    # Priority 3: Check for any other general failures.
    if songs.any?(&:failed?)
      return {
        css_class: "btn--negative",
        icon: "icon--circle-alert",
        text: "Error",
        animate: false
      }
    end

    # Default state: If no songs are processing or failed, show the default button.
    # This state will be reached if all songs are `processed`.
    # (The button will be hidden by `return if songs.empty?` if there are no songs at all)
    {
      css_class: "btn--primary", # Your standard button color
      icon: "icon--list-music",
      text: "View Status",
      animate: false
    }
  end
end
