# DevOpsLab.ps1
# Run: irm "https://raw.githubusercontent.com/USERNAME/REPO/main/DevOpsLab.ps1" | iex
$ErrorActionPreference = "Stop"
$Root = Join-Path ([Environment]::GetFolderPath("Desktop")) "devopslab"

function Make-Files {
    $dirs = @("01-registration-form","02-git-github","03-github-scm","04-jenkins-setup","05-jenkins-cicd","06-docker-commands","07-docker-application","08-kubernetes-integration")
    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    foreach ($d in $dirs) { New-Item -ItemType Directory -Path (Join-Path $Root $d) -Force | Out-Null }

    $html = @'
<!DOCTYPE html>
<html>
<head><title>Event Registration</title></head>
<body>
<h2>Event Registration Form</h2>
<form onsubmit="register(event)">
<label>Name:</label> <input id="name" required><br><br>
<label>Email:</label> <input type="email" id="email" required><br><br>
<label>Phone:</label> <input type="tel" id="phone" required><br><br>
<label>College:</label> <input id="college" required><br><br>
<label>Event:</label>
<select id="event"><option>Web Development</option><option>AI Workshop</option><option>Hackathon</option></select><br><br>
<button type="submit">Register</button>
</form>
<p id="message"></p>
<script>
function register(e) {
 e.preventDefault();
 document.getElementById("message").innerHTML =
 "Registration Successful! Welcome " + document.getElementById("name").value;
}
</script>
</body>
</html>
'@
    $git = @'
GIT AND GITHUB COMMANDS
git --version                 Check Git version
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git init                      Initialize repository
git status                    Check status
git add .                     Stage files
git commit -m "message"       Commit changes
git log                       View history
git branch                    List branches
git clone URL                 Clone repository
git remote -v                 View remote
git push                      Push commits
git pull                      Pull changes

Basic flow:
git init
git add .
git commit -m "First commit"
git branch -M main
git remote add origin REPOSITORY_URL
git push -u origin main

Use Git Credential Manager/browser authentication. Never paste your GitHub password into this script.
'@
    $docker = @'
DOCKER COMMANDS
docker --version
docker info
docker images
docker pull nginx
docker ps
docker ps -a
docker run hello-world
docker run -d -p 8082:80 --name mynginx nginx
docker stop mynginx
docker start mynginx
docker restart mynginx
docker logs mynginx
docker exec -it mynginx sh
docker rm -f mynginx
docker rmi nginx
docker volume ls
docker system prune  (removes unused data; use carefully)

Open http://localhost:8082 for the Nginx test.
'@
    $dockerfile = @'
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
'@
    $jenkins = @'
pipeline {
    agent any
    triggers { pollSCM('H/2 * * * *') }
    options { skipDefaultCheckout(true) }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'GitHub source downloaded'
            }
        }
        stage('Build') {
            steps {
                bat 'echo Building Event Registration App'
                bat 'dir'
            }
        }
        stage('Test') {
            steps {
                bat 'if not exist index.html exit /b 1'
                echo 'HTML file verified'
            }
        }
        stage('Deploy') {
            steps {
                bat 'if not exist deployment mkdir deployment'
                bat 'copy /Y index.html deployment\\'
                archiveArtifacts artifacts: 'deployment/**', fingerprint: true
            }
        }
    }
    post {
        success { echo 'CI/CD completed successfully' }
        failure { echo 'CI/CD failed' }
    }
}
'@
    Set-Content "$Root\01-registration-form\index.html" $html -Encoding UTF8
    Set-Content "$Root\02-git-github\Git-GitHub-Commands.txt" $git -Encoding UTF8
    Set-Content "$Root\03-github-scm\index.html" $html -Encoding UTF8
    Set-Content "$Root\04-jenkins-setup\Jenkins-Setup.txt" @'
Jenkins local URL: http://localhost:8080
Install Jenkins LTS and a compatible Java JDK.
Run Jenkins as a Windows service.
After service starts, open:
C:\Program Files\Jenkins\secrets\initialAdminPassword
Complete Unlock Jenkins, suggested plugins, and admin user setup manually.
Keep this lab instance local; do not expose it publicly.
'@ -Encoding UTF8
    Set-Content "$Root\05-jenkins-cicd\Jenkinsfile" $jenkins -Encoding UTF8
    Set-Content "$Root\06-docker-commands\Docker-Commands.txt" $docker -Encoding UTF8
    Set-Content "$Root\07-docker-application\index.html" $html -Encoding UTF8
    Set-Content "$Root\07-docker-application\Dockerfile" $dockerfile -Encoding UTF8
    Set-Content "$Root\08-kubernetes-integration\Kubernetes-Integration.txt" @'
EXPERIMENT 8 - DOCKER + KUBERNETES
1. Start Docker Desktop.
2. Settings > Kubernetes > Enable Kubernetes > Apply & Restart.
3. Wait until Kubernetes is running.
4. Run:
docker --version
kubectl version --client
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
docker images
The event-registration image is built in Experiment 7.
Experiment 9 will create the Kubernetes Deployment and Service.
'@ -Encoding UTF8
    Write-Host "Files created: $Root" -ForegroundColor Green
}

