
variable region {
  type = string
}

variable project {
  type = string
}

variable tooling-account {
  type = string
}

variable artifact-name {
  type = string
}

variable attached-policies {
  type = map(array(object({ 
    effect = string
    actions = any
    resource = string
  })))
}
