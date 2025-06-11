# Get subscription
$SubscriptionName = "KLP LZ SRE playground Sandbox"
$subscription = Get-AzSubscription -SubscriptionName $SubscriptionName
Set-AzContext -SubscriptionId $subscription.Id | Out-Null


# Variable
if (!(Test-Path -Path "architectureDesign\PUML\$($subscription.Name)")) {

    New-Item -Path "$((Get-item -path "architectureDesign\PUML").FullName)" -Name "$($subscription.Name)" -ItemType "Directory" | Out-Null
}

$outputFile = "$((Get-item -Path ".\architectureDesign\PUML\$($subscription.Name)").FullName)\subscriptionAzureHierarchy.puml"
if (Test-Path -Path $outputFile) { Remove-Item -Path $outputFile -Force | Out-Null }


$resourceTypeIcons = Get-Content -Path ".\architectureDesign\resourceTypeIcons.json" | ConvertFrom-Json -asHashtable

# Start writing to the PlantUML file for C4-Container diagram
"@startuml" | Out-File -FilePath $outputFile -Encoding utf8
"!pragma revision 1" | Out-File -FilePath $outputFile -Append -Encoding utf8
"" | Out-File -FilePath $outputFile -Append -Encoding utf8
"!includeurl https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
"" | Out-File -FilePath $outputFile -Append -Encoding utf8
"!define AzurePuml https://raw.githubusercontent.com/plantuml-stdlib/Azure-PlantUML/master/dist" | Out-File -FilePath $outputFile -Append -Encoding utf8
"!includeurl AzurePuml/AzureCommon.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
"!includeurl AzurePuml/AzureC4Integration.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
"!includeurl AzurePuml/Management/AzureSubscription.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
"!includeurl AzurePuml/Management/AzureResourceGroups.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
"" | Out-File -FilePath $outputFile -Append -Encoding utf8


