# Prefix for resource names to ensure uniqueness
variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

# Azure region for resources
variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Admin username for the SQL server
variable "admin_username" {
  description = "Admin username for SQL Server"
  type        = string
}

# Admin password for the SQL server (sensitive information)
variable "admin_password" {
  description = "Admin password for the SQL server"
  type        = string
  sensitive   = true
}

variable "sql_db_name" {
  description = "SQL database name"
  type        = string
}

# Password for the SSL Certificate (sensitive information)
variable "certificate_password" {
  description = "Password for the SSL Certificate"
  type        = string
  sensitive   = true
}

variable "ssl_certificate" {
  description = "Base64 encoded SSL certificate"
  type        = string
}