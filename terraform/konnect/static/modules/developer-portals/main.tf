terraform {
    required_providers {
    konnect-beta = {
      source  = "kong/konnect-beta"
    }
  }
}

# Demo portal
resource "konnect_portal" "portal" {
 provider = konnect-beta
  authentication_enabled               = true
  auto_approve_applications            = false
  auto_approve_developers              = false
  default_api_visibility               = "public"
  #default_application_auth_strategy_id = "e7d77a5f-c5f5-49db-9b2f-cabb4401add8"
  default_page_visibility              = "private"
  description                          = "KongAir API Developer Portal"
  display_name                         = "KongAir API Developer Portal"
  labels = {
    key = "value"
  }
  name         = "KongAir API Developer Portal"
  rbac_enabled = true
}

resource "konnect_portal_auth" "portalauth" {
  provider = konnect-beta
  basic_auth_enabled      = false
  idp_mapping_enabled     = false
  konnect_mapping_enabled = true
  oidc_auth_enabled       = true
  oidc_claim_mappings = {
    email  = "email"
    groups = "groups"
    name   = "name"
  }
  oidc_client_id     = var.konnect_portal_oidc_client_id
  oidc_client_secret = var.konnect_portal_oidc_client_secret
  oidc_issuer        = var.konnect_portal_oidc_issuer
  oidc_scopes = [
    "openid",
    "email",
    "profile"
  ]
  oidc_team_mapping_enabled = false
  portal_id                 = konnect_portal.portal.id
  saml_auth_enabled         = false
}

resource "konnect_portal_team" "api_developers_portal_team" {
  provider = konnect-beta
  description = "The API Developers Team that can access the API Developer Portal"
  name        = "API Developers"
  portal_id   = konnect_portal.portal.id
}

resource "konnect_portal_custom_domain" "portalcustomdomain" {
  provider  = konnect-beta
  enabled   = false
  hostname  = "portal.kongair.xyz"
  portal_id = konnect_portal.portal.id
  ssl = {
    domain_verification_method = "http"
  }
}

locals {
  pages = [
    {
      title      = "Home"
      slug       = "/"
      visibility = "public"
      filename   = "home.md"
    },
    {
      title      = "About"
      slug       = "/about"
      visibility = "public"
      filename   = "about.md"
    },
    {
      title      = "APIs"
      slug       = "/apis"
      visibility = "public"
      filename   = "apis.md"
    },
    {
      title      = "Getting Started"
      slug       = "/getting-started"
      slug       = "/getting-started"
      visibility = "public"
      filename   = "getting-started.md"
    }
  ]
}

resource "konnect_portal_page" "portalpage" {
  provider = konnect-beta
  for_each = { for page in local.pages : page.slug => page }

  content        = file("modules/developer-portals/pages/${each.value.filename}")
  description    = each.value.title
  parent_page_id = null
  portal_id      = konnect_portal.portal.id
  slug           = each.value.slug
  status         = "published"
  title          = each.value.title
  visibility     = each.value.visibility
}

# resource "konnect_portal_snippet" "portalsnippet" {
#   provider    = konnect-beta
#   content     = "# Welcome to My Snippet"
#   description = "A custom page about developer portals"
#   name        = "my-snippet"
#   portal_id   = konnect_portal.portal.id
#   status      = "published"
#   title       = "My Snippet"
#   visibility  = "public"
# }


resource "konnect_portal_customization" "portalcustomization" {
  provider = konnect-beta

  menu = {
    main = [
      {
        external   = false
        path       = "/about"
        title      = "About"
        visibility = "public"
      },
      {
        external   = false
        path       = "/apis"
        title      = "APIs"
        visibility = "public"
      },
      {
        external   = false
        path       = "/getting-started"
        title      = "Getting Started"
        visibility = "public"
      }
      # {
      #   external   = false
      #   path       = "/secret"
      #   title      = "Secret"
      #   visibility = "private"
      # }
    ]

    footer_sections = [
      {
        title = "Products"
        items = [
          {
            external   = false
            path       = "/"
            title      = "Pricing"
            visibility = "public"
          },
          {
            external   = false
            path       = "/"
            title      = "APIs"
            visibility = "public"
          },
          {
            external   = false
            path       = "/"
            title      = "Documentation"
            visibility = "public"
          }
        ]
      },
      {
        title = "Company"
        items = [
          {
            external   = false
            path       = "/"
            title      = "About"
            visibility = "public"
          },
          {
            external   = false
            path       = "/"
            title      = "Careers"
            visibility = "public"
          },
          {
            external   = false
            path       = "/"
            title      = "Contact Us"
            visibility = "public"
          }
        ]
      },
      {
        title = "Legal"
        items = [
          {
            external   = false
            path       = "/"
            title      = "Privacy Policy"
            visibility = "public"
          },
          {
            external   = false
            path       = "/"
            title      = "Terms of Service"
            visibility = "public"
          }
        ]
      }
    ]

    footer_bottom = [
      {
        external   = false
        path       = "/"
        title      = "@ Cpyright 2025 KongAir"
        visibility = "public"
      }
    ]
  }

  portal_id = konnect_portal.portal.id
  spec_renderer = {
    infinite_scroll = true
    show_schemas    = false
    try_it_insomnia = false
    try_it_ui       = true
  }
  theme = {
    mode = "system"
  }
}

