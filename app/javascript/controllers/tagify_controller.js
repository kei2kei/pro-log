import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    mode: String,
    class: String
  }

  connect() {
    if (!window.Tagify) return

    const isSearch = this.modeValue === "search"
    this.tagify = new window.Tagify(this.element, {
      maxTags: isSearch ? 5 : undefined,
      delimiters: ",|\\s|、",
      whitelist: [],
      dropdown: {
        enabled: 0,
        maxItems: 8,
        closeOnSelect: false
      },
      originalInputValueFormat: (values) => values.map((item) => item.value).join(",")
    })

    if (this.hasClassValue) {
      this.classValue.split(" ").forEach((name) => {
        if (name) this.tagify.DOM.scope.classList.add(name)
      })
    }

    if (this.urlValue && !isSearch) {
      this.fetchWhitelist("")
    }

    this.tagify.on("input", this.onInput.bind(this))
  }

  disconnect() {
    if (this.tagify) {
      this.tagify.destroy()
      this.tagify = null
    }
  }

  onInput(e) {
    if (!this.urlValue) return
    const value = e.detail.value || ""

    if (this.modeValue === "search" && value.length < 1) {
      this.tagify.dropdown.hide()
      return
    }

    this.fetchWhitelist(value)
  }

  async fetchWhitelist(query) {
    const url = new URL(this.urlValue, window.location.origin)
    if (query) url.searchParams.set("q", query)

    this.tagify.loading(true)
    try {
      const response = await fetch(url)
      if (!response.ok) return
      const list = await response.json()
      this.tagify.settings.whitelist = list
      this.tagify.dropdown.show.call(this.tagify, query)
    } finally {
      this.tagify.loading(false)
    }
  }
}
