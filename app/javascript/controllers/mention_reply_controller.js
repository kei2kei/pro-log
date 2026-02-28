import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  reply(event) {
    event.preventDefault()

    if (!this.hasTextareaTarget) return

    const username = event.params.username
    if (!username) return

    const mention = `@${username} `
    const textarea = this.textareaTarget
    const currentValue = textarea.value || ""

    if (currentValue.includes(mention)) {
      textarea.focus()
      return
    }

    const separator = currentValue.length > 0 && !currentValue.endsWith("\n") ? "\n" : ""
    textarea.value = `${currentValue}${separator}${mention}`
    textarea.focus()
    textarea.setSelectionRange(textarea.value.length, textarea.value.length)
    textarea.dispatchEvent(new Event("input", { bubbles: true }))
  }
}
