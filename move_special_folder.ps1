param (
    [string]$folderPath = "C:\Users\syuuu\Downloads\WIP\処理1_展開する\[250308][hoge同好会] テスト用のダミーゲーム Ver1.02 [d_484036]"
)

function Move-SpecialFolder {
    param (
        [string]$folderPath
    )

    if (-not (Test-Path $folderPath)) {
        Write-Host "指定されたフォルダが存在しません: $folderPath"
        return $false
    }

    $tempDir = "C:\Users\syuuu\Downloads\WIP\空フォルダ一時保管先"

    # 移動先フォルダが存在しない場合は作成
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }

    try {
        $folderName = Split-Path $folderPath -Leaf
        $targetFolderName = "[250308][hoge同好会] テスト用のダミーゲーム Ver1.02 [d_484036]"

        Write-Host ("比較対象: '{0}' vs '{1}'" -f $folderName, $targetFolderName)

        # フォルダ名が一致するか確認
        if ($folderName -ne $targetFolderName) {
            Write-Host "対象外フォルダのためスキップ: '$folderName'"
            return $false
        }

        Write-Host "対象フォルダを検出: '$folderName'"

        $destPath = Join-Path $tempDir $folderName

        # 既に移動先に同名フォルダが存在する場合はスキップ
        if (Test-Path $destPath) {
            Write-Host "移動先に既に同名フォルダが存在します: $destPath"
            return $false
        }

        # フォルダを移動
        Move-Item -Path $folderPath -Destination $destPath -Force
        Write-Host "フォルダを移動しました: $folderPath → $destPath"
        return $true
    }
    catch {
        Write-Host "フォルダ移動中にエラーが発生しました: $($_.Exception.Message)"
        return $false
    }
}

# メイン処理
try {
    $result = Move-SpecialFolder -folderPath $folderPath
    if (-not $result) {
        Write-Host "処理が失敗しました。"
        exit 1
    }
}
catch {
    Write-Host "エラーが発生しました: $_"
    exit 1
}

# ウィンドウを開いたままにする
Write-Host "`n=== スクリプト実行結果 ==="
if ($result) {
    Write-Host "処理が正常に完了しました"
} else {
    Write-Host "処理が失敗しました"
}
Write-Host "`nEnterキーを押して終了します..."
Read-Host
