# WRB Workspace Rename Script
# This script helps rename the workspace from TheBigWRB to WRB

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  WRB Workspace Rename Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Get current directory
$currentDir = Get-Location
Write-Host "Current directory: $currentDir" -ForegroundColor Yellow

# Check if we're in the TheBigWRB directory
if ($currentDir.Name -eq "TheBigWRB") {
    Write-Host "✅ Found TheBigWRB directory" -ForegroundColor Green
    
    # Navigate to parent directory
    Set-Location ..
    Write-Host "📁 Navigated to parent directory: $(Get-Location)" -ForegroundColor Yellow
    
    # Rename the directory
    try {
        Rename-Item "TheBigWRB" "WRB" -Force
        Write-Host "✅ Successfully renamed TheBigWRB to WRB" -ForegroundColor Green
        Write-Host ""
        Write-Host "📁 New directory structure:" -ForegroundColor Cyan
        Get-ChildItem "WRB" | Format-Table Name, Mode -AutoSize
        Write-Host ""
        Write-Host "🎯 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Close your current IDE/editor" -ForegroundColor White
        Write-Host "2. Open the new WRB folder as your workspace" -ForegroundColor White
        Write-Host "3. All file references will automatically update" -ForegroundColor White
    }
    catch {
        Write-Host "❌ Error renaming directory: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 You may need to close applications using the folder first" -ForegroundColor Yellow
    }
}
else {
    Write-Host "❌ Not in TheBigWRB directory" -ForegroundColor Red
    Write-Host "💡 Please run this script from inside the TheBigWRB folder" -ForegroundColor Yellow
    Write-Host "   Or manually rename the folder in Windows Explorer" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
