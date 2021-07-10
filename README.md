[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/kunduso/MigrateToAzureRepos)
![Image](https://skdevops.files.wordpress.com/2020/07/21.-migratingfrombbtoar-image0-1.png)
## Motivation

I had a task at hand to migrate all repositories from a particular team in bitbucket to Azure Repos. I knew about the UI based tool that is available to import repositories from AzureDevops but there is a limitation there. Only one repository could be moved at a time. And each time (manually) information has to be provided. If you are interested in knowing more about it please visit my article on that [here](http://skundunotes.com/2020/07/10/migrating-a-repository-from-bitbucket-to-azure-repos-ui-based/).

I had to move more than three dozen bitbuket repositories and that approach did not sound exciting and hence I automated the task. Here is a link to my [note](http://skundunotes.com/2020/07/10/migrating-a-repository-from-bitbucket-to-azure-repos-using-powershell/)

## Prerequisites
### **Installations**
Install Azure CLI from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
<br />Install [Atlassian.Bitbucket Powershell module](https://www.powershellgallery.com/packages/Atlassian.Bitbucket/0.14.0) from Powershell Administrator console.
### **Input Parameters**
BitBucketUserName : your bitbucket user name
<br />BitBucketEmailAlias : email id associated with bitbucket
<br />BitBucketPassword : bitbucket password
<br />RootFolderForProjects : local folder path for migration work. Folder does not need to exist. Folder will be deleted after the script runs successfully.
<br />AzureDevopsPAT : AzureDevops team project PAT
<br />$AzureDevopsOrgURL : similar to https://dev.azure.com/MyOrganizationName/
<br />AzureDevopsTeamName : project team name in AzureDevops

## Usage
-Open windows powershell as admin before you run the script
<br />-Copy/download powershell file and execute below command

<pre><code>.\MigrateToAzureRepos.ps1 -BitBucketUserName "$(YourBitBucketUserName)" -BitBucketEmailAlias "$(YourBitBucketEmailID)" -BitBucketPassword "$(YourBitBucketPassword)" -RootFolderForProjects "$(LocalMachineFolderPath)" -AzureDevopsPAT "$(AzureDevopsPAT)" -AzureDevopsOrgURL "$(AzureDevopsOrgURL)" -AzureDevopsTeamName "$(YourAzureDevopsTeamName)"</code></pre>

## Algorithm
Create local folder for clone work
<br />Login to Bitbucket
<br />Get a list of bitbucket teams
<br />For each bitbucket team, get a list of projects associated with that team
<br />    -For each projects, get a list of repositories associated with that project
<br />        -For each repository,
<br />            -clone the repo to local
<br />            -check if a repository exists in Azure Repos, if not create one
<br />            -push code from local to repo in Azure Repos
<br />        continue until all repositories in particular project are migrated
<br />    continue until all projects in particular bitbucket team are migrated
<br />continue until all teams in particular bitbucket login are migrated
<br />Logout of bitbucket
<br />Delete local folder
<br />Delete AzureDevps PAT from environment
## Error
If you get an error like the one below, most probably the powershell module `Atlassian.Bitbucket` was not installed. Install that following the steps mentioned above.
```diff
-import-module : The specified module 'Atlassian.Bitbucket' was not loaded because no valid module file was found in any module directory.
-At C:\ed\MigrateToAzureRepos\MigrateToAzureRepos.ps1:14 char:1
-+ import-module Atlassian.Bitbucket
-+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-    + CategoryInfo          : ResourceUnavailable: (Atlassian.Bitbucket:String) [Import-Module], FileNotFoundException
-    + FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand
```
If you get this error even after installing the module, open a new Administrator Powershell and execute the powershell file `MigrateToAzureRepos.ps1` with appropriate parameters.
<br /> Apart from that if there are any issues with executing the powershell file, please let me know.

## Contribution/Feedback
Please submit a pull request with as much details as possible
