##Motivation

I had a task at hand to migrate all repositories from a particular team in bitbucket to Azure Repos. I knew about the UI based tool that is available to import repositories from AzureDevops but there is a limitation there. Only one repository could be moved at a time. And each time (manually) information has to be provided. If you are interested in knowing more about it please visit my article on that [here](http://skundunotes.com/2020/07/10/migrating-a-repository-from-bitbucket-to-azure-repos-using-powershell).

I had to move more than three dozen bitbuket repositories and that approach did not sound exciting and hence I automated the task.

##Prerequisites
<br />BitBucketUserName : your bitbucket user name
<br />BitBucketEmailAlias : email id associated with bitbucket
<br />BitBucketPassword : bitbucket password
<br />RootFolderForProjects : local folder path for migration work. Folder does not need to exist. Folder will be deleted after the script runs successfully.
<br />AzureDevopsPAT : AzureDevops team project PAT
<br />$AzureDevopsOrgURL : similar to https://dev.azure.com/MyOrganizationName/
<br />AzureDevopsTeamName : project team name in AzureDevops

##Usage
<br />-Open windows powershell as admin before you run the script
<br />-Copy/download powershell file and execute below command

.\MigrateToAzureRepos.ps1 -BitBucketUserName "$(YourBitBucketUserName)" -BitBucketEmailAlias "$(YourBitBucketEmailID)" -BitBucketPassword "$(YourBitBucketPassword)" -RootFolderForProjects "$(LocalMachineFolderPath)" -AzureDevopsPAT "$(AzureDevopsPAT)" -AzureDevopsOrgURL "$(AzureDevopsOrgURL)" -AzureDevopsTeamName "$(YourAzureDevopsTeamName)"

##Algorithm
<br />Create local folder for clone work
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
