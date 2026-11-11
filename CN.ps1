# DevOpsLab.ps1
# Run from PowerShell:
# irm "https://raw.githubusercontent.com/USERNAME/REPOSITORY/main/DevOpsLab.ps1" | iex
# Jenkins installation is intentionally excluded. Jenkins must already be running locally.

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
<label>Name:</label> <input type="text" id="name" required><br><br>
<label>Email:</label> <input type="email" id="email" required><br><br>
<label>Phone:</label> <input type="tel" id="phone" required><br><br>
<label>College:</label> <input type="text" id="college" required><br><br>
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
git --version
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git init
git status
git add .
git commit -m "message"
git log
git branch
git clone URL
git remote -v
git push
git pull

Basic flow:
git init
git add .
git commit -m "First commit"
git branch -M main
git remote add origin REPOSITORY_URL
git push -u origin main

Use Git Credential Manager/browser sign-in. Do not put GitHub passwords in scripts.
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

    $jenkinsfile = @'
pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'GitHub source code downloaded'
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
                echo 'HTML file verified successfully!'
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
        success { echo 'CI/CD Completed Successfully!' }
        failure { echo 'CI/CD Failed!' }
    }
}
'@

    Set-Content (Join-Path $Root "01-registration-form\index.html") $html -Encoding UTF8
    Set-Content (Join-Path $Root "02-git-github\Git-GitHub-Commands.txt") $git -Encoding UTF8
    Set-Content (Join-Path $Root "03-github-scm\index.html") $html -Encoding UTF8
    Set-Content (Join-Path $Root "04-jenkins-setup\Jenkins-Setup.txt") @'
Jenkins installation is intentionally excluded from this lab script.
Jenkins must already be running and initially configured before Experiment 5.
Required plugins: Git plugin and Pipeline (workflow) plugin.
For automated CI/CD, choose option 2 in the main menu.
The script pushes the application and Jenkinsfile to GitHub, creates or updates the Pipeline job through the Jenkins API, triggers the build, and checks its result.
You will be prompted for the Jenkins URL, username, API token, GitHub repository URL, and branch.
The API token is entered as hidden input and is not written to disk.
Keep Jenkins local; do not expose it publicly.
'@ -Encoding UTF8
    Set-Content (Join-Path $Root "05-jenkins-cicd\Jenkinsfile") $jenkinsfile -Encoding UTF8
    Set-Content (Join-Path $Root "06-docker-commands\Docker-Commands.txt") $docker -Encoding UTF8
    Set-Content (Join-Path $Root "07-docker-application\index.html") $html -Encoding UTF8
    Set-Content (Join-Path $Root "07-docker-application\Dockerfile") $dockerfile -Encoding UTF8
    Set-Content (Join-Path $Root "08-kubernetes-integration\Kubernetes-Integration.txt") @'
EXPERIMENT 8 - DOCKER + KUBERNETES
1. Start Docker Desktop.
2. Settings > Kubernetes > Enable Kubernetes > Apply & Restart.
3. Wait until Kubernetes reports Running.
4. Run:
docker --version
kubectl version --client
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
docker images
The event-registration image is created in Experiment 7.
Experiment 9 will create the Kubernetes Deployment and Service.
'@ -Encoding UTF8
    Write-Host "Lab files created: $Root" -ForegroundColor Green
}

