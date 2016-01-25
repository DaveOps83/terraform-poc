output "Cloudtrail trail" { value = "${aws_cloudtrail.cloudtrail.name}" }
output "Cloudtrail S3 bucket" { value = "${aws_s3_bucket.cloudtrail.bucket}" }
