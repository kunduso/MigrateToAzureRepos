param (  
    [Parameter(Mandatory=$true)][string]$BitBucketUserName,
    [Parameter(Mandatory=$true)][string]$BitBucketEmailAlias,
    [Parameter(Mandatory=$true)][string]$BitBucketPassword,
    [Parameter(Mandatory=$true)][string]$RootFolderForProjects,
    [Parameter(Mandatory=$true)][string]$AzureDevopsPAT,
    [Parameter(Mandatory=$true)][string]$AzureDevopsOrgURL,
    [Parameter(Mandatory=$true)][string]$AzureDevopsTeamName
    )
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
# https://www.powershellgallery.com/packages/Atlassian.Bitbucket/0.24.0
import-module Atlassian.Bitbucket

# $RootFolderForProjects is where code from bitbucket repos gets cloned to
#Region CreateRootFolder
if (Test-Path "$RootFolderForProjects")
{	
    "Folder exists and will be deleted."
    Remove-Item -path $RootFolderForProjects -force -Recurse
}
    "Creating folder`n"
    New-Item -ItemType directory -path $RootFolderForProjects
#endregion

#Region SetVariables
$ScriptPath = $PSScriptRoot
$count = 1
$BitbucketCloneUrl = "https://"+$BitBucketUserName+"@bitbucket.org/"
#endregion

function CreateBitBucketLogin {
    $password = ConvertTo-SecureString $BitBucketPassword -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($BitBucketEmailAlias, $password)
    try {
        New-BitbucketLogin -Credential $credential
    }
    catch {
        
        "An error occurred: " +$_
        $_.ScriptStackTrace
        #Remove-BitbucketLogin
        exit 1
    }
}
function CloneReposFromBitBucket ($ParentFolder, $GitCloneURL, $LocalProjectPath)
{
    Set-Location -Path "$ParentFolder" -PassThru
    "Value of Clone URL: "+ $GitCloneURL
    cmd /c "git clone --mirror $GitCloneURL"
    "`nProject cloned at "+$ParentFolder
}
function PushCodeFromLocalToEmptyAzureRepo ($ParentFolder, $LocalProjectPath) 
{
    "Parent Folder: "+$ParentFolder
    "LocalProjectPath: "+$LocalProjectPath
    Set-Location ("$ParentFolder" + "\$LocalProjectPath"+".git\")
    $AzureDevopsRepoURL = $AzureDevopsOrgURL+"/"+$AzureDevopsTeamName+"/_git/"+$LocalProjectPath
    "AzureRepoURL: "+$AzureDevopsRepoURL
    cmd /c "git remote set-url --push origin $AzureDevopsRepoURL"
    "`ngit remote set-url done`n"
    cmd /c "git push --mirror"
    "`ngit push done`n"
}
function CreateEmptyAzureRepo ($RepoName)
{   
    $CreateRepoFlag = "True"
    #https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7
     $ListofAzureRepos = cmd /c "az repos list --org $AzureDevopsOrgURL -p $AzureDevopsTeamName" | ConvertFrom-Json
    foreach ($AzureRepos in $ListofAzureRepos)
    {
        if ($AzureRepos.name -eq $RepoName)
        {
            "`nRepository already exists`n"
            $CreateRepoFlag = "False"
        }
    }
    if ($CreateRepoFlag -eq "True")
    {
        "`nCreating a repo in AzureDevops with name: "+$RepoName
        cmd /c "az repos create --name "$RepoName" --org "$AzureDevopsOrgURL" -p $AzureDevopsTeamName"
    }
}

###################################################
#
# Eecution begins here
#
###################################################

"`nCreating bitbucket login`n"
CreateBitBucketLogin
"`n"

$ListofBitbucketTeams = Get-BitbucketTeam
foreach ($BitBucketTeam in $ListofBitbucketTeams)
{
    "Bitbucket team name: "+$BitbucketTeam.display_name
    "****************************************`n"
    $ListofBitbucketProject = Get-BitbucketProject | Where-Object {$_.owner.display_name -eq $BitbucketTeam.display_name}
    foreach ($BitbucketProject in $ListofBitbucketProject) 
    {
        "Bitbucket project name: "+$BitbucketProject.name+"`n"
        $ListOfProjectRepos = Get-BitbucketRepository | Where-Object {$_.project.name -eq $BitbucketProject.name}
        foreach ($ProjectRepos in $ListOfProjectRepos)
        { 
            "`nProject number: "+$count
            "Repository name: "+$ProjectRepos.slug
            $ProjectRepos.project.name
            $ProjectRepos.full_name
            $count=$count+1

            #Region Migration
            $ProjectCloneURL = $BitbucketCloneUrl+$ProjectRepos.full_name+".git"
            . CloneReposFromBitBucket ($RootFolderForProjects) ($ProjectCloneURL) ($ProjectRepos.slug)
            . CreateEmptyAzureRepo ($ProjectRepos.slug)
            . PushCodeFromLocalToEmptyAzureRepo ($RootFolderForProjects) ($ProjectRepos.slug)
            #endregion
        }
        "----------------------------------------`n"
    }
}

#Region Cleanup
Remove-BitbucketLogin 
Set-Location -Path "$ScriptPath" -PassThru
if (Test-Path "$RootFolderForProjects")
{	
    "Folder "+$RootFolderForProjects+" will be deleted."
    Remove-Item -path $RootFolderForProjects -force -Recurse
}
try {
    $env:AZURE_DEVOPS_EXT_PAT = 'settingthistosomethingthatisincorrectsothatitcantbeused'
    Remove-Item -Path Env:AZURE_DEVOPS_EXT_PAT
}
catch {
    "An error occurred: " +$_
    $_.ScriptStackTrace
    exit 1
}
#endregion