variable "amis" {
  type = map(string)
  default = {
    "your-region" = "your-ami" 
    "your-region-2" = "your-ami2" 
  }
}