Function Invoke-TTS
{
    <#
    .SYNOPSIS
        Converts text to speech using the built-in Windows speech synthesizer.
    
    .DESCRIPTION
        - This function utilizes the System.Speech.Synthesis.SpeechSynthesizer class to read aloud the specified text.
        - It provides a simple way to generate speech output from a given string.
    
    .INPUTS
        - $Text (String) : The text to be spoken.
    
    .EXAMPLE
        Invoke-TTS -Text "Hello, how are you?"
        This command will use the speech synthesizer to say "Hello, how are you?".
    
    .NOTES
        Created by: Carl-Étienne Brière
    #>
    Param
    (
        [String]$Text
    )
    Add-Type -AssemblyName System.Speech
    $SpeechBot = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $SpeechBot.Speak($Text)
}