function Need-Command($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        Write-Host "$name is not installed or not in PATH." -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Git-Push {
    Make-Files
    if (-not (Need-Command git)) { return }
    $name = Read-Host "Git username"
    $email = Read-Host "Git email"
    $url = Read-Host "GitHub repository URL"
    if (!$name -or !$email -or !$url) { Write-Host "All three values are required."; return }
    $dir = "$Root\03-github-scm"
    Push-Location $dir
    try {
        git config user.name $name
        git config user.email $email
        if (!(Test-Path ".git")) { git init }
        git branch -M main
        if ((git remote) -contains "origin") { git remote set-url origin $url } else { git remote add origin $url }
        git add .
        git commit -m "Add event registration app"
        if ($LASTEXITCODE -ne 0) { Write-Host "No new commit was created; continuing to push." -ForegroundColor Yellow }
        git push -u origin main
    } finally { Pop-Location }
}

function Install-Jenkins {
    if (-not (Need-Command winget)) { return }
    if (-not (Get-Service Jenkins -ErrorAction SilentlyContinue)) {
        if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
            winget install --id EclipseAdoptium.Temurin.21.JDK -e --accept-package-agreements --accept-source-agreements
        }
        winget install --id Jenkins.Jenkins -e --accept-package-agreements --accept-source-agreements
    }
    $svc = Get-Service Jenkins -ErrorAction SilentlyContinue
    if ($svc) {
        if ($svc.Status -ne "Running") { Start-Service Jenkins }
        Start-Sleep 5
        $pwdFile = "C:\Program Files\Jenkins\secrets\initialAdminPassword"
        if (Test-Path $pwdFile) {
            notepad $pwdFile
            Start-Process "http://localhost:8080"
        } else { Write-Host "Jenkins is installed, but password file was not found at $pwdFile" -ForegroundColor Yellow }
    } else {
        Write-Host "Jenkins service not detected. Check winget output or install Jenkins LTS manually." -ForegroundColor Yellow
    }
}

function Jenkins-Pipeline {
    Make-Files
    Write-Host "Jenkinsfile created at $Root\05-jenkins-cicd\Jenkinsfile"
    Write-Host "Copy it to the root of your GitHub repo and push it."
    Write-Host "Jenkins: New Item > Pipeline > Pipeline script from SCM > Git."
    Write-Host "Enter repo URL, branch */main, Script Path Jenkinsfile, then Build Now."
    Start-Process "$Root\05-jenkins-cicd"
}

function Docker-Test {
    Make-Files
    if (-not (Need-Command docker)) { return }
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Host "Start Docker Desktop first."; return }
    docker pull nginx
    if ($LASTEXITCODE -ne 0) { return }
    if ((docker ps -a --filter "name=^mynginx$" --format "{{.Names}}") -contains "mynginx") { docker rm -f mynginx | Out-Null }
    docker run -d -p 8082:80 --name mynginx nginx
    if ($LASTEXITCODE -eq 0) { Start-Process "http://localhost:8082" }
}

function Docker-App {
    Make-Files
    if (-not (Need-Command docker)) { return }
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Host "Start Docker Desktop first."; return }
    Push-Location "$Root\07-docker-application"
    try {
        docker build -t event-registration:latest .
        if ($LASTEXITCODE -ne 0) { return }
        if ((docker ps -a --filter "name=^event-app$" --format "{{.Names}}") -contains "event-app") { docker rm -f event-app | Out-Null }
        docker run -d -p 8081:80 --name event-app event-registration:latest
        if ($LASTEXITCODE -eq 0) { Start-Process "http://localhost:8081" }
    } finally { Pop-Location }
}

function Kubernetes-Check {
    Make-Files
    if (-not (Need-Command docker) -or -not (Need-Command kubectl)) { return }
    docker --version
    kubectl version --client
    kubectl cluster-info
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Enable Kubernetes in Docker Desktop: Settings > Kubernetes > Enable Kubernetes > Apply & Restart." -ForegroundColor Yellow
        return
    }
    kubectl get nodes
    kubectl get namespaces
    docker images
    Write-Host "Experiment 8 checks complete. Kubernetes deployment is reserved for Experiment 9." -ForegroundColor Green
}

Make-Files
while ($true) {
    Write-Host "`n========= DEVOPS LAB (1-8) =========" -ForegroundColor Cyan
    Write-Host "Folder: $Root"
    Write-Host "1. Create files and open Experiment 1"
    Write-Host "2. GitHub source control: configure and push"
    Write-Host "3. Install/start Jenkins and open setup"
    Write-Host "4. Prepare Jenkins CI/CD pipeline"
    Write-Host "5. Docker commands: run Nginx test"
    Write-Host "6. Build and run Docker application"
    Write-Host "7. Check Docker-Kubernetes integration"
    Write-Host "8. Open devopslab folder"
    Write-Host "9. Exit"
    $choice = Read-Host "Choose"
    try {
        switch ($choice) {
            "1" { Start-Process "$Root\01-registration-form\index.html" }
            "2" { Git-Push }
            "3" { Install-Jenkins }
            "4" { Jenkins-Pipeline }
            "5" { Docker-Test }
            "6" { Docker-App }
            "7" { Kubernetes-Check }
            "8" { Start-Process explorer.exe -ArgumentList "`"$Root`"" }
            "9" { break }
            default { Write-Host "Choose 1 to 9." -ForegroundColor Yellow }
        }
    } catch { Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red }
    if ($choice -eq "9") { break }
}
