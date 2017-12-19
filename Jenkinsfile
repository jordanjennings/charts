// Find any changed charts
//
node {
    properties[(disableConcurrentBuilds)]
    def changedFolders = []
    def chartFile = 'Chart.yml'
    def indexYaml = "index.yaml"
    def indexYamlBackup = "${indexYaml}.bak"
    def artifactoryServer = Artifactory.server 'bossanova-artifactory'     
    def helmChartsRepo = 'helm-charts'
    def artifactoryDownloadedIndexYaml = "artifactory-index.yaml"
    def artifactoryBaseUrl = "https://bossanova.jfrog.io/bossanova"
    def artifactoryChartsUrl = "${artifactoryBaseUrl}/${helmChartsRepo}"
    def artifactoryIndexYamlLocation = "${helmChartsRepo}/${indexYaml}"
    def packagePath = ''
    def packageName = ''

    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'jenkins_build_jumpcloud',
    usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
        stage('Check out Charts Repository') {
            sshagent(['jenkins_github']){
                checkout scm
            }
        }

        stage('Gather changed Charts') {
            changedFolders = sh(
                returnStdout: true,
                script: "git show --name-only stable/ | grep $chartFile | awk -F/ '{print $1\"/\"$2}' | uniq"
            )
        }

        stage('Set Helm home directory to the current workspace') {
            // https://docs.helm.sh/glossary/#helm-home-helm-home
            env.HELM_HOME = "${env.WORKSPACE}/.helm}"
        }

        docker.image('lachlanevenson/k8s-helm:v2.7.2').inside() {
            stage("Initialize Helm client") {
                sh(
                    returnStdout: false,
                    script: 'helm init --client-only'
                  )
            }

            for (int i = 0; i < changedFolders.length; i++) {
                def chartName = changedFolders[i].split('/')[1]
                def chartPath = changedFolders[i]

                stage("Lint the Chart: $chartName") {
                    sh(
                        returnStdout: false,
                        script: "helm lint $chartPath"
                    )
                }

                stage("Package the Chart: $chartName") {
                    packagePath = sh(
                        returnStdout: true,
                        script: "helm package $chartPath"
                    ).trim().split(':')[1]

                    packageName = packagePath.split('/').last()
                }

            }
        }

        

        if (env.BRANCH_NAME == 'master') {
            stage("Download the current ${indexYaml}") {
                def indexYamlDownloadSpec = """{
                  "files": [
                    {
                      "pattern": "${artifactoryIndexYamlLocation}",
                      "target": "${artifactoryDownloadedIndexYaml}"
                    }
                  ]
                }"""
                def indexYamlFile = artifactoryServer.download(indexYamlDownloadSpec)
            }

            stage("Create backup of the current ${indexYaml}") {
                def indexYamlBackupUploadSpec = """{
                  "files": [
                    {
                      "pattern": "${artifactoryDownloadedIndexYaml}",
                      "target": "${helmChartsRepo}/${indexYamlBackup}",
                      "flat": true
                    }
                  ]
                }"""

                artifactoryServer.upload(indexYamlBackupUploadSpec)        
            }

            stage("Merge ${indexYaml}") {
                sh(
                    returnStdout: false,
                    script: "helm repo index --merge ${artifactoryDownloadedIndexYaml} ."
                )
            }

            stage('Publish the Helm Charts') {
                def helmChartUploadSpec = """{
                  "files": [
                    {
                      "pattern": "*.tgz",
                      "target": "${helmChartsRepo}/",
                      "flat": true
                    }
                  ]
                }"""

                artifactoryServer.upload(helmChartUploadSpec)
              }

              stage("Publish the updated ${indexYaml}") {
                def indexYamlUploadSpec = """{
                  "files": [
                    {
                      "pattern": "${indexYaml}",
                      "target": "${helmChartsRepo}/${indexYaml}",
                      "flat": true
                    }
                  ]
                }"""

                artifactoryServer.upload(indexYamlUploadSpec)
            }
        }
    }
}
