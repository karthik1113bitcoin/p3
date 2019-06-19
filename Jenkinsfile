//def templatePath = 'https://raw.githubusercontent.com/karthik1113bitcoin/dbs_cust/master/dbs_template.json'
def templatePath = 'https://raw.githubusercontent.com/karthik1113bitcoin/p3/master/template.yaml'
def templateName = 'dbs-cust-template'
pipeline {
    environment {
        registryURL = 'https://10.73.122.51:4500'
        registry = "10.73.122.51:4500/karthikeyan_c01"
        registryCredential = 'docker_dtr'
        dockerReleaseFile = 'release_dockerfile'
        dockerSITFile = 'sit_dockerfile'
        release_image = 'cn_release'
        SIT_BASE_IMAGE = 'cn_fincore_cust_ucp'
        SIT_BASE_TAG = 'latest'
    }
    agent any
    stages {
        stage('Preprocessing Source conversion') {

            steps {
                sh 'echo preprocessing step...'
            }
        }
        stage('cleanup') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // delete everything with this template label
                            openshift.selector("all", [ template : templateName ]).delete()
                            // delete any secrets with this template label
                            if (openshift.selector("secrets", templateName).exists()) {
                                openshift.selector("secrets", templateName).delete()
                            }
                        }
                    }
                } // script
            } // steps
        } // stage
       stage('Build Source archive') {
            steps {
                sh 'rm -rf cust'
                /*sh 'rm -f cust.tgz'
                sh 'mkdir cust'
                sh 'mv COMMON_CNTRY DFBANK1 ./cust/'
                sh 'tar -cvf cust.tgz cust'
                sh 'ls -lrt'
                sh 'whoami'
                sh 'echo $JENKINS_USERNAME'
                sh 'pwd'
                sh 'oc whoami'*/
               // sh 'oc new-app https://raw.githubusercontent.com/karthik1113bitcoin/dbs_cust/master/dbs_template.json'
            }
       }
      /* stage('Test & Analysis') {
        parallel(
          Tests:{
            echo "Running Unit Tests"
          },
          Analysis:{
            echo "Running Code Analysis"
            //sh "${mvnCmd} sonar:sonar -Dsonar.host.url=http://sonarqube-gpte-hw-cicd.apps.na311.openshift.opentlc.com -Dsonar.projectName=${JOB_BASE_NAME}-${devTag}"
          }
        )
       }
       stage('Publish to Nexus') {
        echo "Publish to Nexus"
        sh "${mvnCmd} deploy -DskipTests=true -DaltDeploymentRepository=nexus::default::http://nexus3-gpte-hw-cicd.apps.na311.openshift.opentlc.com/repository/releases"
       }*/
       stage('create') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // create a new application from the templatePath
                            openshift.newApp(templatePath)
                        }
                    }
                } // script
            } // steps
        } // stage
       /* stage('Build-release') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // create a new application from the templatePath
                            //openshiftBuild(buildConfig: 'release-build', showBuildLogs: 'true')
                            openshift.selector("bc", "release-build").startBuild("--from-dir=/var/lib/jenkins/jobs/p2/jobs/p2-bc1-pipeline/workspace","--wait=true","--follow")
                        }
                    }
                } // script
            } // steps
        } // stage 
        stage('Build-cn') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // create a new application from the templatePath
                            //openshiftBuild(buildConfig: 'release-build', showBuildLogs: 'true')
                            openshift.selector("bc", "cn-build").startBuild("--wait=true","--follow")
                        }
                    }
                } // script
            } // steps
        } // stage */
        
        stage('Build-release') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            // create a new application from the templatePath
                            //openshiftBuild(buildConfig: 'release-build', showBuildLogs: 'true')
                            openshift.selector("bc", "1bc").startBuild("--wait=true","--follow")
                        }
                    }
                } // script
            } // steps
        } // stage 
    } //stages
}
