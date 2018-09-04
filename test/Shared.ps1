$ModuleManifestName  = 'Plaster.psd1'
$ModuleManifestPath  = "$PSScriptRoot\..\src\$ModuleManifestName"
$TemplateDir         = "$PSScriptRoot\TemplateRootTemp"
$OutDir = "$PSScriptRoot\Out"


if (!$SuppressImportModule) {
    $OmnicitModule = Import-Module $ModuleManifestPath -Scope Global -PassThru
}