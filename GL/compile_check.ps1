$csc = New-Object Microsoft.CSharp.CSharpCodeProvider
$cp = New-Object System.CodeDom.Compiler.CompilerParameters
$cp.ReferencedAssemblies.Add("System.Data.dll")
$cp.ReferencedAssemblies.Add("System.Data.Linq.dll")
$cp.ReferencedAssemblies.Add("System.Web.dll")
$cp.ReferencedAssemblies.Add((Resolve-Path "bin/System.Web.Extensions.dll").Path)
$cp.GenerateInMemory = $true
$cp.OutputAssembly = "C:\Users\Ali\gir_compile.dll"
$src = Get-Content "Modules\Inventory\GoodsIssuanceRequestView.aspx.cs" -Raw
$results = $csc.CompileAssemblyFromSource($cp, $src)
if ($results.Errors.Count -gt 0) {
    $results.Errors | ForEach-Object { $_.ErrorText }
} else {
    Write-Host "OK"
}
