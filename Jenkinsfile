// Find any changed charts
//
caughtError = 0
try {
    node {
        def changedFolders = []
        def chartFile = 'Chart.yaml'
        def artifactoryServer = Artifactory.server 'bossanova-artifactory'     
        def helmChartsRepo = 'bossanova-helm-charts'
        def packagePath = ''
        def packageName = ''
        def mergeBaseBranch = 'devel'
        def mergeBaseCommit = 'HEAD'
        def helmDockerImage = 'marcsensenich/k8s-helm:artifactory'
        def helmChartsUrl = 'https://bossanova.jfrog.io/bossanova/charts'
        def packagedChartsDestination = 'packaged_charts'

        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'jenkins_build_jumpcloud',
        usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
            stage('Check out Charts Repository') {
                sshagent(['jenkins_github']){
                    checkout scm
                }
            }

            if (env.BRANCH_NAME == 'master') {
                mergeBaseBranch = 'master'
                mergeBaseCommit = 'HEAD~1'
            }

            if (env.BRANCH_NAME == 'devel') {
                mergeBaseCommit = 'HEAD~1'
            }

            stage('Gather changed Charts') {
                // mimicking https://github.com/kubernetes/charts/blob/master/test/changed.sh to some degree
                changedFolders = sh returnStdout: true, script: "git diff --find-renames --name-only \$(git merge-base origin/$mergeBaseBranch $mergeBaseCommit) stable/ | grep $chartFile | awk -F/ '{print \$1\"/\"\$2}' | uniq"
            }

            stage('Set Helm home directory to the current workspace') {
                // https://docs.helm.sh/glossary/#helm-home-helm-home
                env.HELM_HOME = "${env.WORKSPACE}/.helm}"
            }

            docker.image("$helmDockerImage").inside() {
                stage("Initialize Helm client") {
                    sh(
                        returnStdout: false,
                        script: 'helm init --client-only'
                      )
                }

                stage("Add the Artifactory Helm Repository") {
                    sh(
                        returnStdout: false,
                        script: "helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/"
                    )
                }

                stage("Add the Artifactory Helm Repository") {
                    sh(
                        returnStdout: false,
                        script: "helm repo add artifactory $helmChartsUrl $ARTIFACTORY_USER $ARTIFACTORY_PASSWORD"
                    )
                }

                stage("Update the Helm Repositories") {
                    sh(
                        returnStdout: false,
                        script: "helm repo update"
                    )
                }

                if (!changedFolders.empty){
                    changedFolders = changedFolders.split("\\r?\\n")

                    stage("Make the Chart destination directory") {
                        sh "mkdir -p $packagedChartsDestination"
                    }

                    for (int i = 0; i < changedFolders.length; i++) {
                        def chartName = changedFolders[i].split('/')[1]
                        def chartPath = changedFolders[i]

                        stage("Install Chart Depenedencies: $chartName") {
                            sh(
                                returnStdout: false,
                                script: "helm dependency build $chartPath"
                            )
                        }

                        stage("Lint the Chart: $chartName") {
                            sh(
                                returnStdout: false,
                                script: "helm lint $chartPath"
                            )
                        }

                        stage("Package the Chart: $chartName") {
                            packagePath = sh(
                                returnStdout: true,
                                script: "helm package --destination $packagedChartsDestination $chartPath"
                            ).trim().split(':')[1]

                            packageName = packagePath.split('/').last()
                        }

                    }
                }
            }



            if (env.BRANCH_NAME == 'master') {
                stage('Publish the Helm Charts') {
                    def helmChartUploadSpec = """{
                      "files": [
                        {
                          "pattern": "$packagedChartsDestination/*.tgz",
                          "target": "${helmChartsRepo}/",
                          "flat": true
                        }
                      ]
                    }"""

                    artifactoryServer.upload(helmChartUploadSpec)
                }
            }
        }
    }

    currentBuild.result = "SUCCESS"
}
catch (caughtError) {
  currentBuild.result = "FAILURE"
  print "Problems with the build..."
  print caughtError
}
finally {
  node {
    stage("Cleanup Workspace") {
      print "Cleaning up the workspace..."
      step([$class: 'WsCleanup'])
    }

    sendBuildResultStatus(currentBuild.result, '#k8s')

    if (caughtError != 0) {
      throw caughtError
    }
  }
}

