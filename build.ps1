# Tum src/ modullerini tek dosyaya birlestirir -> dist/Orbit.lua
$root = $PSScriptRoot
$src = Join-Path $root "src"
$out = Join-Path $root "dist\Orbit.lua"
New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("-- Orbit UI (bundle) - build.ps1 tarafindan uretildi, elle duzenleme")
[void]$sb.AppendLine("local __modules = {}")

Get-ChildItem $src -Recurse -Filter *.lua | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($src.Length + 1)
    $name = ($rel -replace '\.lua$', '') -replace '[\\/]', '.'
    $code = [IO.File]::ReadAllText($_.FullName).TrimStart([char]0xFEFF)
    [void]$sb.AppendLine("__modules[`"$name`"] = function(...)")
    [void]$sb.AppendLine($code)
    [void]$sb.AppendLine("end")
}

[void]$sb.AppendLine(@'
local __cache = {}
local function import(name)
    if __cache[name] ~= nil then return __cache[name] end
    local fn = assert(__modules[name], "[Orbit] modul yok: " .. tostring(name))
    local result = fn(import)
    __cache[name] = result
    return result
end
return import("init")
'@)

[IO.File]::WriteAllText($out, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Olusturuldu: $out"
