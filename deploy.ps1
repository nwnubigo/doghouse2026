# 남원누비고 상세페이지 자동 배포 스크립트
# 사용법:  powershell -ExecutionPolicy Bypass -File deploy.ps1 "커밋 메시지"
param([string]$msg = "상세페이지 업데이트")
$ErrorActionPreference = "Stop"
$Repo  = "C:\Users\NWUBIGO\OneDrive\문서\GitHub\doghouse2026"
$Stage = "C:\Users\NWUBIGO\Downloads\_dh_deploy"

Write-Host "[1/5] 원격 변경사항 가져오는 중..." -ForegroundColor Cyan
Set-Location $Repo
git pull --no-rebase --no-edit origin main | Out-Null

Write-Host "[2/5] 새 파일 복사 중..." -ForegroundColor Cyan
$files = Get-ChildItem $Stage -File -ErrorAction SilentlyContinue
if (-not $files) { Write-Host "  복사할 파일이 없습니다. 종료합니다." -ForegroundColor Yellow; exit 0 }
foreach ($f in $files) {
  if ($f.Extension -in ".jpg",".jpeg",".png",".gif",".webp",".svg") {
    Copy-Item $f.FullName (Join-Path $Repo "images") -Force
    Write-Host "  images\$($f.Name)"
  } else {
    Copy-Item $f.FullName $Repo -Force
    Write-Host "  $($f.Name)"
  }
}

Write-Host "[3/5] 변경사항 확인 중..." -ForegroundColor Cyan
git add -A
$changed = git status --porcelain
if (-not $changed) { Write-Host "  변경된 내용이 없습니다. 종료합니다." -ForegroundColor Yellow; exit 0 }

Write-Host "[4/5] 커밋 중..." -ForegroundColor Cyan
git commit -q -m $msg

Write-Host "[5/5] GitHub에 업로드 중..." -ForegroundColor Cyan
git push origin main
Write-Host ""
Write-Host "완료! 1~2분 뒤 사이트에 반영됩니다." -ForegroundColor Green
Write-Host "  https://nwnubigo.github.io/doghouse2026/" -ForegroundColor Green
Move-Item "$Stage\*" "$Stage\_배포완료" -Force -ErrorAction SilentlyContinue
