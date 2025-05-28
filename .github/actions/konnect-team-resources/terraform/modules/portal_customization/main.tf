terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_portal_customization" "this" {
  provider  = konnect-beta
  portal_id = var.portal_id

  # Custom CSS
  css = var.css

  # JavaScript configuration
  js = var.js

  # Layout template
  layout = var.layout

  # Menu configuration
  menu = var.menu

  # Robots.txt content
  robots = var.robots

  # Spec renderer configuration
  spec_renderer = var.spec_renderer

  # Theme configuration
  theme = var.theme
}
