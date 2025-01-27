# Ghaf-releases-storage Highlights
* This is Az public storage where we deploy our new release images and contents
* We are using Azure storage as public storage
* We are using Azure web service to host contents
* Microsoft Defender for security  
* To manage backup, we are using Azure Backup Vault 
* Azure Cloud based IDE

# How to deploy 
- Clone the project:
  ```bash
  $ git clone git@github.com:tiiuae/ghaf-release-storage.git
- Move to source folder
  ```bash
  $ cd ghaf-release-storage
  ```
- Login to azure via CLI and If you dont have Azure CLI Please install:
  ```bash
  https://search.nixos.org/packages?channel=24.05&show=azure-cli&from=0&size=1&sort=relevance&type=packages&query=azure-cli

- Downlaods Artifacts to codebase run
```bash
$ downloads-artifacts.sh
```
- For example by running below command it will download carbon x1 to ghaf-release-artifacts folder
```bash
$ ./downloads-artifacts.sh -u https://ghaf-jenkins-controller-prod.northeurope.cloudapp.azure.com/artifacts/ghaf-release-pipeline/build_7-commit_4ca7b66461f1bf4f423a3c0a8743a38736a56dcd/packages.x86_64-linux.lenovo-x1-carbon-gen11-debug/

```
- Move the artifacts to the ghaf-releases-artifacts folder root and verify
```bash
$ cd ghaf-releases-artifact ls
```
- Run prod deployment script:
```bash
$ bash ./prod_deployment_script.sh
```
- cmd prompt will ask please enter the new Release tag name (e.g., ghaf-24-09-8):
- Make sure follow the pattern otherwise deployment will fails
- After entering the release tag name then script search the release tag already exist if not it will say Release tag name does not exist. Are you sure you want to continue with this release tag? (yes/no). if exist cmd will say exist give another release tag!
- continuing with the release Yes
- Then script will read the ghaf-releases-artifacts and start upload files one by one
- Script will automatically create new folder in the codebase and uploads to azure server with the release tag we enters 
- Script will automatically create in the codebase uploads to azure server dummy index.html, signature-verification-of-binary-image.html and signature-verification-of-provenance-file.html
- If everything succesfully uploads you should see "Resources added successfully"


# Go to the ghafreleasesstorage Storage  

- Open IDE make codes changes based on new Releases needs
