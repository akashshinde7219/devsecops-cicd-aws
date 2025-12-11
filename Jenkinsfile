pipeline {
    agent any

    environment {
        AWS_REGION        = "ap-south-1"          // change if needed
        AWS_ACCOUNT_ID    = "730335595521"        // your AWS account
        ECR_REPO_NAME     = "devsecops-flask-app"
        IMAGE_TAG         = "${env.BUILD_NUMBER}"
        APP_NAME          = "devsecops-flask-app"

        // SonarQube
        SONARQUBE_ENV     = "sonarqube-server"    // Jenkins SonarQube server name

        // Terraform
        TF_DIR            = "infra"
    }

    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-user/devsecops-cicd-aws.git'
            }
        }

        // stage('Code Quality - SonarQube') {
        //     steps {
        //         script {
        //             withSonarQubeEnv(env.SONARQUBE_ENV) {
        //                 sh """
        //                 cd app
        //                 sonar-scanner \
        //                   -Dsonar.projectKey=${APP_NAME} \
        //                   -Dsonar.sources=. \
        //                   -Dsonar.host.url=\$SONAR_HOST_URL \
        //                   -Dsonar.login=\$SONAR_AUTH_TOKEN
        //                 """
        //             }
        //         }
        //     }
        // }

        stage('Unit Tests') {
            steps {
                sh """
                cd app
                pip install -r requirements.txt
                pytest -q
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                cd app
                docker build -t ${APP_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Security Scan - Trivy') {
            steps {
                sh """
                trivy image --exit-code 1 --severity HIGH,CRITICAL ${APP_NAME}:${IMAGE_TAG} || \
                (echo "Trivy scan failed for high/critical vulnerabilities" && exit 1)
                """
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh """
                    aws ecr describe-repositories --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION} || \
                    aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION}

                    aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    docker tag ${APP_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                dir(env.TF_DIR) {
                    sh """
                    terraform init
                    terraform plan -var="app_image=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    """
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return env.BRANCH_NAME == 'main' || env.GIT_BRANCH == 'origin/main' }
            }
            steps {
                input message: "Apply Terraform changes to AWS (Prod)?", ok: "Apply"
                dir(env.TF_DIR) {
                    sh """
                    terraform apply -auto-approve \
                        -var="app_image=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    """
                }
            }
        }

        stage('Blue-Green Switch & Smoke Test') {
            steps {
                script {
                    // simple placeholder – real logic could hit /health on Green target group
                    echo "Blue-Green switch handled by Terraform + ALB target groups. Add smoke tests here."
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished: ${currentBuild.currentResult}"
        }
    }
}
