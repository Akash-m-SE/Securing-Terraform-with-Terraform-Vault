provider "aws" {
  region = "eu-central-1"
}

provider "vault" {
  address          = "http://18.199.168.162:8200"
  skip_child_token = true

  #authenticating with hashicorp vault
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = "78cc8185-d68e-1638-1e3e-fb60544b82f2"
      secret_id = "836f264a-d5a3-ad97-43e4-a04bed12d7b7"
    }
  }
}

# Reading the kv secret from the vault
data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test-secret"
}

resource "aws_instance" "ec2-instance-example" {
  ami = "ami-01e444924a2233b07"
  instance_type = "t2.micro"

  tags = {
    secret = data.vault_kv_secret_v2.example.data["username"]    
  }
}

# if we choose to create an s3 bucket and store our secret in it
resource "aws_s3_bucket" "terraform-secret-bucket" {
  bucket = "akash-terraform-vault-secret-bucket"

  tags = {
    mysecret = data.vault_kv_secret_v2.example.data["username"]
  }
}