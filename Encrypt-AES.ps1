# Function to encrypt a string using AES encryption
Function Encrypt-AES
{
<#
.SYNOPSIS
    This function encrypts a string using AES encryption with a provided key.

.DESCRIPTION
    - This function takes an input string and an encryption key to perform AES encryption.
    - It generates a random initialization vector (IV) and returns the encrypted string along with the IV.
    - The encrypted string is returned in Base64 format, with the IV and encrypted data separated by a special character ("###").
    
.PARAMETERS
    - $InputString (String) : The string that will be encrypted.
    - $EncryptionKey (String) : The encryption key used for AES encryption (must be 32 characters long).
    
.EXAMPLE
    $EncryptedString = Encrypt-AES -InputString "Hello, World!" -EncryptionKey "MyEncryptionKey12345678"
    This example encrypts the string "Hello, World!" using the specified encryption key.

.NOTES
    Created by: Carl-Étienne Brière
#>
    Param
    (
        [String]$InputString,   # The string to be encrypted
        [String]$EncryptionKey  # The encryption key (must be 32 characters long)
    )
    
    Try
    {
        # Convert the encryption key to a byte array of the correct size (32 bytes)
        $KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($EncryptionKey.PadRight(32, '0').Substring(0, 32))
        # Initialize the AES encryption object with the key
        $AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
        $AES.Key = $KeyBytes
        $AES.GenerateIV()  # Generate a random initialization vector (IV)
        
        # Convert the input string to a byte array
        $InputBytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        
        # Encrypt the byte array
        $EncryptedBytes = $AES.CreateEncryptor().TransformFinalBlock($InputBytes, 0, $InputBytes.Length)
        
        # Convert the IV and encrypted data to Base64 for storage
        $IVBase64 = [System.Convert]::ToBase64String($AES.IV)
        $EncryptedBase64 = [System.Convert]::ToBase64String($EncryptedBytes)
        
        # Concatenate IV and encrypted string with a special separator
        $ResultString = $IVBase64 + "###" + $EncryptedBase64
        Return $ResultString
    }
    Catch
    {
        Return $False
    }
}