function Need-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Host "$Name is not installed or not in PATH." -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Run-GitJenkins {
    Make-Files
    if (-not (Need-Command "git")) { return }

    Write-Host "`nThis option pushes the app + Jenkinsfile to GitHub, creates/updates the Jenkins job, triggers it, and checks the result." -ForegroundColor Cyan
    $gitName = Read-Host "Git username"
    $gitEmail = Read-Host "Git email"
    $repoUrl = Read-Host "GitHub repository URL (HTTPS)"
    if (!$gitName -or !$gitEmail -or !$repoUrl) { Write-Host "Git username, email, and repo URL are required."; return }

    $jenkinsUrl = Read-Host "Jenkins URL (Enter for http://localhost:8080)"
    if (!$jenkinsUrl) { $jenkinsUrl = "http://localhost:8080" }
    $jenkinsUrl = $jenkinsUrl.TrimEnd("/")
    $jenkinsUser = Read-Host "Jenkins administrator username"
    $tokenSecure = Read-Host "Jenkins API token (hidden input)" -AsSecureString
    $jobName = Read-Host "Jenkins job name (Enter for Event-Registration-CI)"
    if (!$jobName) { $jobName = "Event-Registration-CI" }
    $branch = Read-Host "Git branch (Enter for main)"
    if (!$branch) { $branch = "main" }

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tokenSecure)
    try { $token = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }

    $basic = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${jenkinsUser}:$token"))
    $headers = @{ Authorization = "Basic $basic" }

    try {
        # Verify Jenkins URL and credentials before pushing anything.
        Invoke-RestMethod "$jenkinsUrl/api/json" -Headers $headers -Method Get | Out-Null
    } catch {
        $tokenSecure.Dispose()
        $token = $null; $basic = $null; $headers = $null
        Write-Host "Cannot authenticate to Jenkins. Check URL, service, username, and API token." -ForegroundColor Red
        return
    }

    $work = Join-Path $env:TEMP ("DevOpsLab_" + [guid]::NewGuid().ToString("N"))
    Write-Host "`nCloning GitHub repository..." -ForegroundColor Cyan
    git clone $repoUrl $work
    if ($LASTEXITCODE -ne 0) {
        $tokenSecure.Dispose()
        Write-Host "Git clone failed. Check URL, repository access, and GitHub authentication." -ForegroundColor Red
        return
    }

    try {
        Push-Location $work

        # Keep the local branch aligned with the requested remote branch.
        git fetch origin $branch 2>$null
        git show-ref --verify --quiet "refs/remotes/origin/$branch"
        if ($LASTEXITCODE -eq 0) { git checkout -B $branch "origin/$branch" }
        else { git checkout -B $branch }
        if ($LASTEXITCODE -ne 0) { throw "Could not prepare branch $branch." }

        git config user.name $gitName
        git config user.email $gitEmail
        Copy-Item (Join-Path $Root "03-github-scm\index.html") (Join-Path $work "index.html") -Force
        Copy-Item (Join-Path $Root "05-jenkins-cicd\Jenkinsfile") (Join-Path $work "Jenkinsfile") -Force

        git add index.html Jenkinsfile
        git diff --cached --quiet
        if ($LASTEXITCODE -eq 1) {
            git commit -m "Add event registration app and Jenkins pipeline"
            if ($LASTEXITCODE -ne 0) { throw "Git commit failed." }
        } else {
            Write-Host "No new source changes to commit." -ForegroundColor Yellow
        }

        git push -u origin $branch
        if ($LASTEXITCODE -ne 0) { throw "Git push failed. Check GitHub write permission/authentication." }
        Write-Host "App and Jenkinsfile pushed to GitHub." -ForegroundColor Green
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        return
    } finally {
        Pop-Location
    }

    # Jenkins Pipeline job configuration: SCM repository + Jenkinsfile from the selected branch.
    $safeRepo = [System.Security.SecurityElement]::Escape($repoUrl)
    $safeBranch = [System.Security.SecurityElement]::Escape("*/$branch")
    $xml = @"
<?xml version="1.0" encoding="UTF-8"?>
<flow-definition plugin="workflow-job">
  <description>Event Registration CI/CD - configured by DevOpsLab</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps">
    <scm class="hudson.plugins.git.GitSCM" plugin="git">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$safeRepo</url>
          <credentialsId></credentialsId>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches><hudson.plugins.git.BranchSpec><name>$safeBranch</name></hudson.plugins.git.BranchSpec></branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers>
    <hudson.triggers.SCMTrigger>
      <spec>H/2 * * * *</spec>
      <ignorePostCommitHooks>false</ignorePostCommitHooks>
    </hudson.triggers.SCMTrigger>
  </triggers>
  <disabled>false</disabled>
