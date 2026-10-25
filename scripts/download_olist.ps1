$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$dataDirectory = Join-Path $projectRoot "data\raw"
$requiredFiles = @(
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv"
)

if (Get-Command kaggle -ErrorAction SilentlyContinue) {
    $kaggleExecutable = (Get-Command kaggle).Source
} else {
    $userKaggleExecutable = Join-Path $env:APPDATA "Python\Python312\Scripts\kaggle.exe"
    if (Test-Path -LiteralPath $userKaggleExecutable -PathType Leaf) {
        $kaggleExecutable = $userKaggleExecutable
    } else {
        throw "Kaggle CLI not found. Install it with: py -3.12 -m pip install --user kaggle"
    }
}

New-Item -ItemType Directory -Force -Path $dataDirectory | Out-Null

& $kaggleExecutable datasets download olistbr/brazilian-ecommerce --path $dataDirectory --unzip --force
if ($LASTEXITCODE -ne 0) {
    throw "Kaggle download failed. If authentication is required, run 'kaggle auth login' and retry."
}

$missingFiles = @($requiredFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $dataDirectory $_) -PathType Leaf) })
if ($missingFiles.Count -gt 0) {
    throw "Dataset download is missing required file(s): $($missingFiles -join ', ')"
}

Write-Output "Olist dataset is ready in $dataDirectory"
