variable "mysql_root_password" {
  description = "The root password for MySQL"
  type        = string
  sensitive   = true
}

variable "mysql_database" {
  description = "The name of the MySQL database"
  type        = string
}

variable "mysql_user" {
  description = "The MySQL username"
  type        = string
}

variable "mysql_password" {
  description = "The password for the MySQL user"
  type        = string
  sensitive   = true
}

variable "database_host" {
  description = "The host for the MySQL database"
  type        = string
}

variable "port" {
  description = "The port for the MySQL database"
  type        = number
}

variable "flask_env" {
  description = "The Flask environment (development or production)"
  type        = string
}


variable "image_tag" {
  description = "The tag of the Docker image for the Flask app"
  type        = string
}
