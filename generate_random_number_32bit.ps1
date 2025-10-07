# Generate 32 cryptographically-strong random bytes
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)

# Convert to lowercase hex (64 chars = 32 bytes)
$hex = ($bytes | ForEach-Object { $_.ToString("x2") }) -join ''
$hex