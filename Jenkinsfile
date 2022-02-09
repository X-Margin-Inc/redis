// Using git without checkout
pipeline {
  agent any
  parameters {
    gitParameter branchFilter: 'origin/(.*)', defaultValue: 'master', name: 'BRANCH_SELECT', type: 'BRANCH'
  }
  stages {
    stage('Example') {
      steps {
       sh 'echo ${BRANCH_SELECT}'
      }
    }
  }
}
