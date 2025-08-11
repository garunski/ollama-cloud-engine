# Minimal egress-only firewall (no inbound)

resource "google_compute_firewall" "egress_all" {
  name    = "${var.instance_name}-egress"
  network = google_compute_network.vpc.name

  direction   = "EGRESS"
  priority    = 1000
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
}


