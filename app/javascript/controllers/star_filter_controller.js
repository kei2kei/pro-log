import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "input"]

  connect() {
    this.setActive(this.currentValue())
  }

  select(event) {
    const score = Number(event.currentTarget.dataset.score)
    const next = this.currentValue() === score ? 0 : score
    this.inputTarget.value = next
    this.setActive(next)
  }

  currentValue() {
    return Number(this.inputTarget.value || 0)
  }

  setActive(value) {
    this.buttonTargets.forEach((button) => {
      const score = Number(button.dataset.score)
      button.classList.toggle("text-accent", score <= value)
      button.classList.toggle("text-stone-300", score > value)
    })
  }
}
