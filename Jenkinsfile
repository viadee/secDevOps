pipeline { 
    agent any
    parameters {
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'schritt-2', selectedValue: 'DEFAULT', name: 'BRANCH', type: 'PT_BRANCH'
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
    post { 
        always { 
            recordIssues aggregatingResults: true, enabledForFailure: true, qualityGates: [[threshold: 10, type: 'TOTAL_ERROR', unstable: false], [threshold: 15, type: 'TOTAL_HIGH', unstable: false], [threshold: 30, type: 'TOTAL_NORMAL', unstable: false], [threshold: 50, type: 'TOTAL_LOW', unstable: false]], tools: [spotBugs(pattern: '**/spotbugs/main.xml')]
        }
    }
}
