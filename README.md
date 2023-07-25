***Buiding Artifact using Maven and Gradle***
                   AND
    **running a Python flask app Ec2**                  
** Using Jenkins pipeline and usage of slave and deployment instance**
---------------------------------------------------------------------
**1) Building Artifact and using Maven through Jenkins pipeline script**

--->  Setup Required 3 Ec2 <---
one Ec2 act as master  : where in master only jenkins is installed 
another one is slave   : where we will run our pipeline and 
another  Ec2 is deploy : where we will push the artifact which is generated in salve to dev instance 

***Same setup for Maven and Gradle***
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/06c37038-9930-468f-8dc2-ece8f5cd1c42)

--- We will push the code to source code managemrnt ( **Github** ) the file that is required to build Maven if POM.Xml and if out artifact is .war the an index.jsp where our web page code is viewd ---

after setting up the source code 

##Open Jenkins Ec2 and connect using Cli## 
***CMD run in master ec2:***
ubuntu@ip-10-0-29-80:~$ = on mvn master
1)vi jenkins.sh
2)sh jenkins.sh
3)jenkins --version 
4)ssh-keygen
5)ssh-copy-id ubuntu@10.0.22.79
6)ssh ubuntu@10.0.22.79
7)cat /home/ubuntu/.ssh/id_rsa

in this steps :
    1) we have installed jenkins 
    2) we have generated SSH Keygen, where we will get public and prvt key , so now we will copy the public key with slave Ec2 to connect with password less connection 
    3) so before performing the 5th step , open slave machine and give a password to user :   cmd =  **sudo passwd ubuntu**  , and after that go to cmd : **sudo vi /etc/ssh/sshd_config**  enter and give ***yes*** in password auth and restart with cmd **sudo service ssh restart**
    4) now give the 5th step : i.e **ssh-copy-id ubuntu@pvrt ip of slave**


***CMD run in slave ec2:***

![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/4040b469-960a-4320-b4c4-a0d084f1f0c4)

dont be confused with the extra cmd  in the above image will get back to it later stage 


***CMD run in Deploy ec2:***
 we will be only install  the tomcat9 and restart , if needed change the port number in server.xml  igonore some cmd which i was testing and but in the below cmd in line number 39 and 40 we will change the  permission of tomcat9/webapp so that we can edit content 
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/d2476783-0612-41e1-afd9-a55dd432a896)


**Now Open the jenkins by coping the public ip of master ec2 and with port :8080

1) set up and jenkins
2) setup the configuration in jenkins
3) setup the node where slave ec2 will be act as node (or) agent
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/6b6ae07b-1a38-49da-80a5-e63b0a938c63)

4) now build a pipeline :
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/ad44691c-f3cb-4600-af03-4bc34d7242ed)

script :
      pipeline {
    agent {
        label 'maven-1'
    }
    tools {
        maven 'maven'
    } 
    
    stages {
        stage('Continuous Download') {
            steps {
                git branch: 'master', url: 'https://github.com/Gnaneswartripura/maven.git'
            }
        }
        
        stage('Continuous Build') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Deployment') {
            steps {
                sh 'scp /home/ubuntu/workspace/maven/webapp/target/webapp.war ubuntu@10.0.18.135:/var/lib/tomcat9/webapps/webapp.war'
                
                sh 'ssh ubuntu@10.0.18.135 "sudo systemctl restart tomcat9"'
            }
        }
    }
}

**RUN**
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/58424dd1-d65e-4a92-a9d7-f43f938baa51)

after the build stage is success :
check where the build is done in consloe output in slave ec2 , so as i said the cmd in slave ec2 in above is this 
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/16b6db72-2b07-42ee-8e32-873846ae8cfb)
**checking in ec2**
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/be4c8ab3-a2ca-4791-92dd-53dccd44150f)

**in the pipeline there is step for deployment of artifact from slave to dev , so before running this pipeline , u need to connect the slave and deploy with ssh with auto connect**

so after this in the deploy stage the artifact (**.war**) which is in slave copied to deploy ec2 in tomcat9/webapp folder :


**Now take the public ip of Ec2 of deploy and paste in browser and give **:tomcatport** with **/artifact-name**
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/8c2a2a7d-bcd5-4d35-a65f-7bfdda6f3aed)
my artifact name was webapp 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

***setup of gradle (same setup as Maven)**

in source code we need to have a build.gradle file 
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/21906b5a-525a-4d29-b017-ff7e12d13dbb)

same cmd run in maven ec2 should be run in gradle 

***CMD run in slave ec2:***
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/4cf87998-b2a3-437d-8695-7a0b941223b6)
in this we have done ssh connection between slave and deplyment , igonre 47 and 48 cmd 
**Cmd in deploy ec2**
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/61fe8ad5-9f85-41d6-974e-aa9c76f150c5)

install tomcat9 and change the permission 

**open jenkins**
1) setup jenkins
2) build pipeline:
     pipeline {
    agent {
        label 'gradle-1'
    }
    tools {
        gradle "gradle"
    }
    stages {
        stage('Checkout from SCM') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], userRemoteConfigs: [[url: 'https://github.com/Taissery-Suhaib/gardleeee.git']]])
            }
        }
        stage('Build Gradle App') {
            steps {
                sh 'gradle clean war'
            }
        }
        stage('Test Gradle App') {
            steps {
                sh 'gradle test'
            }
        }
        stage('Deployment') {
            steps {
                sh 'gradle clean war'
                sh 'mv build/libs/your-app-name.war build/libs/random-name.war'
                sh 'scp build/libs/random-name.war ubuntu@10.0.30.218:/var/lib/tomcat9/webapps/random-name.war'
                
                
                sh 'ssh ubuntu@10.0.30.218 "sudo systemctl restart tomcat9"'
            }
        }
    }
}

**run**

![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/a9b1b28c-8d25-4d40-ad64-5cffce920165)

in this it is deploying in gradle ec2 in /tomcat9/webapp
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/d74bb224-224d-4fca-a488-eac1c6e3d4f5)

---------------------------------------------------------------------------------------------------------------------------------

**Running a Python flask app in ec2**
in source code we need to have app.py file 
setup required :
2 ec2 ,  one as master , one is were file is clone and install the dependencies to run the app file like python3 , pip3 , flask 
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/d814b869-d5cc-442f-8fab-8e4afba9ddad)


**CMD Run on jenkins master Ec2**
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/8cd08314-239e-4925-8a5a-4f65f7cca41f)
ssh between slave and master and installed jenkins 
                                  **CMD in slave**
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/165a3bbc-b1ea-4b3f-8d39-1fa5b9582205)

![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/29d2d507-41f4-42f2-90c1-d335a558480b)
                                 **Setup a jenkins**
1) configure jenkins
2) build a pipeline 
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/4c48489d-87f9-41ef-a018-0f2e9dc66f3d)
after the build :
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/4364c3e9-bdc2-4997-bc8a-4d277f9bfcad)
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/9a0304c0-509c-4033-a69b-249993dd4a32)
                            **the log or console output**
![image](https://github.com/dev-ops-aws/sonix-batch2/assets/134582331/70c7a1be-4301-42b8-bf7e-bf384d97a78e)





 
 






