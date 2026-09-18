$source = @"
using System;
public class TestChecker {
    public static string Ping() { return "OK"; }
}
"@
Add-Type -TypeDefinition $source
Write-Output ([TestChecker]::Ping())
