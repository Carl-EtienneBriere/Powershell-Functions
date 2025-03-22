# Function to decrypt an AES encrypted string
Function Decrypt-AES
{
<#
.SYNOPSIS
    This function decrypts a string that was encrypted using AES encryption.

.DESCRIPTION
    - This function takes an encrypted string and the corresponding encryption key to perform AES decryption.
    - It extracts the initialization vector (IV) and the encrypted data from the input string and returns the original string.
    
.PARAMETERS
    - $EncryptedString (String) : The Base64 encoded encrypted string to be decrypted.
    - $EncryptionKey (String) : The encryption key used for AES decryption (must be 32 characters long).
    
.EXAMPLE
    $DecryptedString = Decrypt-AES -EncryptedString $EncryptedString -EncryptionKey "MyEncryptionKey12345678"
    This example decrypts the string that was previously encrypted using the specified encryption key.

.NOTES
    Created by: Carl-Étienne Brière
#>
    Param
    (
        [String]$EncryptedString,  # The encrypted string to be decrypted
        [String]$EncryptionKey     # The encryption key used for decryption (must be 32 characters long)
    )
    Try
    {
        # Convert the encryption key to a byte array of the correct size (32 bytes)
        $KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($EncryptionKey.PadRight(32, '0').Substring(0, 32))
        
        # Split the encrypted string into IV and encrypted data
        $IVBase64, $EncryptedBase64 = $EncryptedString -Split "###"
        
        # Convert the IV and encrypted data from Base64 to byte arrays
        $AESIV = [System.Convert]::FromBase64String($IVBase64)
        $EncryptedBytes = [System.Convert]::FromBase64String($EncryptedBase64)
        
        # Initialize the AES decryption object with the key and IV
        $AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
        $AES.Key = $KeyBytes
        $AES.IV = $AESIV
        
        # Decrypt the byte array
        $DecryptedBytes = $AES.CreateDecryptor().TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)
        
        # Convert the decrypted byte array back to a string
        $DecryptedString = [System.Text.Encoding]::UTF8.GetString($DecryptedBytes)
        Return $DecryptedString
    }
    Catch
    {
        Return $False
    }
}
