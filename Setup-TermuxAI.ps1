# ====================================
# ANDROID EMULATOR + TERMUX AI SETUP
# PowerShell automation script for Windows
# ====================================

param(
    [string]$AVDName = "Pixel_7_Pro_API_33",
    [switch]$SkipEmulator,
    [switch]$InstallOnly,
    [switch]$Help
)

# Colors for PowerShell output
$Colors = @{
    Info = "Cyan"
    Success = "Green" 
    Warning = "Yellow"
    Error = "Red"
    Highlight = "Magenta"
}

function Write-ColorMessage {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Colors[$Color]
}

function Show-Banner {
    Clear-Host
    Write-ColorMessage "╔══════════════════════════════════════════════════════════════╗" "Highlight"
    Write-ColorMessage "║            ANDROID EMULATOR + TERMUX AI SETUP               ║" "Highlight"
    Write-ColorMessage "║         🚀 Automated Development Environment Setup          ║" "Highlight"
    Write-ColorMessage "╚══════════════════════════════════════════════════════════════╝" "Highlight"
    Write-Host ""
}

function Show-Help {
    Write-ColorMessage "🚀 Android Emulator + Termux AI Setup Script" "Info"
    Write-Host ""
    Write-ColorMessage "USAGE:" "Highlight"
    Write-Host "  .\Setup-TermuxAI.ps1 [OPTIONS]"
    Write-Host ""
    Write-ColorMessage "OPTIONS:" "Highlight"
    Write-Host "  -AVDName <name>     Specify Android Virtual Device name (default: Pixel_7_Pro_API_33)"
    Write-Host "  -SkipEmulator       Skip emulator launch (use existing running emulator)"
    Write-Host "  -InstallOnly        Only install Termux APK, don't run setup"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-ColorMessage "EXAMPLES:" "Highlight"
    Write-Host "  .\Setup-TermuxAI.ps1                    # Full automated setup"
    Write-Host "  .\Setup-TermuxAI.ps1 -SkipEmulator      # Use running emulator"
    Write-Host "  .\Setup-TermuxAI.ps1 -InstallOnly       # Only install Termux"
    Write-Host ""
    Write-ColorMessage "REQUIREMENTS:" "Warning"
    Write-Host "  - Android Studio with SDK installed"
    Write-Host "  - Android Virtual Device (AVD) created"
    Write-Host "  - Virtualization enabled in BIOS"
    Write-Host "  - Internet connection"
    exit 0
}

function Test-Prerequisites {
    Write-ColorMessage "🔍 Checking prerequisites..." "Info"
    
    # Check if Android SDK exists
    $AndroidHome = $env:ANDROID_HOME
    if (-not $AndroidHome) {
        $AndroidHome = "$env:LOCALAPPDATA\Android\Sdk"
    }
    
    if (-not (Test-Path $AndroidHome)) {
        Write-ColorMessage "❌ Android SDK not found. Please install Android Studio." "Error"
        Write-ColorMessage "Expected location: $AndroidHome" "Warning"
        exit 1
    }
    
    # Set Android environment variables
    $env:ANDROID_HOME = $AndroidHome
    $env:PATH = "$AndroidHome\emulator;$AndroidHome\platform-tools;$env:PATH"
    
    # Check if emulator executable exists
    if (-not (Get-Command "emulator" -ErrorAction SilentlyContinue)) {
        Write-ColorMessage "❌ Android emulator not found in PATH" "Error"
        Write-ColorMessage "Please ensure Android SDK is properly installed" "Warning"
        exit 1
    }
    
    # Check if ADB exists
    if (-not (Get-Command "adb" -ErrorAction SilentlyContinue)) {
        Write-ColorMessage "❌ ADB not found in PATH" "Error"
        exit 1
    }
    
    Write-ColorMessage "✅ Prerequisites verified" "Success"
}

function Get-AvailableAVDs {
    Write-ColorMessage "📱 Available Android Virtual Devices:" "Info"
    $AVDs = & emulator -list-avds
    if ($AVDs) {
        $AVDs | ForEach-Object { Write-Host "  - $_" }
        return $AVDs
    } else {
        Write-ColorMessage "❌ No Android Virtual Devices found" "Error"
        Write-ColorMessage "Please create an AVD in Android Studio first" "Warning"
        exit 1
    }
}

function Start-AndroidEmulator {
    param([string]$AVDName)
    
    # Check if AVD exists
    $AvailableAVDs = & emulator -list-avds
    if ($AvailableAVDs -notcontains $AVDName) {
        Write-ColorMessage "❌ AVD '$AVDName' not found" "Error"
        Get-AvailableAVDs
        exit 1
    }
    
    Write-ColorMessage "�� Starting Android emulator: $AVDName" "Info"
    Write-ColorMessage "⏳ This may take 2-5 minutes..." "Warning"
    
    # Start emulator in background
    $EmulatorArgs = @(
        "-avd", $AVDName,
        "-gpu", "host",
        "-memory", "4096",
        "-cores", "4",
        "-no-audio",
        "-camera-back", "none",
        "-camera-front", "none"
    )
    
    Start-Process -FilePath "emulator" -ArgumentList $EmulatorArgs -WindowStyle Minimized
    
    # Wait for emulator to be ready
    Write-ColorMessage "⏳ Waiting for emulator to boot..." "Info"
    do {
        Start-Sleep 10
        $Devices = & adb devices
        $DeviceReady = $Devices | Where-Object { $_ -match "device$" }
        Write-Host "." -NoNewline
    } while (-not $DeviceReady)
    
    Write-Host ""
    Write-ColorMessage "✅ Android emulator is ready!" "Success"
}

