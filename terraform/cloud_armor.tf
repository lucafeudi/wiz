resource "google_compute_security_policy" "ingress" {
  name        = "wiz-ingress-policy"
  description = "Cloud Armor policy for the Wiz ingress"

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