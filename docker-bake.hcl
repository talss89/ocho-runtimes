# docker-bake.hcl

variable "OCHO_TARGET_PLATFORM" {
  default = "linux/amd64"
}

variable "PHP_VERSION" {
  default = "8.2"
}

variable "WP_CLI_VERSION" {
  default = "2.9.0"
}

variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["php", "openresty", "bedrock", "bedrock-build", "wordpress-vanilla"]
}

target "php" {
  tags = ["ghcr.io/talss89/ocho-php-${PHP_VERSION}:${TAG}"]
  args = {
    PHP_VERSION = "${PHP_VERSION}"
  }
  dockerfile = "./php/Dockerfile"
  context = "."
  platforms = ["${OCHO_TARGET_PLATFORM}"]
}

target "openresty" {
  tags = ["ghcr.io/talss89/ocho-openresty:${TAG}"]
  dockerfile = "./openresty/Dockerfile"
  context = "."
  platforms = ["${OCHO_TARGET_PLATFORM}"]
}

target "bedrock" {
  tags = ["ghcr.io/talss89/ocho-bedrock-${PHP_VERSION}:${TAG}"]
  dockerfile = "./wordpress/bedrock.Dockerfile"
  context = "."
  contexts = {
    php = "target:php"
  }
  args = {
    WP_CLI_VERSION = "${WP_CLI_VERSION}"
  }
  platforms = ["${OCHO_TARGET_PLATFORM}"]
}

target "bedrock-build" {
  tags = ["ghcr.io/talss89/ocho-bedrock-build-${PHP_VERSION}:${TAG}"]
  dockerfile = "./wordpress/bedrock.build.Dockerfile"
  context = "."
  contexts = {
    bedrock = "target:bedrock"
  }
  platforms = ["${OCHO_TARGET_PLATFORM}"]
}

target "wordpress-vanilla" {
  name = "wordpress-vanilla-${replace(wp_version, ".", "-")}"
  matrix = {
    wp_version = ["6.3.2", "6.4.1"]
  }
  tags = ["ghcr.io/talss89/ocho-wordpress-${wp_version}-php-${PHP_VERSION}:${TAG}"]
  dockerfile = "./wordpress/bedrock.build.Dockerfile"
  context = "."
  contexts = {
    bedrock = "target:bedrock"
  }
  args = {
    WORDPRESS_VERSION = "${wp_version}"
  }
  platforms = ["${OCHO_TARGET_PLATFORM}"]
}
