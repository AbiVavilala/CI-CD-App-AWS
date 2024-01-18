# CI/CD of Flask Application using AWS CodeBuild, CodeDeploy and CodePipeline

In this Project, we will delve deep into CI/CD using AWS. Being the most commonly used cloud services, AWS has emerged as a frontrunner in providing scalable and trustworthy options for setting up CI/CD pipelines. From it’s Devops-focused tools we will use AWS CodeBuild, CodeDeploy and CodePipeline. Trio of these tools work flawlessly with each other in to offer an end-to-end solution. Throughout this series, CI/CD guide, I’ll walk you through each step — from setting up an EC2 instance to attaching the appropriate service roles for our pipeline. Stay tuned as we unpack each stage in this blog.

## Table of Contents

- [Pipeline flow](#Pipeline-flow)
- [Create Application](#Create-Application)
- [Create ECR Repository](#Create-ECR-Repository)
- [Create an EC2 instance](#Create-an-EC2-Instance)
- [Configure CodeBuild project](#Configure-Codebuild-Project)
- [Define build specification](#Define-Build-Specification)
- [Create IAM role for code deploy](#Create-IAM-Role-for-code-deploy)
- [Define deployment specification](#Define-deployment-specification)
- [Preparing EC2 instance for deployment](#Preparing-EC2-instance-for-deployment)
- [Configure CodeDeploy project](#Cofigure-CodeDeploy-project)
- [Prerequisites for Code Pipeline](#Prerequisites-for-code-pipeline)
- [Configure CodePipeline project](#Configure-Codepipeline-project)
- [Final Result](#Final-Result)
- [Erros and troubleshooting](#Erros-and-troubleshooting)


## Pipeline flow
First, we have to understand the workflow of this whole pipeline that we are about to set. Source of the Application will be Github(we can use AWS CodeCommit as well, it is same as Github just owned by AWS people) for this tutorial. Our target is to containerize the Flask Application(building Flask application docker image) and run/deploy this container on EC2 instance. Wait, let me elaborate this:

1. First, let us assume we already have our Flask application existing on some github repository with a proper Dockerfile in it.
2. Then we use AWS CodeBuild, to build the docker image of our Flask application and push the image to the ECR repository.
3. Next, AWS CodeDeploy will pull the respective Flask image from ECR on an EC2 instance and run the flask container, which will deploy the flask application.
4. At the end, we will use AWS CodePipeline to automate the build and deployment(in (2) and (3)) process, whenever any new changes is pushed on the githun repository


## Create Application
For this project I already created a Flask application and it's on GitHub. You can clone the repo using the url https://github.com/AbiVavilala/CI-CD-App-AWS.git. 

Application is a static page. and will be deployed on AWS and will build pipeline using Codebuild, Code Deploy and Code Pipeline.

![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/FlaskPic.JPG)

### Create a Docker file
In the repo you can see a docker file add following instructions to dockerfile

```
FROM public.ecr.aws/docker/library/python:3.10-slim

RUN pip install --upgrade pip

WORKDIR /app
COPY . /app

RUN pip install gunicorn
RUN python -m pip install -r requirements.txt

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

## Create ECR Reposiroty

Go to AWS console, and type ECR in the search bar. Click on the first search result.

![]https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/Create-Ecr-repository.JPG

A page will open up, where we have to select the required options to create an ECR repository. In General settingsI am keeping visbility as Private and choosing repo name as flask_image.

![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/Create-Ecr-repository1.JPG)

Leave the remaining settings as default
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/Create-Ecr-repository3.JPG)

## Create an EC2 Instance

Go to AWS console, and type ec2 in the search bar. Click on the first search result.

Now launch an EC2 instance with Ubuntu OS
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/launch-Ec2-instance.JPG)

EC2 instance is launched 
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/ec2instancelaunched.JPG)

### Create an IAM role for EC2 instance and attached to EC2 instance.

I already created IAM role with privelages. I will attach role created to EC2 instance. this way, my Ec2 instance can call other services and perform read and write access. to attach the role follow the steps below. Click on Actions then security
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/IAMroleforec2instance.JPG)

click on modify IAM role
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/IAMroleforec2instance1.JPG)

I have already created the role called EC2_code_deploy role. wth following policies.
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/IAMrole3.JPG)

## Configure Code Build Project

Go to AWS console, and type codebuild in the search bar. Click on the first search result. Click on Build Project 
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/Codebuild.JPG)

On scrolling down, in Source section we will select Github as our source provider since our source code exists there. Now we have to authorize AWS CodeBuild to access our Github account. For this click on Connect to GitHub.
![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/codebuild1.JPG)

 Sroll down further, in Environment section choose Managed image, in Operating system choose Ubuntu, Runtime(s) as Standard, Image as aws/codebuild/standard:7.0 and rest of the field’s option to be choosen as shown in the image below. One important point, we will tick Privileged option because we have to build a Docker image
 ![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/codebuild2.JPG)

 ## Define build specification

 We definitely need to provide some set of instructions for our build project to ensure we get the expected output. Hence the buildspec comes into the picture. Any CodeBuild project, requires a buildspec.yml file containing all the steps that it has to perform in the build stage. And this buildspec.yml file will be located in the root directory of our source code.

Let us head back to our Flask_app_CICD directory. Create a buildspec.yml file and edit this file to add all the required instruction as given below:

```
version: 0.1

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
      - echo Logged in to Amazon ECR successfully

  build:
    commands:
      - echo Building Docker Image for Flask Application
      - docker build -t flask_image .
      - echo Image built successfully

  post_build:
    commands:
      - echo Tagging Flask Docker image
      - docker tag flask_image:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/flask_image:latest
      - docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/flask_image:latest
      - echo Flask image pushed to ECR
```
Note: Replace 123456789.dkr.ecr.us-east-1.amazonaws.com with your own ECR repository URI

In buildspec.yml, we can see there are three phases.

pre_build: This phase will log in to the Amazon ECR repository.

build: This phase will build a docker image of our Flask Application by using the Dockerfile we have in the repository.

post_build: This phase will take the docker image from previous(build) phase, tag that image and push that tagged image to the ECR repository(flask_image).
Now, we will push this buildspec.yml file to our Source Code(GitHub Repository) using following command:

Start Build Process
Excited to see CodeBuild in action. Okay, Click the Start build button.

## Create IAM role for CodeDeploy
1. Navigate to IAM (Identity and Access Management) on AWS management console.
2. In the left navigation pane, click on Roles, then click Create role.

![](https://github.com/AbiVavilala/CI-CD-App-AWS/blob/main/CI/CDpics/1_E9lmbEVl8NuV68uiLV92Kw.png)

