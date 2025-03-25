﻿# UTF-8 with BOMで保存
# 空フォルダチェックスクリプト（安定版）

# コンソール出力の色設定
$host.UI.RawUI.ForegroundColor = "White"
$progressColor = "Cyan"
$successColor = "Green"
$warningColor = "Yellow"
$errorColor = "Red"

# 出力ファイルパス
$outputFile = "C:\Users\syuuu\Downloads\WIP\処理1_展開する\空フォルダ判定リスト.txt"

# 移動先フォルダ
$tempStorage = "C:\Users\syuuu\Downloads\WIP\空フォルダ一時保管先"

# 処理対象ルートフォルダ（直下のみ）
$rootFolder = "C:\Users\syuuu\Downloads\WIP\処理1_展開する"

# 移動先フォルダの作成
if (-not (Test-Path $tempStorage)) {
    New-Item -Path $tempStorage -ItemType Directory -Force | Out-Null
    Write-Host "移動先フォルダを作成しました: $tempStorage"
}

# 処理開始時間記録
$startTime = Get-Date
$host.UI.RawUI.ForegroundColor = $progressColor
Write-Host "`n空フォルダチェックを開始します..."
Write-Host "開始時刻: $($startTime.ToString('yyyy/MM/dd HH:mm:ss'))"
Write-Host "対象フォルダ: $rootFolder (直下フォルダのみ)"
Write-Host "出力ファイル: $outputFile"
Write-Host "移動先フォルダ: $tempStorage`n"
$host.UI.RawUI.ForegroundColor = "White"

# 出力ファイルが存在しない場合は作成
if (-not (Test-Path $outputFile)) {
    New-Item -Path $outputFile -ItemType File -Force | Out-Null
    Write-Host "出力ファイルを作成しました"
}

# フォルダ状態をチェックする関数（前回の安定版を維持）
function Check-FolderStatus {
    param (
        [string]$folderPath
    )
    # ...（前回の安定版のCheck-FolderStatus関数をそのまま維持）...
}

# メイン処理（移動部分のみ簡素化）
if ($result.ShouldMove) {
    $destPath = Join-Path $tempStorage $folder.Name
    try {
        Move-Item -Path $folder.FullName -Destination $destPath -Force -ErrorAction Stop
        $movedCount++
        Write-Host "  → 移動完了: $destPath" -ForegroundColor $successColor
        $outputLine = "$($folder.Name) [移動済]`n  → 判定結果: $($result.Status) ($($result.Description))"
    }
    catch {
        Write-Host "  → 移動失敗: $_" -ForegroundColor $errorColor
        $outputLine = "$($folder.Name) [移動失敗]`n  → 判定結果: $($result.Status) ($($result.Description))"
    }
}