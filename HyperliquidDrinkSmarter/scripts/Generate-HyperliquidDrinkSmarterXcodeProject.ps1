# Regenerates HyperliquidDrinkSmarter.xcodeproj/project.pbxproj
$root = Split-Path $PSScriptRoot -Parent
$srcRoot = Join-Path $root "HyperliquidDrinkSmarter"
$pbxPath = Join-Path $root "HyperliquidDrinkSmarter.xcodeproj\project.pbxproj"
$schemePath = Join-Path $root "HyperliquidDrinkSmarter.xcodeproj\xcshareddata\xcschemes\HyperliquidDrinkSmarter.xcscheme"

function New-Uuid { [guid]::NewGuid().ToString("N").Substring(0, 24).ToUpper() }

$swiftFiles = Get-ChildItem -Path $srcRoot -Recurse -Filter "*.swift" | ForEach-Object {
    $rel = $_.FullName.Substring($srcRoot.Length + 1).Replace("\", "/")
    [PSCustomObject]@{ Path = $rel; Id = New-Uuid; BuildId = New-Uuid }
}

$fontFiles = Get-ChildItem -Path (Join-Path $srcRoot "Resources/Fonts") -Recurse -Filter "*.ttf" | ForEach-Object {
    $rel = $_.FullName.Substring($srcRoot.Length + 1).Replace("\", "/")
    [PSCustomObject]@{ Path = $rel; Id = New-Uuid; BuildId = New-Uuid }
}

$assetId = New-Uuid
$assetBuildId = New-Uuid
$plistId = New-Uuid
$privacyId = New-Uuid
$privacyBuildId = New-Uuid
$releaseCfgId = New-Uuid
$targetId = "B612A66D38A74EFEA8816BBB"
$projectId = New-Uuid
$mainGroupId = New-Uuid
$productsGroupId = New-Uuid
$sourcesPhaseId = New-Uuid
$resourcesPhaseId = New-Uuid
$frameworksPhaseId = New-Uuid
$productRefId = New-Uuid
$configListProjId = New-Uuid
$configListTargetId = New-Uuid
$debugProjId = New-Uuid
$releaseProjId = New-Uuid
$debugTargetId = New-Uuid
$releaseTargetId = New-Uuid
$localGroupId = New-Uuid

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("// `$*UTF8*`$!")
[void]$sb.AppendLine("{")
[void]$sb.AppendLine("	archiveVersion = 1;")
[void]$sb.AppendLine("	classes = {")
[void]$sb.AppendLine("	};")
[void]$sb.AppendLine("	objectVersion = 56;")
[void]$sb.AppendLine("	objects = {")

foreach ($f in $swiftFiles) {
    [void]$sb.AppendLine("		$($f.BuildId) /* $($f.Path) in Sources */ = {isa = PBXBuildFile; fileRef = $($f.Id) /* $($f.Path) */; };")
}
foreach ($f in $fontFiles) {
    [void]$sb.AppendLine("		$($f.BuildId) /* $($f.Path) in Resources */ = {isa = PBXBuildFile; fileRef = $($f.Id) /* $($f.Path) */; };")
}
[void]$sb.AppendLine("		$assetBuildId /* Resources/Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = $assetId /* Resources/Assets.xcassets */; };")
[void]$sb.AppendLine("		$privacyBuildId /* SupportingFiles/PrivacyInfo.xcprivacy in Resources */ = {isa = PBXBuildFile; fileRef = $privacyId /* SupportingFiles/PrivacyInfo.xcprivacy */; };")

[void]$sb.AppendLine("		$productRefId /* HyperliquidDrinkSmarter.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = HyperliquidDrinkSmarter.app; sourceTree = BUILT_PRODUCTS_DIR; };")
foreach ($f in $swiftFiles) {
    [void]$sb.AppendLine("		$($f.Id) /* $($f.Path) */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = `"$($f.Path)`"; sourceTree = `"<group>`"; };")
}
foreach ($f in $fontFiles) {
    [void]$sb.AppendLine("		$($f.Id) /* $($f.Path) */ = {isa = PBXFileReference; lastKnownFileType = file; path = `"$($f.Path)`"; sourceTree = `"<group>`"; };")
}
[void]$sb.AppendLine("		$assetId /* Resources/Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Resources/Assets.xcassets; sourceTree = `"<group>`"; };")
[void]$sb.AppendLine("		$plistId /* SupportingFiles/Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = SupportingFiles/Info.plist; sourceTree = `"<group>`"; };")
[void]$sb.AppendLine("		$privacyId /* SupportingFiles/PrivacyInfo.xcprivacy */ = {isa = PBXFileReference; lastKnownFileType = text.xml; path = SupportingFiles/PrivacyInfo.xcprivacy; sourceTree = `"<group>`"; };")
[void]$sb.AppendLine("		$releaseCfgId /* SupportingFiles/Release.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = SupportingFiles/Release.xcconfig; sourceTree = `"<group>`"; };")

[void]$sb.AppendLine("		$mainGroupId = {")
[void]$sb.AppendLine("			isa = PBXGroup;")
[void]$sb.AppendLine("			children = (")
[void]$sb.AppendLine("				$localGroupId /* HyperliquidDrinkSmarter */,")
[void]$sb.AppendLine("				$productsGroupId /* Products */,")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			sourceTree = `"<group>`";")
[void]$sb.AppendLine("		};")
[void]$sb.AppendLine("		$productsGroupId = {")
[void]$sb.AppendLine("			isa = PBXGroup;")
[void]$sb.AppendLine("			children = (")
[void]$sb.AppendLine("				$productRefId /* HyperliquidDrinkSmarter.app */,")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			name = Products;")
[void]$sb.AppendLine("			sourceTree = `"<group>`";")
[void]$sb.AppendLine("		};")

$children = @($assetId, $plistId, $privacyId, $releaseCfgId) + $swiftFiles.Id + $fontFiles.Id
[void]$sb.AppendLine("		$localGroupId = {")
[void]$sb.AppendLine("			isa = PBXGroup;")
[void]$sb.AppendLine("			children = (")
foreach ($cid in $children) { [void]$sb.AppendLine("				$cid,") }
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			path = HyperliquidDrinkSmarter;")
[void]$sb.AppendLine("			sourceTree = `"<group>`";")
[void]$sb.AppendLine("		};")

[void]$sb.AppendLine("		$frameworksPhaseId = {")
[void]$sb.AppendLine("			isa = PBXFrameworksBuildPhase;")
[void]$sb.AppendLine("			buildActionMask = 2147483647;")
[void]$sb.AppendLine("			files = (")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			runOnlyForDeploymentPostprocessing = 0;")
[void]$sb.AppendLine("		};")

[void]$sb.AppendLine("		$sourcesPhaseId = {")
[void]$sb.AppendLine("			isa = PBXSourcesBuildPhase;")
[void]$sb.AppendLine("			buildActionMask = 2147483647;")
[void]$sb.AppendLine("			files = (")
foreach ($f in $swiftFiles) { [void]$sb.AppendLine("				$($f.BuildId) /* $($f.Path) in Sources */,") }
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			runOnlyForDeploymentPostprocessing = 0;")
[void]$sb.AppendLine("		};")

[void]$sb.AppendLine("		$resourcesPhaseId = {")
[void]$sb.AppendLine("			isa = PBXResourcesBuildPhase;")
[void]$sb.AppendLine("			buildActionMask = 2147483647;")
[void]$sb.AppendLine("			files = (")
[void]$sb.AppendLine("				$assetBuildId /* Resources/Assets.xcassets in Resources */,")
[void]$sb.AppendLine("				$privacyBuildId /* SupportingFiles/PrivacyInfo.xcprivacy in Resources */,")
foreach ($f in $fontFiles) { [void]$sb.AppendLine("				$($f.BuildId) /* $($f.Path) in Resources */,") }
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			runOnlyForDeploymentPostprocessing = 0;")
[void]$sb.AppendLine("		};")

[void]$sb.AppendLine("		$targetId = {")
[void]$sb.AppendLine("			isa = PBXNativeTarget;")
[void]$sb.AppendLine("			buildConfigurationList = $configListTargetId;")
[void]$sb.AppendLine("			buildPhases = (")
[void]$sb.AppendLine("				$sourcesPhaseId,")
[void]$sb.AppendLine("				$frameworksPhaseId,")
[void]$sb.AppendLine("				$resourcesPhaseId,")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			buildRules = (")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			dependencies = (")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			name = HyperliquidDrinkSmarter;")
[void]$sb.AppendLine("			productName = HyperliquidDrinkSmarter;")
[void]$sb.AppendLine("			productReference = $productRefId;")
[void]$sb.AppendLine("			productType = `"com.apple.product-type.application`";")
[void]$sb.AppendLine("		};")

[void]$sb.AppendLine("		$projectId = {")
[void]$sb.AppendLine("			isa = PBXProject;")
[void]$sb.AppendLine("			attributes = {")
[void]$sb.AppendLine("				BuildIndependentTargetsInParallel = 1;")
[void]$sb.AppendLine("				LastSwiftUpdateCheck = 1500;")
[void]$sb.AppendLine("				LastUpgradeCheck = 1500;")
[void]$sb.AppendLine("			};")
[void]$sb.AppendLine("			buildConfigurationList = $configListProjId;")
[void]$sb.AppendLine("			compatibilityVersion = `"Xcode 14.0`";")
[void]$sb.AppendLine("			developmentRegion = en;")
[void]$sb.AppendLine("			hasScannedForEncodings = 0;")
[void]$sb.AppendLine("			knownRegions = (")
[void]$sb.AppendLine("				en,")
[void]$sb.AppendLine("				Base,")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("			mainGroup = $mainGroupId;")
[void]$sb.AppendLine("			productRefGroup = $productsGroupId;")
[void]$sb.AppendLine("			projectDirPath = `"`";")
[void]$sb.AppendLine("			projectRoot = `"`";")
[void]$sb.AppendLine("			targets = (")
[void]$sb.AppendLine("				$targetId,")
[void]$sb.AppendLine("			);")
[void]$sb.AppendLine("		};")

function Write-ProjConfig($id, $name) {
    [void]$sb.AppendLine("		$id = {")
    [void]$sb.AppendLine("			isa = XCBuildConfiguration;")
    [void]$sb.AppendLine("			buildSettings = {")
    [void]$sb.AppendLine("				ALWAYS_SEARCH_USER_PATHS = NO;")
    [void]$sb.AppendLine("				CLANG_ENABLE_MODULES = YES;")
    [void]$sb.AppendLine("				SWIFT_VERSION = 5.0;")
    if ($name -eq "Debug") { [void]$sb.AppendLine("				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;") }
    [void]$sb.AppendLine("			};")
    [void]$sb.AppendLine("			name = $name;")
    [void]$sb.AppendLine("		};")
}

function Write-TargetConfig($id, $name) {
    [void]$sb.AppendLine("		$id = {")
    [void]$sb.AppendLine("			isa = XCBuildConfiguration;")
    if ($name -eq "Release") {
        [void]$sb.AppendLine("			baseConfigurationReference = $releaseCfgId /* SupportingFiles/Release.xcconfig */;")
    }
    [void]$sb.AppendLine("			buildSettings = {")
    [void]$sb.AppendLine("				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;")
    [void]$sb.AppendLine("				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;")
    [void]$sb.AppendLine("				CODE_SIGN_STYLE = Automatic;")
    [void]$sb.AppendLine("				CURRENT_PROJECT_VERSION = 1;")
    [void]$sb.AppendLine("				ENABLE_PREVIEWS = YES;")
    [void]$sb.AppendLine("				GENERATE_INFOPLIST_FILE = NO;")
    [void]$sb.AppendLine("				INFOPLIST_FILE = HyperliquidDrinkSmarter/SupportingFiles/Info.plist;")
    [void]$sb.AppendLine("				IPHONEOS_DEPLOYMENT_TARGET = 17.0;")
    [void]$sb.AppendLine('				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks");')
    [void]$sb.AppendLine("				MARKETING_VERSION = 1.0.0;")
    [void]$sb.AppendLine("				PRIVACY_MANIFEST_PATH = HyperliquidDrinkSmarter/SupportingFiles/PrivacyInfo.xcprivacy;")
    [void]$sb.AppendLine("				PRODUCT_BUNDLE_IDENTIFIER = com.hyperliquiddrinksmarter.app;")
    [void]$sb.AppendLine('				PRODUCT_NAME = "$(TARGET_NAME)";')
    [void]$sb.AppendLine("				SUPPORTED_PLATFORMS = `"iphoneos iphonesimulator`";")
    [void]$sb.AppendLine("				SWIFT_EMIT_LOC_STRINGS = YES;")
    [void]$sb.AppendLine("				SWIFT_VERSION = 5.0;")
    [void]$sb.AppendLine("				TARGETED_DEVICE_FAMILY = `"1,2`";")
    if ($name -eq "Debug") { [void]$sb.AppendLine("				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;") }
    if ($name -eq "Release") { [void]$sb.AppendLine("				DEBUG_INFORMATION_FORMAT = `"dwarf-with-dsym`";") }
    [void]$sb.AppendLine("			};")
    [void]$sb.AppendLine("			name = $name;")
    [void]$sb.AppendLine("		};")
}

Write-ProjConfig $debugProjId "Debug"
Write-ProjConfig $releaseProjId "Release"
Write-TargetConfig $debugTargetId "Debug"
Write-TargetConfig $releaseTargetId "Release"

[void]$sb.AppendLine("		$configListProjId = {")
[void]$sb.AppendLine("			isa = XCConfigurationList;")
[void]$sb.AppendLine("			buildConfigurations = ($debugProjId, $releaseProjId);")
[void]$sb.AppendLine("			defaultConfigurationIsVisible = 0;")
[void]$sb.AppendLine("			defaultConfigurationName = Release;")
[void]$sb.AppendLine("		};")
[void]$sb.AppendLine("		$configListTargetId = {")
[void]$sb.AppendLine("			isa = XCConfigurationList;")
[void]$sb.AppendLine("			buildConfigurations = ($debugTargetId, $releaseTargetId);")
[void]$sb.AppendLine("			defaultConfigurationIsVisible = 0;")
[void]$sb.AppendLine("			defaultConfigurationName = Release;")
[void]$sb.AppendLine("		};")

[void]$sb.AppendLine("	};")
[void]$sb.AppendLine("	rootObject = $projectId;")
[void]$sb.AppendLine("}")

$content = $sb.ToString().Replace("`r`n", "`n")
[System.IO.File]::WriteAllText($pbxPath, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Generated $pbxPath"
Write-Host "Swift: $($swiftFiles.Count) | Fonts: $($fontFiles.Count) | Target: $targetId"
