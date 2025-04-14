output "route53_name_servers" {
  value = aws_route53_zone.main.name_servers
}

# Output DS record
output "ds_record" {
  description = "Formatted DS record for registrar"
  value = format("%s %s %s %s",
    aws_route53_key_signing_key.main.key_tag,
    aws_route53_key_signing_key.main.signing_algorithm_mnemonic,
    aws_route53_key_signing_key.main.digest_algorithm_mnemonic,
    aws_route53_key_signing_key.main.digest_value
  )
}