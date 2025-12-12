pipeline {
    agent { label "test" } // change to the label of your Linux node

    environment {
        AWS_REGION     = "ap-south-1"
        AWS_ACCOUNT_ID = "730335595521"
        ECR_REPO_NAME  = "devsecops-flask-app"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        APP_NAME       = "devsecops-flask-app"

        // SonarQube (optional)
        SONARQUBE_ENV  = "sonarqube-server"

        // Terraform directory
        TF_DIR         = "infra"
    }

    options {
        timestamps()
        // disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/akashshinde7219/devsecops-cicd-aws.git'
            }
        }

       // ===== Unit tests =====
        stage('Unit Tests') {
          steps {
            sh '''
            set -e
            python3 -m venv .venv
            . .venv/bin/activate
            pip install -r app/requirements.txt
        
            # make the 'app' directory importable as top-level 'app'
            PYTHONPATH=$PWD/app pytest -q
            '''
          }
        }


        // ===== Build Docker Image =====
        stage('Build Docker Image') {
            steps {
                sh '''
                set -e
                cd app
                docker build -t ${APP_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        // ===== Security Scan (Trivy) =====
        stage('Security Scan - Trivy') {
            steps {
                sh '''
                set -e
                trivy image --exit-code 1 --severity HIGH,CRITICAL ${APP_NAME}:${IMAGE_TAG} || \
                (echo "Trivy scan found HIGH/CRITICAL vulnerabilities" && exit 1)
                '''
            }
        }

        // ===== Push to Amazon ECR =====
        stage('Push to ECR') {
            steps {
                // bind AWS credentials stored in Jenkins credentials store
                // create a "username/password" credential with id 'aws-creds' where username=access_key and password=secret_key
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                    set -e
                    export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                    export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                    export AWS_DEFAULT_REGION=${AWS_REGION}

                    aws ecr describe-repositories --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION} || \
                      aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION}

                    aws ecr get-login-password --region ${AWS_REGION} | \
                      docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    docker tag ${APP_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        // ===== Terraform Init & Plan =====
        stage('Terraform Init & Plan') {
            steps {
                // ensure Terraform has AWS creds for plan if provider needs them
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir(env.TF_DIR) {
                        sh '''
                        set -e
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=${AWS_REGION}

                        terraform init -input=false
                        terraform plan -var="app_image=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}" -out=tfplan
                        '''
                    }
                }
            }
        }

        // ===== Terraform Apply (manual approval on main) =====
        stage('Terraform Apply') {
            // when {
            //     branch "main"
            // }
            steps {
                input message: "Apply Terraform changes to AWS (Prod)?", ok: "Apply"
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir(env.TF_DIR) {
                        sh '''
                        set -e
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=${AWS_REGION}
                        
                   
                        # apply using plan file if you want (uncomment below) or run apply directly
                         terraform apply -auto-approve tfplan

                        terraform apply -auto-approve -var="app_image=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                        '''
                    }
                }
            }
        }

        // ===== Blue-Green Switch & Smoke Test (placeholder) =====
        stage('Blue-Green Switch & Smoke Test') {
            steps {
                script {
                    echo "Blue-Green switch handled by Terraform + ALB target groups. Add smoke tests (e.g. curl /health) here."
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished: ${currentBuild.currentResult}"
        }
        success {
            echo "Build ${env.BUILD_NUMBER} succeeded."
        }
        failure {
            echo "Build ${env.BUILD_NUMBER} failed."
        }
    }
}
