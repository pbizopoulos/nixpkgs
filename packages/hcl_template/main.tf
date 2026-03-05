variable "message" {
  type    = string
  default = "Hello HCL!"
}
output "message" {
  value = var.message
}
