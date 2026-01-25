import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  normalize() {
    const groups = new Map()
    const fields = this.element.querySelectorAll("[data-range-order-group]")

    fields.forEach((field) => {
      const group = field.dataset.rangeOrderGroup
      const kind = field.dataset.rangeOrderKind
      if (!groups.has(group)) {
        groups.set(group, {})
      }
      groups.get(group)[kind] = field
    })

    groups.forEach(({ min, max }) => {
      if (!min || !max) return
      const minValue = parseFloat(min.value)
      const maxValue = parseFloat(max.value)
      if (Number.isNaN(minValue) || Number.isNaN(maxValue)) return
      if (minValue > maxValue) {
        const temp = min.value
        min.value = max.value
        max.value = temp
      }
    })
  }
}
