$appspec = @"
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: arn:aws:ecs:ap-south-1:301782007642:task-definition/strapi-neeraj-task:1
        LoadBalancerInfo:
          ContainerName: strapi-app
          ContainerPort: 1337
"@

$revision = @{
    revisionType = "AppSpecContent"
    appSpecContent = @{
        content = $appspec
    }
} | ConvertTo-Json -Depth 3

$deploymentId = aws deploy create-deployment `
    --application-name strapi-neeraj-app `
    --deployment-group-name strapi-neeraj-deployment-group `
    --revision $revision `
    --region ap-south-1 `
    --profile neerajnakka.n@gmail.com `
    --query 'deploymentId' `
    --output text

Write-Host "Deployment ID: $deploymentId"

# Monitor deployment
do {
    Start-Sleep 10
    $status = aws deploy get-deployment --deployment-id $deploymentId --region ap-south-1 --profile neerajnakka.n@gmail.com --query 'deploymentInfo.status' --output text
    Write-Host "Deployment Status: $status"
} while ($status -eq "InProgress" -or $status -eq "Created" -or $status -eq "Queued")

Write-Host "Final Status: $status"