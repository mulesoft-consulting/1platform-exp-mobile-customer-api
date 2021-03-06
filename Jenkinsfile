pipeline {
  agent {
    label 'mule-builder'
  }
  environment {
    DEPLOY_CREDS = credentials('deploy-anypoint-user')
    MULE_VERSION = '4.1.4'
    BG = "1Platform\\Retail\\Sales"
    APP_CLIENT_CREDS = credentials("$BRANCH_NAME-api-mgr-exp-mobile-customer-api")
  }
  stages {
    stage('Prepare') {
      steps {
        configFileProvider([configFile(fileId: "${BRANCH_NAME}-exp-mobile-customer-api.yaml", replaceTokens: true, targetLocation: './src/main/resources/config/configuration.yaml')]) {
          withCredentials([file(credentialsId: 'self-signed-keystore.jks', variable: 'KEYSTORE_FILE')]){
            sh 'echo "Branch NAME: $BRANCH_NAME"'
            sh 'cp $KEYSTORE_FILE ./src/main/resources/keystore.jks'
          }
        }

      }
    }
    stage('Build') {
      environment {
        PROFILE = 'Cloudhub'
      }
      steps {
        withMaven(
          mavenSettingsConfig: 'f007350a-b1d5-44a8-9757-07c22cd2a360'){
            sh 'mvn clean -DskipTests package'
          }
      }
    }

    stage('Test') {
      steps {
        withMaven(
          mavenSettingsConfig: 'f007350a-b1d5-44a8-9757-07c22cd2a360'){
            sh "mvn -B test"
        }
      }
    }

    stage('Deploy Development') {
      when {
        branch 'develop'
      }
      environment {
        ENVIRONMENT = 'Development'
        ANYPOINT_ENV = credentials('DEV_ANYPOINT_SALES')
        APP_NAME = 'dev-nto-mobile-customer-api-v1'
        PROFILE = 'Cloudhub'
        WORKER_SIZE = 'Small'
      }
      steps {
        withMaven(
          mavenSettingsConfig: 'f007350a-b1d5-44a8-9757-07c22cd2a360'){
            sh 'mvn -V -B -P $PROFILE -DskipTests deploy -DmuleDeploy -Dmule.version=$MULE_VERSION -Danypoint.username=$DEPLOY_CREDS_USR -Danypoint.password=$DEPLOY_CREDS_PSW -Dcloudhub.app=$APP_NAME -Dcloudhub.environment=$ENVIRONMENT -Denv.ANYPOINT_CLIENT_ID=$ANYPOINT_ENV_USR -Denv.ANYPOINT_CLIENT_SECRET=$ANYPOINT_ENV_PSW -Dcloudhub.bg=$BG -Dcloudhub.worker=$WORKER_SIZE -Dapp.client_id=$APP_CLIENT_CREDS_USR -Dapp.client_secret=$APP_CLIENT_CREDS_PSW'
          }
      }
    }
    stage('Upload to Exchange') {
      when {
        branch 'master'
      }
      steps {
        withMaven(
            mavenSettingsConfig: 'f007350a-b1d5-44a8-9757-07c22cd2a360'){
              script {
                try {
                  sh 'mvn -V deploy'
                  echo 'App upload to Exchange!'
                } catch (err) {
                  echo 'Error uploading app to Exchange!'
                  echo "${err}"
                }
              }
            }
      }
    }

    stage('Deploy Production') {
        when {
          branch 'master'
        }
        environment {
          ENVIRONMENT = 'Production'
          ANYPOINT_ENV = credentials('PRD_ANYPOINT_SALES')
          APP_NAME = 'nto-mobile-customer-api'
          CPU = "500m"
          MEM = "1000Mi"
          PROFILE="RTF"
          TARGET="1platform-demos-rtf"
          PUBLIC_URL = "https://nto-mobile-customer-api.rtf.demos.mulesoft.com"
        }
        steps {
	        withMaven(
            mavenSettingsConfig: 'f007350a-b1d5-44a8-9757-07c22cd2a360'){
              sh 'mvn -V -B -P $PROFILE -DskipTests deploy -DmuleDeploy -Dmule.version=$MULE_VERSION -Danypoint.username=$DEPLOY_CREDS_USR -Danypoint.password=$DEPLOY_CREDS_PSW -Dcloudhub.app=$APP_NAME -Dcloudhub.environment=$ENVIRONMENT -Denv.ANYPOINT_CLIENT_ID=$ANYPOINT_ENV_USR -Denv.ANYPOINT_CLIENT_SECRET=$ANYPOINT_ENV_PSW -Dcloudhub.bg=$BG -Dcloudhub.cpu=$CPU -Dcloudhub.memory=$MEM -Dapp.client_id=$APP_CLIENT_CREDS_USR -Dapp.client_secret=$APP_CLIENT_CREDS_PSW -Dcloudhub.target=$TARGET -Dcloudhub.publicUrl=$PUBLIC_URL'
            }
        }
      }
  }

  post {
    always {
      step([$class: 'hudson.plugins.chucknorris.CordellWalkerRecorder'])
    }
  }

  tools {
    maven 'M3'
  }
}