function Get-TermuxAPK {
    Write-ColorMessage "📥 Downloading latest Termux APK..." "Info"
    
    try {
        # Get latest release info from GitHub
        $LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/termux/termux-app/releases/latest"
        $APKAsset = $LatestRelease.assets | Where-Object { $_.name -like "*universal.apk" } | Select-Object -First 1
        
        if (-not $APKAsset) {
            throw "Universal APK not found in latest release"
        }
        
        $APKPath = "termux-latest.apk"
        Invoke-WebRequest -Uri $APKAsset.browser_download_url -OutFile $APKPath -ProgressAction SilentlyContinue
        
        Write-ColorMessage "✅ Downloaded: $APKPath ($([math]::Round((Get-Item $APKPath).Length / 1MB, 2)) MB)" "Success"
        return $APKPath
    }
    catch {
        Write-ColorMessage "❌ Failed to download Termux APK: $($_.Exception.Message)" "Error"
        Write-ColorMessage "Please download manually from: https://github.com/termux/termux-app/releases" "Warning"
        exit 1
    }
}

function Install-TermuxAPK {
    param([string]$APKPath)
    
    Write-ColorMessage "📦 Installing Termux APK..." "Info"
    
    # Check if device is connected
    $Devices = & adb devices
    if ($Devices -notmatch "device$") {
        Write-ColorMessage "❌ No Android device/emulator connected" "Error"
        Write-ColorMessage "Please ensure emulator is running" "Warning"
        exit 1
    }
    
    # Install APK
    $InstallResult = & adb install $APKPath 2>&1
    if ($InstallResult -like "*Success*") {
        Write-ColorMessage "✅ Termux installed successfully!" "Success"
    } else {
        Write-ColorMessage "⚠️  Installation result: $InstallResult" "Warning"
        if ($InstallResult -like "*INSTALL_FAILED_ALREADY_EXISTS*") {
            Write-ColorMessage "📱 Termux already installed, continuing..." "Info"
        }
    }
}

function Show-InstallationInstructions {
    Write-ColorMessage "🎉 Setup Phase Complete!" "Success"
    Write-Host ""
    Write-ColorMessage "NEXT STEPS:" "Highlight"
    Write-Host ""
    Write-ColorMessage "1. 📱 Open Termux app in the Android emulator" "Info"
    Write-Host ""
    Write-ColorMessage "2. 🚀 Run the quick installation command:" "Info"
    Write-Host ""
    Write-ColorMessage "wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash" "Highlight"
    Write-Host ""
    Write-ColorMessage "3. ⏳ Wait for installation to complete (5-15 minutes)" "Info"
    Write-Host ""
    Write-ColorMessage "4. �� Access your AI development environment!" "Success"
    Write-Host ""
    Write-ColorMessage "ALTERNATIVE MANUAL INSTALLATION:" "Info"
    Write-ColorMessage "pkg update && pkg upgrade" "Warning"
    Write-ColorMessage "pkg install curl wget git" "Warning"
    Write-ColorMessage "wget -O setup.sh https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/setup.sh" "Warning"
    Write-ColorMessage "chmod +x setup.sh && ./setup.sh" "Warning"
    Write-Host ""
}

function Connect-ADBShell {
    Write-ColorMessage "🔌 Connecting to Android device via ADB..." "Info"
    Write-ColorMessage "Type 'exit' to return to PowerShell" "Warning"
    & adb shell
}

# Main execution
function Main {
    if ($Help) {
        Show-Help
    }
    
    Show-Banner
    Test-Prerequisites
    
    # Step 1: Start emulator (unless skipped)
    if (-not $SkipEmulator) {
        Get-AvailableAVDs | Out-Null
        Start-AndroidEmulator -AVDName $AVDName
    } else {
        Write-ColorMessage "⏭️  Skipping emulator launch (using existing)" "Info"
        
        # Verify device is connected
        $Devices = & adb devices
        if ($Devices -notmatch "device$") {
            Write-ColorMessage "❌ No Android device connected. Please start emulator first." "Error"
            exit 1
        }
    }
    
    # Step 2: Download and install Termux
    if (Test-Path "termux-latest.apk") {
        Write-ColorMessage "📦 Using existing Termux APK" "Info"
        $APKPath = "termux-latest.apk"
    } else {
        $APKPath = Get-TermuxAPK
    }
    
    Install-TermuxAPK -APKPath $APKPath
    
    # Step 3: Show instructions or connect to shell
    if ($InstallOnly) {
        Write-ColorMessage "✅ Termux installation complete!" "Success"
        Write-ColorMessage "Run script without -InstallOnly to continue with setup" "Info"
    } else {
        Show-InstallationInstructions
        
        # Ask user if they want to connect to ADB shell
        $ConnectShell = Read-Host "📱 Connect to Android shell now? (y/N)"
        if ($ConnectShell -eq "y" -or $ConnectShell -eq "Y") {
            Connect-ADBShell
        }
    }
    
    Write-ColorMessage "🎉 PowerShell automation complete!" "Success"
}

# Execute main function
Main
