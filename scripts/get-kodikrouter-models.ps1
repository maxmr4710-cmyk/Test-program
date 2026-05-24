param(
    [switch]$Help,
    [switch]$UpdateRoomodes,
    [switch]$Interactive
)

function Show-Help {
    Write-Host "Usage: .\scripts\get-kodikrouter-models.ps1 [-UpdateRoomodes] [-Interactive]"
    Write-Host "       .\scripts\get-kodikrouter-models.ps1 -Help"
    Write-Host ""
    Write-Host "Fetch KodikRouter models, show available IDs, and optionally update .roomodes."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -UpdateRoomodes  Update or create .roomodes entries for predefined agent slugs."
    Write-Host "  -Interactive     Prompt to choose a model when multiple matches exist."
}

function Fail {
    param([string]$Message)
    Write-Error $Message
    exit 1
}

if ($Help) {
    Show-Help
    return
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $root '..')
$envPath = Join-Path $projectRoot '.env'
$roomodesPath = Join-Path $projectRoot '.roomodes'

if (-not (Test-Path $envPath)) {
    Fail "File .env not found in project root."
}

$envLines = Get-Content $envPath -ErrorAction Stop
$keyLine = $envLines | Where-Object { $_ -match '^\s*KODIKROUTER_API_KEY\s*=' } | Select-Object -First 1
if (-not $keyLine) {
    Fail "KODIKROUTER_API_KEY not found in .env."
}

$key = $keyLine.Split('=')[1].Trim()
$key = $key.Trim('"').Trim("'")
if ([string]::IsNullOrEmpty($key)) {
    Fail "KODIKROUTER_API_KEY is empty or invalid in .env."
}

Write-Host "Using KODIKROUTER_API_KEY from .env." -ForegroundColor Cyan

$uri = 'https://api.kodikrouter.ru/v1/models'
try {
    $response = Invoke-RestMethod -Uri $uri -Headers @{ Authorization = "Bearer $key" } -Method Get -ContentType 'application/json'
} catch {
    Fail "Failed to fetch KodikRouter models: $($_.Exception.Message)"
}

if (-not $response -or -not $response.data) {
    Fail "Empty or invalid response from KodikRouter."
}

$availableIds = $response.data | ForEach-Object { $_.id }
Write-Host "Available models count: $($availableIds.Count)" -ForegroundColor Green
$response.data | Select-Object @{ Name='ID'; Expression={ $_.id } }, @{ Name='Type'; Expression={ $_.object } } | Format-Table -AutoSize

$agentCandidates = @{
    'orchestrator' = @('deepseek/deepseek-v4-pro', 'deepseek/deepseek-v4-flash', 'deepseek/deepseek-chat-v3.1', 'deepseek/deepseek-v3.2-exp')
    'deepseek-architect' = @('deepseek/deepseek-v4-pro', 'deepseek/deepseek-v4-flash', 'deepseek/deepseek-chat-v3.1', 'deepseek/deepseek-v3.2-exp')
    'qwen-designer' = @('qwen/qwen3-coder-next', 'qwen/qwen3-coder', 'qwen/qwen3-coder-plus', 'qwen/qwen3-vl-8b-instruct', 'qwen/qwen3-32b')
    'qwen-github-manager' = @('qwen/qwen3-coder-next', 'qwen/qwen3-coder', 'qwen/qwen3-coder-plus')
    'kimi-auditor' = @('moonshotai/kimi-k2.5', 'moonshotai/kimi-k2', 'moonshotai/kimi-k2-thinking', 'moonshotai/kimi-k2-0905')
}

function Find-Model {
    param(
        [string[]]$Candidates,
        [string[]]$Available
    )
    foreach ($candidate in $Candidates) {
        if ($Available -contains $candidate) {
            return $candidate
        }
        $matches = $Available | Where-Object { $_ -like "$candidate*" }
        if ($matches.Count -gt 0) {
            $sorted = $matches | Sort-Object { $_.Length } -Descending
            return $sorted[0]
        }
    }
    return $null
}

$selectedModels = @{}
foreach ($slug in $agentCandidates.Keys) {
    $selectedModels[$slug] = Find-Model -Candidates $agentCandidates[$slug] -Available $availableIds
    if (-not $selectedModels[$slug]) {
        Write-Warning "No candidate model found for agent '$slug'. Tried: $($agentCandidates[$slug] -join ', ')"
    }
}

