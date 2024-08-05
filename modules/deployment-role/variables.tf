
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
  type = map(list(object({ 
    effect = optional(string)
    actions = optional(set(string))
    resources = optional(set(string))
  })))
}
