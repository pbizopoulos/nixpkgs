variable "message" {
  type    = string
  default = "Hello World"
}
output "message" {
  value = var.message
}