if ($Interactive -and $availableIds.Count -gt 0) {
    Write-Host ""
    Write-Host "Interactive mode: choose models by index or press Enter to keep defaults." -ForegroundColor Yellow
    for ($i = 0; $i -lt $availableIds.Count; $i++) {
        Write-Host "[$i] $($availableIds[$i])"
    }
    foreach ($slug in $agentCandidates.Keys) {
        $default = $selectedModels[$slug]
        if ($default) {
            Write-Host ""
            Write-Host "Current default for ${slug}: ${default}"
        } else {
            Write-Host ""
            Write-Host "No default candidate found for ${slug}. Choose from list or leave blank."
        }
        $choice = Read-Host "Enter index for $slug (or press Enter)"
        if ($choice -match '^[0-9]+$') {
            $idx = [int]$choice
            if ($idx -ge 0 -and $idx -lt $availableIds.Count) {
                $selectedModels[$slug] = $availableIds[$idx]
            } else {
                Write-Warning "Index $idx is out of range."
            }
        }
    }
}

Write-Host ""
Write-Host "Selected models:" -ForegroundColor Cyan
foreach ($slug in $selectedModels.Keys) {
    Write-Host "  $slug -> $($selectedModels[$slug])"
}

if (-not $UpdateRoomodes) {
    Write-Host ""
    Write-Host "Run the script with -UpdateRoomodes to apply these models into .roomodes." -ForegroundColor Green
    return
}

if (-not (Test-Path $roomodesPath)) {
    Write-Warning ".roomodes not found. A new file will be created."
    $roomodes = @{ modes = @() }
} else {
    try {
        $roomodes = Get-Content $roomodesPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Fail "Failed to read .roomodes: $($_.Exception.Message)"
    }
}

if (-not $roomodes.modes) {
    $roomodes.modes = @()
}

function Create-ModeBlock {
    param(
        [string]$Slug,
        [string]$Name,
        [string]$Role,
        [string]$Model
    )
    return [PSCustomObject]@{
        slug = $Slug
        name = $Name
        role = $Role
        model = $Model
        baseUrl = 'https://api.kodikrouter.ru/v1'
        apiKey = '${KODIKROUTER_API_KEY}'
        systemPrompt = "Auto-generated mode for agent $Name."
    }
}

$modeDefinitions = @{
    'orchestrator' = @{ name='Orchestrator'; role='coordinator' }
    'deepseek-architect' = @{ name='DeepSeek V4 Architect'; role='backend_architect' }
    'qwen-designer' = @{ name='Qwen UI/UX Designer'; role='frontend_designer' }
    'kimi-auditor' = @{ name='Kimi QA Auditor'; role='qa_engineer' }
    'qwen-github-manager' = @{ name='GitHub Manager'; role='devops' }
}

$updated = $false
foreach ($slug in $selectedModels.Keys) {
    $model = $selectedModels[$slug]
    if (-not $model) { continue }
    $mode = $roomodes.modes | Where-Object { $_.slug -eq $slug } | Select-Object -First 1
    if ($mode) {
        if ($mode.model -ne $model) {
            $mode.model = $model
            $updated = $true
            Write-Host "Updated mode '$slug' -> $model"
        } else {
            Write-Host "Mode '$slug' already uses $model" -ForegroundColor Gray
        }
    } else {
        if ($modeDefinitions.ContainsKey($slug)) {
            $def = $modeDefinitions[$slug]
            $newMode = Create-ModeBlock -Slug $slug -Name $def.name -Role $def.role -Model $model
            $roomodes.modes += $newMode
            $updated = $true
            Write-Host "Created new mode '$slug' -> $model"
        } else {
            Write-Warning "Unknown slug '$slug'. Skipping mode creation."
        }
    }
}

if ($updated) {
    try {
        $roomodes | ConvertTo-Json -Depth 10 | Set-Content $roomodesPath -Encoding UTF8
        Write-Host ""
        Write-Host ".roomodes updated successfully." -ForegroundColor Green
    } catch {
        Fail "Failed to save .roomodes: $($_.Exception.Message)"
    }
} else {
    Write-Host ""
    Write-Host ".roomodes did not require changes." -ForegroundColor Yellow
}
