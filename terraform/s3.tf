resource "aws_s3_bucket" "prod_media" {
  bucket = var.prod_media_bucket
}

resource "aws_s3_bucket_ownership_controls" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "prod_media" {
  depends_on = [
    aws_s3_bucket_ownership_controls.prod_media,
    aws_s3_bucket_public_access_block.prod_media,
  ]

  bucket = aws_s3_bucket.prod_media.id
  acl    = "public-read"
}

resource "aws_iam_user" "prod_media_bucket" {
  name = "prod-media-bucket"
}

resource "aws_iam_user_policy" "prod_media_bucket" {
  user = aws_iam_user.prod_media_bucket.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.prod_media_bucket}",
          "arn:aws:s3:::${var.prod_media_bucket}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_access_key" "prod_media_bucket" {
  user = aws_iam_user.prod_media_bucket.name
}
