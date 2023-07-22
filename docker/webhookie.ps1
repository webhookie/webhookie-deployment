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
  printf "./webhookie.sh without any parameter brings all services with default values\n"
  printf "\t auth_provider: keycloak\n"
  echo "--command: [up/down] - default: up"
  echo "--beta: runs beta version of all webhookie-services"
  echo "--help: shows this page"
  echo "--size=[small/medium/large/x-large] - default: medium: sets resource reservations and limits for the services"
  echo "--dry-run: shows full compose file with the current values"
  echo "--config: alias for --dry-run"
  echo "--down: brings services down"
  echo "--up: brings services up"
  echo "--arm: uses arm keycloak image for M1 Macs"
  echo "--auth: [OPTIONAL] path to the auth.env file similar to keycloak.env; overrides auth provider - default: keycloak "
  echo "--with-logging: adds ELK containers from the deployment"
  echo "--with-monitoring: adds Monitoring(Prometheus and Grafana) containers from the deployment"
  echo "--with-demo: adds Sample subscription application container from the deployment"
  echo "--no-mongo: removes MongoDB container from the deployment; consider updating env variables"
  echo "--no-rabbit: removes RabbitMQ container from the deployment; consider updating env variables"
  echo "--no-portal: removed webhookie-portal from the deployment"
  echo "--no-registry: removed Eureka from the deployment"
  echo "--branding: points to your own branding folder if you want to re-brand webhookie!"
  echo "--branding-color: updates webhookie portal with the given color as the main color"
}

# init "$@"
run 

