resource "google_compute_security_policy" "ingress" {
  name        = "wiz-ingress-policy"
  description = "Cloud Armor policy for the Wiz ingress"

# Enable advanced JSON parsing for WAF evaluation if inspecting API bodies
  advanced_options_config {
    json_parsing = "STANDARD"
  }

  # Rule 1: Rate Limiting (Protects against volumetric abuse, credential stuffing, and brute-forcing)
  rule {
    action   = "rate_based_ban"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)" # Returns HTTP 429 Too Many Requests
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }

      ban_threshold {
        count        = 500
        interval_sec = 60
      }
      ban_duration_sec = 600 # Temporarily ban IP for 10 minutes if limits are aggressively exceeded
    }
    description = "Rate limit to 100 req/min per IP; ban for 10 mins if exceeding 500 req/min"
  }

  # Rule 2: OWASP Top 10 - SQL Injection (SQLi) Protection
  rule {
    action   = "deny(403)"
    priority = 2000
    match {
      expr {
        expression = "evaluateSqlInjection()"
      }
    }
    description = "Block OWASP SQL injection attacks"
  }

  # Rule 3: OWASP Top 10 - Cross-Site Scripting (XSS) Protection
  rule {
    action   = "deny(403)"
    priority = 2001
    match {
      expr {
        expression = "evaluateXss()"
      }
    }
    description = "Block OWASP Cross-Site Scripting attacks"
  }

  # Rule 4: OWASP Top 10 - Remote File Inclusion (RFI) / Local File Inclusion (LFI)
  rule {
    action   = "deny(403)"
    priority = 2002
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rfi-v33-tag', {'sensitivity': 2})"
      }
    }
    description = "Block Remote File Inclusion attacks"
  }

  # Rule 5: OWASP Top 10 - Remote Code Execution (RCE)
  rule {
    action   = "deny(403)"
    priority = 2003
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rce-v33-tag', {'sensitivity': 2})"
      }
    }
    description = "Block Remote Code Execution attacks"
  }
  rule {
    action      = "allow"
    priority    = 2147483647
    description = "Default allow; add protective rules above this"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}