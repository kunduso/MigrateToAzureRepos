##Motivation

I had a task at hand to migrate all repositories from a particular team in bitbucket to Azure Repos. I knew about the UI based tool that is available to import repositories from AzureDevops but there is a limitation there. Only one repository could be moved at a time. And each time (manually) information has to be provided. If you are interested in knowing more about it please visit my article on that here.

I had to move more than three dozen bitbuket repositories and that approach did not sound exciting and hence I automated the task.

##Prerequisites
BitBucketUserName : your bitbucket user name
BitBucketEmailAlias : email id associated with bitbucket
BitBucketPassword : bitbucket password
RootFolderForProjects : local folder path for migration work. Folder does not need to exist. Folder will be deleted after the script runs successfully.
AzureDevopsPAT : AzureDevops team project PAT
$AzureDevopsOrgURL : similar to https://dev.azure.com/MyOrganizationName/
AzureDevopsTeamName : project team name in AzureDevops

##Usage
-Open windows powershell as admin before you run the script
-Copy/download powershell file and execute below command

.\MigrateToAzureRepos.ps1 -BitBucketUserName "$(YourBitBucketUserName)" -BitBucketEmailAlias "$(YourBitBucketEmailID)" -BitBucketPassword "$(YourBitBucketPassword)" -RootFolderForProjects "$(LocalMachineFolderPath)" -AzureDevopsPAT "$(AzureDevopsPAT)" -AzureDevopsOrgURL "$(AzureDevopsOrgURL)" -AzureDevopsTeamName "$(YourAzureDevopsTeamName)"

##Algorithm
Create local folder for clone work
Login to Bitbucket
Get a list of bitbucket teams
For each bitbucket team, get a list of projects associated with that team
    -For each projects, get a list of repositories associated with that project
        -For each repository,
            -clone the repo to local
            -check if a repository exists in Azure Repos, if not create one
            -push code from local to repo in Azure Repos
        continue until all repositories in particular project are migrated
    continue until all projects in particular bitbucket team are migrated
continue until all teams in particular bitbucket login are migrated
Logout of bitbucket
Delete local folder
Delete AzureDevps PAT from environment