﻿# UTF-8 with BOMで保存
# 空フォルダ判定スクリプト

# 定数定義
$TARGET_DIR = "C:\Users\syuuu\Downloads\WIP\処理1_展開する"
$OUTPUT_FILE = "$TARGET_DIR\空フォルダ判定リスト.txt"

# フォルダサイズ計算関数
function Get-FolderSize {
    param (
        [string]$folderPath
    )
    
    if (-not (Test-Path -LiteralPath $folderPath)) {
        Write-Host "フォルダが見つかりません: $folderPath"
        return $null
    }

    $fileItems = Get-ChildItem -LiteralPath $folderPath -Recurse -File -ErrorAction SilentlyContinue
    if ($fileItems) {
        return ($fileItems | Measure-Object -Property Length -Sum).Sum
    }
    return 0
}

# 判定条件1: フォルダサイズがゼロであり、なおかつ空のフォルダである
function Test-Condition1 {
    param (
        [string]$folderPath,
        [long]$folderSize
    )
    
    if ($folderSize -ne 0) { return $false }
    
    $items = Get-ChildItem -LiteralPath $folderPath -Recurse -ErrorAction SilentlyContinue
    return ($items.Count -eq 0)
}

# 判定条件2: フォルダサイズがゼロであり、なおかつ直下にあるサブフォルダのサイズもすべてゼロである
function Test-Condition2 {
    param (
        [string]$folderPath,
        [long]$folderSize
    )
    
    if ($folderSize -ne 0) { return $false }
    
    $subFolders = Get-ChildItem -LiteralPath $folderPath -Directory -ErrorAction SilentlyContinue
    if ($subFolders.Count -eq 0) { return $false }
    
    foreach ($subFolder in $subFolders) {
        $subFolderSize = Get-FolderSize $subFolder.FullName
        if ($subFolderSize -ne 0) { return $false }
    }
    return $true
}

# 判定条件3: 圧縮ファイルとサブフォルダの両方があり、両者の名称が同一である
function Test-Condition3 {
    param (
        [string]$folderPath
    )
    
    $files = Get-ChildItem -LiteralPath $folderPath -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(zip|rar|7z)$' }
    $folders = Get-ChildItem -LiteralPath $folderPath -Directory -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0 -or $folders.Count -eq 0) { return $false }
    
    foreach ($file in $files) {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        foreach ($folder in $folders) {
            if ($folder.Name -eq $fileName) {
                return $true
            }
        }
    }
    return $false
}

# 判定条件4: 圧縮ファイルとサブフォルダの両方があり、両者の名称は異なる
function Test-Condition4 {
    param (
        [string]$folderPath
    )
    
    $files = Get-ChildItem -LiteralPath $folderPath -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(zip|rar|7z)$' }
    $folders = Get-ChildItem -LiteralPath $folderPath -Directory -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0 -or $folders.Count -eq 0) { return $false }
    
    foreach ($file in $files) {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        foreach ($folder in $folders) {
            if ($folder.Name -ne $fileName) {
                return $true
            }
        }
    }
    return $false
}

# 判定条件5: 圧縮ファイルがあり、なおかつサブフォルダがない
function Test-Condition5 {
    param (
        [string]$folderPath
    )
    
    $files = Get-ChildItem -LiteralPath $folderPath -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(zip|rar|7z)$' }
    $folders = Get-ChildItem -LiteralPath $folderPath -Directory -ErrorAction SilentlyContinue
    
    return ($files.Count -gt 0 -and $folders.Count -eq 0)
}

# 判定条件6: サブフォルダがあり、そのサイズがゼロではない
function Test-Condition6 {
    param (
        [string]$folderPath,
        [long]$folderSize
    )
    
    $subFolders = Get-ChildItem -LiteralPath $folderPath -Directory -ErrorAction SilentlyContinue
    if ($subFolders.Count -eq 0) { return $false }
    
    return ($folderSize -gt 0)
}

# 判定条件7: 上記以外の全て
function Test-Condition7 {
    param (
        [string]$folderPath,
        [long]$folderSize
    )
    
    return $true
}

# メイン処理
function Main {
    try {
        # 出力ファイル準備
        if (-not (Test-Path -LiteralPath $TARGET_DIR)) {
            throw "対象ディレクトリが存在しません: $TARGET_DIR"
        }

        # 対象フォルダ一覧取得
        $folders = Get-ChildItem -LiteralPath $TARGET_DIR -Directory
        
        # 進捗表示用
        $total = $folders.Count
        $current = 0
        
        foreach ($folder in $folders) {
            $current++
            $folderPath = $folder.FullName
            $folderName = $folder.Name
            
            Write-Host "[$current/$total] 処理中: $folderPath"
            
            # フォルダサイズ取得
            $folderSize = Get-FolderSize $folderPath
            if ($null -eq $folderSize) {
                Write-Host "  → エラー: フォルダサイズ取得失敗"
                continue
            }
            
            # 各条件判定
            if (Test-Condition1 $folderPath $folderSize) {
                $result = "サイズ0、本体空"
                
                # 空フォルダを移動
                $tempDir = "C:\Users\syuuu\Downloads\WIP\空フォルダ一時保管先"
                if (-not (Test-Path -LiteralPath $tempDir)) {
                    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
                }
                
                $destPath = Join-Path -Path $tempDir -ChildPath $folderName
                if (-not (Test-Path -LiteralPath $destPath)) {
                    Move-Item -LiteralPath $folderPath -Destination $destPath -Force
                    $result += " → 移動済み"
                } else {
                    $result += " → 移動先に同名フォルダ存在"
                }
            }
            elseif (Test-Condition2 $folderPath $folderSize) {
                $subFolderCount = (Get-ChildItem -LiteralPath $folderPath -Directory).Count
                $result = "サイズ0、空サブフォルダ${subFolderCount}つ"
            }
            elseif (Test-Condition3 $folderPath) {
                $result = "同名の圧縮ファイルとサブフォルダが存在"
            }
            elseif (Test-Condition4 $folderPath) {
                $result = "異名の圧縮ファイルとサブフォルダが存在"
            }
            elseif (Test-Condition5 $folderPath) {
                $result = "圧縮ファイルのみ存在"
            }
            elseif (Test-Condition6 $folderPath $folderSize) {
                $result = "サブフォルダあり (サイズ: $($folderSize / 1MB) MB)"
            }
            else {
                $result = "その他の条件 (サイズ: $($folderSize / 1MB) MB)"
            }

            Write-Host "  → 判定結果: $result"
            Add-Content -LiteralPath $OUTPUT_FILE "[$current/$total] $folderName`r`n  → 判定結果: $result"
        }
    }
    catch {
        Write-Host "エラーが発生しました: $_"
        exit 1
    }
}

# スクリプト実行
Main

# ウィンドウを開いたままにする
Read-Host "処理が完了しました。Enterキーを押して終了します"