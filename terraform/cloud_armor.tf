resource "google_compute_security_policy" "ingress" {
  name        = "wiz-ingress-policy"
  description = "Cloud Armor policy for the Wiz ingress"

  advanced_options_config {
    json_parsing = "STANDARD"
  }

  # Rule 1: Rate Limiting (Abuse/Brute-force protection)
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
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }

      ban_threshold {
        count        = 500
        interval_sec = 60
      }
      ban_duration_sec = 600
    }
    description = "Rate limit to 100 req/min per IP; ban for 10 mins if exceeding 500 req/min"
  }

  # Rule 2: SQL Injection (SQLi) Protection
  rule {
    action   = "deny(403)"
    priority = 2000
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-v422-stable', {'sensitivity': 2})"
      }
    }
    description = "Block SQL injection attacks"
  }

  # Rule 3: Cross-Site Scripting (XSS) Protection
  rule {
    action   = "deny(403)"
    priority = 2001
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v422-stable', {'sensitivity': 2})"
      }
    }
    description = "Block Cross-Site Scripting attacks"
  }

  # Rule 4: Remote File Inclusion (RFI) Protection
  rule {
    action   = "deny(403)"
    priority = 2002
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rfi-v422-stable', {'sensitivity': 2})"
      }
    }
    description = "Block Remote File Inclusion attacks"
  }

  # Rule 5: Remote Code Execution (RCE) Protection
  rule {
    action   = "deny(403)"
    priority = 2003
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rce-v422-stable', {'sensitivity': 2})"
      }
    }
    description = "Block Remote Code Execution attacks"
  }

  # Default Rule: Allow all other traffic
  rule {
    action   = "allow"
    priority = 2147483647
    description = "Default allow; add protective rules above this"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}