</flow-definition>
"@

    $apiHeaders = @{}
    foreach ($k in $headers.Keys) { $apiHeaders[$k] = $headers[$k] }
    try {
        # Jenkins CSRF crumb, if enabled.
        try {
            $crumb = Invoke-RestMethod "$jenkinsUrl/crumbIssuer/api/json" -Headers $headers -Method Get
            if ($crumb.crumbRequestField -and $crumb.crumb) { $apiHeaders[$crumb.crumbRequestField] = $crumb.crumb }
        } catch {}

        $jobPath = "$jenkinsUrl/job/$([Uri]::EscapeDataString($jobName))"
        $exists = $false
        try { Invoke-RestMethod "$jobPath/api/json" -Headers $headers | Out-Null; $exists = $true } catch {}

        if ($exists) {
            Invoke-WebRequest "$jobPath/config.xml" -Headers $apiHeaders -Method Post -ContentType "application/xml" -Body $xml | Out-Null
            Write-Host "Updated Jenkins job: $jobName" -ForegroundColor Green
        } else {
            Invoke-WebRequest "$jenkinsUrl/createItem?name=$([Uri]::EscapeDataString($jobName))" -Headers $apiHeaders -Method Post -ContentType "application/xml" -Body $xml | Out-Null
            Write-Host "Created Jenkins job: $jobName" -ForegroundColor Green
        }

        # Capture the queue URL so the script waits for this exact build, not an older build.
        $queued = Invoke-WebRequest "$jobPath/build" -Headers $apiHeaders -Method Post
        $queueUrl = [string]$queued.Headers["Location"]
        if ($queueUrl.StartsWith("/")) { $queueUrl = "$jenkinsUrl$queueUrl" }

        $buildNumber = $null
        if ($queueUrl) {
            for ($i = 0; $i -lt 60 -and -not $buildNumber; $i++) {
                Start-Sleep -Seconds 2
                try {
                    $q = Invoke-RestMethod "$($queueUrl.TrimEnd('/'))/api/json" -Headers $headers
                    if ($q.cancelled) { throw "Jenkins cancelled the queued build." }
                    if ($q.executable.number) { $buildNumber = [int]$q.executable.number }
                } catch {
                    if ($_.Exception.Message -like "*cancelled*") { throw }
                }
            }
        }

        if (-not $buildNumber) {
            $last = Invoke-RestMethod "$jobPath/api/json?tree=lastBuild[number]" -Headers $headers
            if ($last.lastBuild.number) { $buildNumber = [int]$last.lastBuild.number }
        }

        $build = $null
        if ($buildNumber) {
            for ($i = 0; $i -lt 100; $i++) {
                Start-Sleep -Seconds 3
                try {
                    $build = Invoke-RestMethod "$jobPath/$buildNumber/api/json" -Headers $headers
                    if ($build.building -eq $false -and $build.result) { break }
                } catch {}
            }
        }

        if ($build -and $build.result) {
            Write-Host "`nBuild #$($build.number): $($build.result)" -ForegroundColor Green
            Write-Host "Build URL: $($build.url)"
            if ($build.result -ne "SUCCESS") {
                Write-Host "Open the build URL and inspect Console Output." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Build was queued, but the result did not arrive before timeout. Open Jenkins to check it." -ForegroundColor Yellow
            Start-Process "$jobPath/"
        }
    } catch {
        Write-Host "Jenkins API error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Check that Git and Pipeline plugins are installed and this user can create, configure, and build jobs." -ForegroundColor Yellow
    } finally {
        $token = $null; $basic = $null; $headers = $null; $apiHeaders = $null
        $tokenSecure.Dispose()
    }
}

function Docker-Test {
    Make-Files
    if (-not (Need-Command "docker")) { return }
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
    if (-not (Need-Command "docker")) { return }
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Host "Start Docker Desktop first."; return }
    Push-Location (Join-Path $Root "07-docker-application")
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
    if (-not (Need-Command "docker") -or -not (Need-Command "kubectl")) { return }
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
    Write-Host "Experiment 8 checks completed. Kubernetes deployment is reserved for Experiment 9." -ForegroundColor Green
}

Make-Files
while ($true) {
    Write-Host "`n========== DEVOPS LAB (EXPERIMENTS 1-8) ==========" -ForegroundColor Cyan
    Write-Host "Folder: $Root"
    Write-Host "1. Create files and open Experiment 1"
    Write-Host "2. AUTOMATE GitHub push + Jenkins CI/CD (no Jenkins installation)"
    Write-Host "3. Open Jenkinsfile"
    Write-Host "4. Docker commands: run Nginx test"
    Write-Host "5. Build and run Docker application"
    Write-Host "6. Check Docker-Kubernetes integration"
    Write-Host "7. Open devopslab folder"
    Write-Host "8. Exit"
    $choice = Read-Host "Choose"
    try {
        switch ($choice) {
            "1" { Start-Process (Join-Path $Root "01-registration-form\index.html") }
            "2" { Run-GitJenkins }
            "3" { Start-Process notepad.exe -ArgumentList "`"$(Join-Path $Root '05-jenkins-cicd\Jenkinsfile')`"" }
            "4" { Docker-Test }
            "5" { Docker-App }
            "6" { Kubernetes-Check }
            "7" { Start-Process explorer.exe -ArgumentList "`"$Root`"" }
            "8" { break }
            default { Write-Host "Choose 1 to 8." -ForegroundColor Yellow }
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    if ($choice -eq "8") { break }
}
