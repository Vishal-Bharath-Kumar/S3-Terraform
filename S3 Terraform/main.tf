resource "aws_s3_bucket" "react-hosting" {
  bucket = var.bucket_name

  tags = {
    Name        = "Vishal"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_ownership_controls" "bucket-owner" {
  bucket = aws_s3_bucket.react-hosting.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.react-hosting.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_acl" "bucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket-owner,
    aws_s3_bucket_public_access_block.public-access,
  ]

  bucket = aws_s3_bucket.react-hosting.id
  acl    = "public-read"
}
resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.react-hosting.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
  depends_on = [ aws_s3_bucket_acl.bucket-acl ]
}
data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
     "arn:aws:s3:::react-demo-deployment004", 
      "arn:aws:s3:::react-demo-deployment004/*",
    ]
  }
}
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.react-hosting.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}