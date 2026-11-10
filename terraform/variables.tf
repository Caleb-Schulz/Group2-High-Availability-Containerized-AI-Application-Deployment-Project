variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "GCP deployment region"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP deployment zone"
  type        = string
  default     = "us-east1-b"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"
}