# Top Level - Azure Subscription
$subLabel = $subscription.Name
$subLabel_ = $subLabel.replace(" ", "_")
$subLabel_ = $subLabel_.replace("-", "_")
$subLevel = "AzureSubscription($subLabel_, '$subLabel', 'Azure Landing Zone')" 
$subLevel.replace("''", """") | Out-File -FilePath $outputFile -Append -Encoding utf8

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

foreach ($resourceGroup in $resourceGroups) {
    $rgLabel = $resourceGroup.ResourceGroupName
    $rgLabel_ = $rgLabel.replace("-", "_")
    $rgLabel_ = $rgLabel_.replace(" ", "_") 
    $rgLevel = "AzureResourceGroups($rgLabel_, '$rgLabel', 'Azure Resource Group')" 
    $rgLevel.replace("''", """") | Out-File -FilePath $outputFile -Append -Encoding utf8

    $rel = "Rel($subLabel_, $rgLabel_, 'Uses', 'Subscription' )"
    $rel.replace("''", """") | Out-File -FilePath $outputFile -Append -Encoding utf8
    "" | Out-File -FilePath $outputFile -Append -Encoding utf8

}

"LAYOUT_WITH_LEGEND()" | Out-File -FilePath $outputFile -Append -Encoding utf8
"@enduml" | Out-File -FilePath $outputFile -Append -Encoding utf8


if (!(Test-Path -Path "architectureDesign\PUML\$($subscription.Name)_ResourceGroups")) {

    New-Item -Path "$((Get-item -path "architectureDesign\PUML").FullName)" -Name "$($subscription.Name)_ResourceGroups" -ItemType Directory | Out-Null

}

$resourceGroupNames = (Get-AzResourceGroup).ResourceGroupName
foreach ($resourceGroupName in $resourceGroupNames) {
    
    $outputFile = "$((Get-item -Path ".\architectureDesign\PUML\$($subscription.Name)_ResourceGroups").FullName)\$($resourceGroupName)AzureHierarchy.puml"
    if (Test-Path -Path $outputFile) { Remove-Item -Path $outputFile -Force | Out-Null }

    "@startuml" | Out-File -FilePath $outputFile -Encoding utf8
    "!pragma revision 1" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "!includeurl https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "!define AzurePuml https://raw.githubusercontent.com/plantuml-stdlib/Azure-PlantUML/master/dist" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "!includeurl AzurePuml/AzureCommon.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "!includeurl AzurePuml/AzureC4Integration.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "!includeurl AzurePuml/Management/AzureResourceGroups.puml" | Out-File -FilePath $outputFile -Append -Encoding utf8
    "" | Out-File -FilePath $outputFile -Append -Encoding utf8

    $rgLabel = $resourceGroupName
    $rgLabel_ = $rgLabel.replace("-", "_")
    $rgLabel_ = $rgLabel_.replace(" ", "_") 
    $rgLevel = "AzureResourceGroups($rgLabel_, '$rgLabel', 'Azure Resource Group')" 
    $rgLevel.replace("''", """") | Out-File -FilePath $outputFile -Append -Encoding utf8
    "" | Out-File -FilePath $outputFile -Append -Encoding utf8

    $resources = Get-AzResource -ResourceGroupName $resourceGroupName
    foreach ($resource in $resources) {

        $resourceLabel = $resource.Name
        $resourceLabel_ = $resourceLabel.replace("-", "_")
        $resourceLabel_ = $resourceLabel_.replace(" ", "_")
        $resourceLabelType = $resource.ResourceType


        if ($resourceTypeIcons.ContainsKey($resourceLabelType)) {
            $getIcon = $resourceTypeIcons[$resourceLabelType]

            "!includeurl AzurePuml/$($getIcon.Values)" | Out-File -FilePath $outputFile -Append -Encoding utf8 -Force
            $resourceLevel = "$($getIcon.Keys)($resourceLabel_, '$resourceLabel', '$resourceLabelType')"
            $resourceLevel.replace("''", """") | Out-File -FilePath $outputFile -Append -Encoding utf8 -Force


            $rel = "Rel($rgLabel_, $resourceLabel_, 'Uses', 'Resource' )"
            $rel.replace("''", """") | Out-File -FilePath $outputFile -Append -Encoding utf8 -Force
            "" | Out-File -FilePath $outputFile -Append -Encoding utf8 -Force
        }

    
        if (!(Test-Path -Path "architectureDesign\PUML\$($resourceGroupName)_Resources")) {
    
            New-Item -Path "$((Get-item -path "architectureDesign\PUML").FullName)" -Name "$($resourceGroupName)_Resources" -ItemType Directory | Out-Null
        
        }

        if (!(Test-Path -Path "architectureDesign\PUML\$($resourceGroupName)_Resources\resourcesJson")) {
    
            New-Item -Path "$((Get-item -path "architectureDesign\PUML\$($resourceGroupName)_Resources").FullName)" -Name "resourcesJson" -ItemType Directory | Out-Null
        
        }
        
        if ($resourceLabel -like "*/*") {
            $splitResourceLabel = $resourceLabel -split "/"
            $query = @"
resources
| where name == "$($splitResourceLabel[1])"
| project properties
"@
  
            $azureResourceGraph = Search-AzGraph -Query $query -Subscription $subscription.Id
            $removeArray = $azureResourceGraph.properties
            $propertiesJson = $azureResourceGraph.properties | ConvertTo-Json -Depth 30

            if ($removeArray -is [System.Array]) {
                $jsonObject = @{}
                $removeArray | ForEach-Object {
                    for ($i = 0; $i -lt $removeArray.Count; $i++) {
                        $jsonObject[[string]$i] = $_
                    }
                }
                $propertiesJson = $jsonObject | ConvertTo-Json -Depth 30
            } 
    
            $resourceOutputFile = "$((Get-item -Path ".\architectureDesign\PUML\$($resourceGroupName)_Resources\resourcesJson").FullName)\$($splitResourceLabel[1]).json"
            if (Test-Path -Path $resourceOutputFile) { Remove-Item -Path $resourceOutputFile -Force | Out-Null }
            $propertiesJson | Out-File -FilePath $resourceOutputFile -Append -Encoding utf8

            $resourceOutputFolder = "$((Get-item -Path ".\architectureDesign\PUML\$($resourceGroupName)_Resources").FullName)\$($splitResourceLabel[1]).puml"
            if (Test-Path -Path $resourceOutputFolder) { Remove-Item -Path $resourceOutputFolder -Force | Out-Null }

            "@startuml" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "title Resources Display - Component Diagram" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "component Component {" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "json  Resource_Properties $propertiesJson" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "}" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "@enduml" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8


        }
        else {
            $query = @"
resources
| where name == "$($resourceLabel)"
| project properties
"@
    
            $azureResourceGraph = Search-AzGraph -Query $query -Subscription $subscription.Id
            $removeArray = $azureResourceGraph.properties
            $propertiesJson = $azureResourceGraph.properties | ConvertTo-Json -Depth 30

            if ($removeArray -is [System.Array]) {
                $jsonObject = @{}
                $removeArray | ForEach-Object {
                    for ($i = 0; $i -lt $removeArray.Count; $i++) {
                        $jsonObject[[string]$i] = $_
                    }
                }
                $propertiesJson = $jsonObject | ConvertTo-Json -Depth 30
            } 
    
            $resourceOutputFile = "$((Get-item -Path ".\architectureDesign\PUML\$($resourceGroupName)_Resources\resourcesJson").FullName)\$($resourceLabel_).json"
            if (Test-Path -Path $resourceOutputFile) { Remove-Item -Path $resourceOutputFile -Force | Out-Null }
            $propertiesJson | Out-File -FilePath $resourceOutputFile -Append -Encoding utf8

            $resourceOutputFolder = "$((Get-item -Path ".\architectureDesign\PUML\$($resourceGroupName)_Resources").FullName)\$($resourceLabel_).puml"
            if (Test-Path -Path $resourceOutputFolder) { Remove-Item -Path $resourceOutputFolder -Force | Out-Null }

            "@startuml" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "title Resources Display - Component Diagram" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "component Component {" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "json  Resource_Properties $propertiesJson" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "}" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
            "@enduml" | Out-File -Path $resourceOutputFolder -Append -Encoding utf8
        }

        
    }

    "LAYOUT_WITH_LEGEND()" | Out-File -FilePath $outputFile -Append -Encoding utf8 -Force
    "@enduml" | Out-File -FilePath $outputFile -Append -Encoding utf8 -Force
}

Write-Host "Azure-PlantUML is completed for AzureHierarchy.puml"