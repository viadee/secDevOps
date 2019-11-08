pipeline { 
    agent any
    parameters {
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'schritt-4', selectedValue: 'DEFAULT', name: 'BRANCH', type: 'PT_BRANCH'
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
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '', odcInstallation: 'OWASP Dependency Check'
            }
        }
        
        stage('OWASP ZAP') {
            steps {
                sh './gradlew docker'
                sh 'docker run --rm -itd --name vulnerapp -p 8280:8080 de.cqrity/vulnerapp'
                
                timeout(5) {
                    waitUntil {
                        script {
                            def r = sh script: 'wget -q http://localhost:8280 -O /dev/null', returnStatus: true
                            return (r == 0);
                        }
                    }
                }
                
                startZap(host: "127.0.0.1", port: 9095, timeout:500, zapHome: "/usr/share/owasp-zap", sessionPath:"${WORKSPACE}/zap/sessions/vulnerads.session", allowedHosts:['localhost','127.0.0.1'])
                runZapCrawler(host: "http://localhost:8280")
                runZapAttack(userId: 0, scanPolicyName: "")
                
                sh'docker stop $(docker ps -aqf "name=vulnerapp")'
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts '**/vulnerapp*.war, **/zapFalsePositives.json'
            }
        }
    }
    post { 
        always { 
            dependencyCheckPublisher failedTotalCritical: 5, failedTotalHigh: 20, failedTotalMedium: 50, pattern: '**/dependency-check-report.xml'
            recordIssues aggregatingResults: true, enabledForFailure: true, qualityGates: [[threshold: 10, type: 'TOTAL_ERROR', unstable: false], [threshold: 15, type: 'TOTAL_HIGH', unstable: false], [threshold: 30, type: 'TOTAL_NORMAL', unstable: false], [threshold: 50, type: 'TOTAL_LOW', unstable: false]], tools: [spotBugs(pattern: '**/spotbugs/main.xml')]
            archiveZap(failAllAlerts: 10, failHighAlerts: 0, failMediumAlerts: 0, failLowAlerts: 0, falsePositivesFilePath: "**/zapFalsePositives.json")
        }
    }
}
