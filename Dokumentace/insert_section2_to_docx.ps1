param(
    [string]$SourceDocx = "Data\Pdf_sema\docx\MongoDB-Denys-Tkach.docx",
    [string]$Markdown = "Dokumentace\architektura-prepis.md",
    [string]$OutputDocx = "Data\Pdf_sema\docx\MongoDB-Denys-Tkach-draft.docx"
)

$ErrorActionPreference = "Stop"

function Get-TrimmedParagraphText {
    param($Paragraph)
    return (($Paragraph.Range.Text -replace "[`r`a]", "")).Trim()
}

function Get-StyleConstant {
    param([string]$Name)
    switch ($Name) {
        "Heading1" { return -2 }
        "Heading2" { return -3 }
        "Heading3" { return -4 }
        "Heading4" { return -5 }
        default { return -1 }
    }
}

function Add-Paragraph {
    param(
        $Document,
        [ref]$Position,
        [string]$Text,
        [string]$Style = "Normal",
        [switch]$Code
    )

    if ($null -eq $Text) {
        $Text = ""
    }

    $start = $Position.Value
    $range = $Document.Range($start, $start)
    $range.InsertAfter($Text + "`r")

    $inserted = $Document.Range($start, $start + $Text.Length)
    $inserted.Style = Get-StyleConstant $Style

    if ($Code) {
        $inserted.Font.Name = "Consolas"
        $inserted.Font.Size = 9
    }

    $Position.Value = $start + $Text.Length + 1
}

function Add-Table {
    param(
        $Document,
        [ref]$Position,
        [object[]]$Rows
    )

    if ($Rows.Count -lt 1) {
        return
    }

    $columnCount = ($Rows[0]).Count
    if ($columnCount -lt 1) {
        return
    }

    $range = $Document.Range($Position.Value, $Position.Value)
    $table = $Document.Tables.Add($range, $Rows.Count, $columnCount)

    for ($r = 0; $r -lt $Rows.Count; $r++) {
        for ($c = 0; $c -lt $columnCount; $c++) {
            $table.Cell($r + 1, $c + 1).Range.Text = [string]$Rows[$r][$c]
        }
    }

    try {
        $table.Style = "Table Grid"
    }
    catch {
        # Style name can be localized. The default table formatting is acceptable.
    }

    $table.Rows.Item(1).Range.Bold = $true
    $table.Range.Font.Size = 9
    $table.Range.ParagraphFormat.SpaceAfter = 3
    $table.AutoFitBehavior(1)

    $table.Range.InsertParagraphAfter()
    $Position.Value = $table.Range.End + 1
}

function Parse-MarkdownTable {
    param([string[]]$Lines)

    $rows = @()
    foreach ($line in $Lines) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?$') {
            continue
        }

        $clean = $trimmed.Trim("|")
        $cells = $clean -split "\|" | ForEach-Object { $_.Trim().Trim([char]96) }
        $rows += ,@($cells)
    }

    return $rows
}

function Insert-MarkdownSection {
    param(
        $Document,
        [ref]$Position,
        [string[]]$Lines
    )

    $i = 0
    while ($i -lt $Lines.Count) {
        $line = $Lines[$i]
        $trimmed = $line.Trim()

        if ($trimmed.Length -eq 0) {
            $i++
            continue
        }

        if ($trimmed.StartsWith('```')) {
            $i++
            $codeLines = @()
            while ($i -lt $Lines.Count -and -not $Lines[$i].Trim().StartsWith('```')) {
                $codeLines += $Lines[$i]
                $i++
            }
            if ($i -lt $Lines.Count) {
                $i++
            }
            Add-Paragraph -Document $Document -Position $Position -Text ($codeLines -join "`r") -Style "Normal" -Code
            continue
        }

        if ($trimmed.StartsWith("|") -and ($i + 1) -lt $Lines.Count -and $Lines[$i + 1].Trim().StartsWith("|")) {
            $tableLines = @()
            while ($i -lt $Lines.Count -and $Lines[$i].Trim().StartsWith("|")) {
                $tableLines += $Lines[$i]
                $i++
            }
            $rows = Parse-MarkdownTable -Lines $tableLines
            Add-Table -Document $Document -Position $Position -Rows $rows
            continue
        }

        if ($trimmed -match '^####\s+(.+)$') {
            $heading = ($Matches[1] -replace '^\d+(\.\d+)*\s+', '')
            Add-Paragraph -Document $Document -Position $Position -Text $heading -Style "Heading3"
            $i++
            continue
        }

        if ($trimmed -match '^###\s+(.+)$') {
            $heading = ($Matches[1] -replace '^\d+(\.\d+)*\s+', '')
            $style = if ($heading -match 'docker-compose') { "Heading3" } else { "Heading2" }
            Add-Paragraph -Document $Document -Position $Position -Text $heading -Style $style
            $i++
            continue
        }

        if ($trimmed -match '^##\s+(.+)$') {
            $heading = ($Matches[1] -replace '^\d+(\.\d+)*\s+', '')
            Add-Paragraph -Document $Document -Position $Position -Text $heading -Style "Heading1"
            $i++
            continue
        }

        $paragraphLines = @($trimmed)
        $i++
        while (
            $i -lt $Lines.Count -and
            $Lines[$i].Trim().Length -gt 0 -and
            -not $Lines[$i].Trim().StartsWith("#") -and
            -not $Lines[$i].Trim().StartsWith("|") -and
            -not $Lines[$i].Trim().StartsWith('```')
        ) {
            $paragraphLines += $Lines[$i].Trim()
            $i++
        }

        Add-Paragraph -Document $Document -Position $Position -Text ($paragraphLines -join " ") -Style "Normal"
    }
}

$sourcePath = (Resolve-Path -LiteralPath $SourceDocx).Path
$markdownPath = (Resolve-Path -LiteralPath $Markdown).Path
$outputPath = Join-Path (Get-Location) $OutputDocx

Copy-Item -LiteralPath $sourcePath -Destination $outputPath -Force

$allLines = Get-Content -LiteralPath $markdownPath -Encoding UTF8
$startLine = -1
for ($i = 0; $i -lt $allLines.Count; $i++) {
    if ($allLines[$i].StartsWith("## 2 Funk")) {
        $startLine = $i
        break
    }
}

if ($startLine -lt 0) {
    throw "Section 2 was not found in markdown file."
}

$sectionLines = $allLines[$startLine..($allLines.Count - 1)]

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $null

try {
    $doc = $word.Documents.Open($outputPath)

    $sectionStart = $null
    $sectionEnd = $null

    for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
        $text = Get-TrimmedParagraphText -Paragraph $doc.Paragraphs.Item($i)
        if ($null -eq $sectionStart -and $text -eq "Funkční řešení" -and $i -gt 40) {
            $sectionStart = $doc.Paragraphs.Item($i).Range.Start
            continue
        }

        if ($null -ne $sectionStart -and $text -eq "Případy užití a případové studie") {
            $sectionEnd = $doc.Paragraphs.Item($i).Range.Start
            break
        }
    }

    if ($null -eq $sectionStart -or $null -eq $sectionEnd) {
        throw "Could not locate section 2 boundaries in the Word document."
    }

    $replaceRange = $doc.Range($sectionStart, $sectionEnd)
    $replaceRange.Delete()

    $position = [ref]$sectionStart
    Insert-MarkdownSection -Document $doc -Position $position -Lines $sectionLines

    $doc.Save()
}
finally {
    if ($null -ne $doc) {
        $doc.Close($false)
    }
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}

Write-Host "Created: $outputPath"
