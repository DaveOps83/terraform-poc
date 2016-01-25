provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${lookup(var.region, var.aws_target_env)}"
}

resource "aws_s3_bucket" "cloudtrail" {
    bucket = "ttc-${var.aws_target_env}-cloudtrail"
    force_destroy = true
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::ttc-${var.aws_target_env}-cloudtrail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::ttc-${var.aws_target_env}-cloudtrail/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudtrail" "cloudtrail" {
    name = "ttc-${var.aws_target_env}"
    s3_bucket_name = "${aws_s3_bucket.cloudtrail.id}"
}
