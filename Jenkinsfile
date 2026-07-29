pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('API tests') {
            steps {
                dir('api') {
                    sh '''
                        python3 -m venv .venv
                        . .venv/bin/activate
                        python -m pip install --disable-pip-version-check --requirement requirements-dev.txt
                        python -m compileall -q main.py test_main.py
                        pytest -q \
                          --junitxml=test-results.xml \
                          --cov=main \
                          --cov-report=term-missing \
                          --cov-report=xml:coverage.xml
                    '''
                }
            }
            post {
                always {
                    junit testResults: 'api/test-results.xml', allowEmptyResults: true
                    archiveArtifacts artifacts: 'api/coverage.xml', allowEmptyArchive: true
                }
            }
        }
    }
}
