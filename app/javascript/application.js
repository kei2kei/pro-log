// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener("turbo:visit", () => {
  document.documentElement.dataset.loading = "true"
})

document.addEventListener("turbo:submit-start", () => {
  document.documentElement.dataset.loading = "true"
})

document.addEventListener("turbo:load", () => {
  document.documentElement.dataset.loading = "false"
})

document.addEventListener("turbo:submit-end", () => {
  document.documentElement.dataset.loading = "false"
})
