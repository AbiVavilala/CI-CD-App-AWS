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



