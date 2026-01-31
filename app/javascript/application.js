// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

const shouldShowLoading = (event) => {
  const form = event?.detail?.formSubmission?.form || event?.target
  if (form?.dataset?.loading === "skip") return false
  if (form?.dataset?.loadingSkip === "true") return false
  return true
}

document.addEventListener("turbo:visit", () => {
  document.documentElement.dataset.loading = "true"
})

document.addEventListener("turbo:submit-start", (event) => {
  if (!shouldShowLoading(event)) return
  document.documentElement.dataset.loading = "true"
})

document.addEventListener("turbo:load", () => {
  document.documentElement.dataset.loading = "false"
})

document.addEventListener("turbo:submit-end", (event) => {
  if (!shouldShowLoading(event)) return
  document.documentElement.dataset.loading = "false"
})
