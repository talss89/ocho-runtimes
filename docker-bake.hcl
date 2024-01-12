# docker-bake.hcl
variable "PHP_VERSION" {
  default = "8.2"
}

variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["php", "openresty"]
}

target "php" {
  tags = ["ghcr.io/ocho/ocho-php-${PHP_VERSION}:${TAG}"]
  args = {
    PHP_VERSION = "${PHP_VERSION}"
  }
  dockerfile = "./php/Dockerfile"
  context = "."
  platforms = ["linux/amd64", "linux/arm64"]
}

target "openresty" {
  tags = ["ghcr.io/ocho/ocho-openresty:${TAG}"]
  dockerfile = "./openresty/Dockerfile"
  context = "."
  platforms = ["linux/amd64", "linux/arm64"]
}
