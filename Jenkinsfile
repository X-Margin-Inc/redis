pipeline {
    agent any
    parameters {
        choice(
            name: 'ENVIRONMENT', 
            choices: ['stage', 'prod'], 
            description: 'Select environment')
        choice(
            name: 'TYPE', 
            choices: ['update'], 
            description: 'Select deployment type')        
    }

    options { 
        disableConcurrentBuilds() 
    }

    environment{
        GITHUB_TOKEN=credentials('github_token')
        CAUSE = "${currentBuild.getBuildCauses()[0].shortDescription}"
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    stages {
        stage('Validate Inputs') {
            steps {
                script {
                    if (env.ENVIRONMENT == null) {
                        error("Aborting the build because conditions are not met")
                    }
                } 
            }
        }
}
