import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowCount", "rowsBody", "status"]
  static values = { suggestUrl: String }

  addFive() {
    this.addRows(5)
  }

  async submitSuggest(event) {
    event?.preventDefault()
    this.setLoading(true)
    this.setStatus("")

    try {
      const csrfToken = document.querySelector("meta[name='csrf-token']")?.content || ""
      const formData = new FormData(this.element)
      const requestUrl = this.suggestUrlValue.endsWith(".json") ? this.suggestUrlValue : `${this.suggestUrlValue}.json`

      const response = await fetch(requestUrl, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: formData,
        credentials: "same-origin"
      })

      const payload = await response.json().catch(() => ({}))
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || "AI補完に失敗しました。")
      }

      const rows = Array.isArray(payload.rows) ? payload.rows : []
      this.replaceRows(rows)
      this.setStatus(payload.message || "AI補完を実行しました。", "notice")
    } catch (error) {
      this.setStatus(error.message, "alert")
    } finally {
      this.setLoading(false)
    }
  }

  addRows(count) {
    const startIndex = this.currentRowCount()

    for (let i = 0; i < count; i += 1) {
      const rowIndex = startIndex + i
      this.rowsBodyTarget.insertAdjacentHTML("beforeend", this.buildRowHtml(rowIndex))
    }

    this.rowCountTarget.value = String(startIndex + count)
  }

  currentRowCount() {
    const value = Number.parseInt(this.rowCountTarget.value || "0", 10)
    return Number.isNaN(value) ? this.rowsBodyTarget.querySelectorAll("tr").length : value
  }

  buildRowHtml(index) {
    return this.buildRowHtmlWithData(index, {})
  }

  replaceRows(rows) {
    const targetCount = Math.max(rows.length, 5)
    const normalized = [...rows]
    while (normalized.length < targetCount) normalized.push({})

    this.rowsBodyTarget.innerHTML = normalized
      .map((row, idx) => this.buildRowHtmlWithData(idx, row))
      .join("")

    this.rowCountTarget.value = String(targetCount)
  }

  buildRowHtmlWithData(index, row) {
    const value = (key) => this.escapeHtml(row?.[key] ?? "")
    return `
      <tr class="border-b border-stone-100">
        <td class="px-2 py-2"><input type="text" name="bulk[items][${index}][flavor]" value="${value("flavor")}" class="w-40 rounded border border-base px-2 py-1" /></td>
        <td class="px-2 py-2"><input type="number" name="bulk[items][${index}][price]" value="${value("price")}" class="w-24 rounded border border-base px-2 py-1" /></td>
        <td class="px-2 py-2"><input type="number" name="bulk[items][${index}][calorie]" value="${value("calorie")}" step="0.1" class="w-20 rounded border border-base px-2 py-1" /></td>
        <td class="px-2 py-2"><input type="number" name="bulk[items][${index}][protein]" value="${value("protein")}" step="0.1" class="w-20 rounded border border-base px-2 py-1" /></td>
        <td class="px-2 py-2"><input type="number" name="bulk[items][${index}][fat]" value="${value("fat")}" step="0.1" class="w-20 rounded border border-base px-2 py-1" /></td>
        <td class="px-2 py-2"><input type="number" name="bulk[items][${index}][carbohydrate]" value="${value("carbohydrate")}" step="0.1" class="w-20 rounded border border-base px-2 py-1" /></td>
        <td class="px-2 py-2"><input type="text" name="bulk[items][${index}][image_url]" value="${value("image_url")}" class="w-56 rounded border border-base px-2 py-1" /></td>
        <td class="px-2 py-2"><input type="text" name="bulk[items][${index}][reference_url]" value="${value("reference_url")}" class="w-56 rounded border border-base px-2 py-1" /></td>
      </tr>
    `
  }

  setStatus(message, kind = "notice") {
    if (!this.hasStatusTarget) return
    if (!message) {
      this.statusTarget.textContent = ""
      this.statusTarget.classList.add("hidden")
      this.statusTarget.className = "hidden rounded-lg px-3 py-2 text-xs font-semibold"
      return
    }

    this.statusTarget.textContent = message
    this.statusTarget.className = "rounded-lg px-3 py-2 text-xs font-semibold"
    if (kind === "alert") {
      this.statusTarget.classList.add("bg-rose-50", "text-rose-700", "border", "border-rose-200")
    } else {
      this.statusTarget.classList.add("bg-emerald-50", "text-emerald-700", "border", "border-emerald-200")
    }
  }

  setLoading(value) {
    document.documentElement.dataset.loading = value ? "true" : "false"
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}
