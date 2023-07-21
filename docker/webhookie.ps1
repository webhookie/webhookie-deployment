param (
  $version = "latest", 
  $size = "small", 
  $branding, 
  $brandingColor, 
  $dryRun = "false", 
  $command = "up",
  $arm = "false",
  $authProvider = "keycloak",
  $withLogging = "false",
  $withMonitoring = "false",
  $noMongo = "false",
  $withSample = "false",
  $noRabbit = "false",
  $noPortal = "false",
  $noRegistry = "false"
)

$default_size="medium"
$keycloak_image="quay.io/keycloak/keycloak:14.0.0"
$help="false"
$branding_path="./data/branding"
$branding_color=""

$sizes = @(
  "small", 
  "medium", 
  "large", 
  "x-large"
)

$modules = [System.Collections.ArrayList](
  "mongo",
  "rabbit",
  "registry",
  "services",
  "gateway",
  "portal",
  "nginx"
)

if ($arm -eq 'true' ) {
  $keycloak_image="wizzn/keycloak:14"
}

if ( $size -eq "" ) {
  $size = $default_size
}

if ($withLogging -eq "true") {
  $modules.Add("logging")
}
if ($withMonitoring -eq "true") {
  $modules.Add("monitoring")
}
if ($noMongo -eq "true") {
  $modules.Remove("mongo")
}
if ($withSample -eq "true") {
  $modules.Add("sample")
}
if ($noRabbit -eq "true") {
  $modules.Remove("rabbit")
}
if ($noPortal -eq "true") {
  $modules.Remove("portal")
}
if ($noRegistry -eq "true") {
  $modules.Remove("registry")
}


function run {
  $envFile = ".env"
  if (Test-Path $envFile) {
    Remove-Item $envFile -Force
  }

  $ctnt = "./res/env.res.$size"

  $elk = Get-Content -Path ./elk.env
  Add-Content -Path ./.env -Value $elk 
  $sizeContent = Get-Content -Path $ctnt
  Add-Content -Path ./.env -Value $sizeContent 
  Add-Content -Path ./.env "WEBHOOKIE_BRANDING_PATH=$branding_path"
  Add-Content -Path ./.env "WEBHOOKIE_TAG=$version"
  Add-Content -Path ./.env "KEYCLOAK_IMAGE=$keycloak_image"
  Add-Content -Path ./.env "AUTH_ENV=./data/$authProvider.env"

  if ($authProvider -eq 'keycloak') {
    $modules = $modules + "keycloak"
  }
  
  if ( $branding_color -ne '' ) {
    Add-Content -Path ./.env "WEBHOOKIE_BRANDING_COLOR='$branding_color'"
  } 
  else {
    Add-Content -Path ./.env "WEBHOOKIE_BRANDING_COLOR="
  }

  $compose=""
  Foreach ($module in $modules)
  {
    if ( "$module" -ne '' ) {
      $compose = "$compose -f docker-$module.yml"
    }
  }

  if ($dryRun -eq "true") {
    Write-Host "docker compose $compose $command"
  } else {
    Invoke-Expression "docker compose $compose $command"
  }
}

function show_help {
  printf "./run without any parameter brings all services with default values\n"
  printf "default values:\n"
  printf "\t size: medium; could be small, medium, large, x-large\n"
  printf "\t version: latest; could be beta, latest\n"
  printf "\t command: up; could be up, config, down\n"
  printf "\t auth_provider: keycloak\n"
  write-host "--beta: runs beta version of all webhookie-services"
  write-host "--help: shows this page"
  write-host "--size=[small/medium/large/x-large]: sets resource reservations and limits for the services"
  write-host "--dry-run: shows full compose file with the current values"
  write-host "--config: alias for --dry-run"
  write-host "--down: brings services down"
  write-host "--up: brings services up"
  write-host "--arm: uses arm keycloak image for M1 Macs"
  write-host "--auth0: removes keycloak from the stack and sets auth0 as auth provider; consider having auth0.env file in the same folder as keycloak.env"
  write-host "--no-logging: removes ELK containers from the deployment"
  write-host "--no-monitoring: removes Monitoring(Prometheus and Grafana) containers from the deployment"
  write-host "--no-sample: removes Sample subscription application container from the deployment"
  write-host "--no-mongo: removes MongoDB container from the deployment; consider updating env variables"
  write-host "--no-rabbit: removes RabbitMQ container from the deployment; consider updating env variables"
  write-host "--no-portal: removed webhookie-portal from the deployment"
  write-host "--no-registry: removed Eureka from the deployment"
  write-host "--branding: points to your own branding folder if you want to re-brand webhookie!"
  write-host "--branding-color: updates webhookie portal with the given color as the main color"
}

# init "$@"
run 

