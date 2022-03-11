terraform {
  backend "s3" {
    bucket = "terrraform-state-indebted-presentation"
    key    = "indebted-presentation/state"
    region = "ap-southeast-2"
  }
}
