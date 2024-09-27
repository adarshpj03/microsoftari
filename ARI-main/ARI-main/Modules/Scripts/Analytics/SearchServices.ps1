﻿<#
.Synopsis
Inventory for Azure Search Services

.DESCRIPTION
This script consolidates information for all microsoft.operationalinsights/workspaces and  resource provider in $Resources variable. 
Excel Sheet Name: SearchServices

.Link
https://github.com/microsoft/ARI/Modules/Analytics/SearchServices.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.2
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

    $Search = $Resources | Where-Object {$_.TYPE -eq 'microsoft.search/searchservices'}

    <######### Insert the resource Process here ########>

    if($Search)
        {
            $tmp = @()

            foreach ($1 in $Search) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ''
                $RetFeature = ''
                $pvt = if(![string]::IsNullOrEmpty($data.privateendpointconnections)){$data.privateendpointconnections}else{'0'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($pv in $pvt)
                        {
                            $priv = $pv.split('/')[8]
                            foreach ($Tag in $Tags) {
                                $obj = @{
                                    'ID'                                        = $1.id;
                                    'Subscription'                              = $sub1.Name;
                                    'Resource Group'                            = $1.RESOURCEGROUP;
                                    'Name'                                      = $1.NAME;
                                    'Status'                                    = $data.status;
                                    'Status Details'                            = $data.statusdetails;
                                    'SKU'                                       = $1.sku.name;
                                    'Public Network Access'                     = $data.publicnetworkaccess;
                                    'Disable Local Authentication'              = $data.disablelocalauth;
                                    'Hosting Mode'                              = $data.hostingmode;
                                    'Semantic Search'                           = $data.semanticsearch;
                                    'Encryption Compliance Status'              = $data.encryptionwithcmk.encryptioncompliancestatu;
                                    'Encryption Enforcement'                    = $data.encryptionwithcmk.enforcement;
                                    'Replica Count'                             = $data.replicacount;
                                    'Network Rule Set'                          = $data.networkruleset.bypass;
                                    'Private Endpoint'                          = $priv;
                                    'Resource U'                                = $ResUCount;
                                    'Tag Name'                                  = [string]$Tag.Name;
                                    'Tag Value'                                 = [string]$Tag.Value
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }
                        }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.SearchServices)
    {

        $TableName = ('SearchTable_'+($SmaResources.SearchServices.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText stopped -Range D:D
        $condtxt += New-ConditionalText enabled -Range G:G

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Status')
        $Exc.Add('Status Details')
        $Exc.Add('SKU')
        $Exc.Add('Public Network Access')
        $Exc.Add('Disable Local Authentication')
        $Exc.Add('Hosting Mode')
        $Exc.Add('Semantic Search')
        $Exc.Add('Encryption Compliance Status')
        $Exc.Add('Encryption Enforcement')
        $Exc.Add('Replica Count')
        $Exc.Add('Network Rule Set')
        $Exc.Add('Private Endpoint')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.SearchServices 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Search Services' -AutoSize -MaxAutoSizeRows 100 -ConditionalText $condtxt -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}