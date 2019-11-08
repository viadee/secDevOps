pipeline { 
    agent any
    parameters {
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'schritt-0', selectedValue: 'DEFAULT', name: 'BRANCH', type: 'PT_BRANCH'
    }
    options {
        skipStagesAfterUnstable()
        timestamps()
    }
    tools {
        gradle 'Gradle 5.6.2'
    }
    stages {
        stage('Checkout') { 
            steps { 
                cleanWs()
                git branch: "${params.BRANCH}", credentialsId: 'gitlab-viadee', url: 'http://localhost/Viadee/vulnerads.git' 
            }
        }
        
        stage('Build'){
            steps {
                sh './gradlew clean check assemble'
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts '**/vulnerapp*.war'
            }
        }
    }
}
