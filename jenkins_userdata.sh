#!/bin/bash
# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file
# except in compliance with the License. A copy of the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under the License.
yum remove java-1.7.0-openjdk -y
yum install git java-1.8.0-openjdk -y
#sudo pip install --upgrade pip
sudo pip install ansible
#git clone https://github.com/ansible/ansible.git
#cd ansible
#git checkout -b stable-2.4 origin/stable-2.4
#git submodule update --init --recursive
#sudo make install
#pip install --upgrade pip
#pip install ansible
mkdir /opt/ansible_playbooks
cd /opt/ansible_playbooks
sudo git clone https://github.com/anecheporuk/ansible-role-jenkins.git
#git clone https://github.com/geerlingguy/ansible-role-jenkins.git
#ansible-playbook /var/ansible_playbooks/playbook.yml -K --extra-vars "jenkins_admin_username=admin jenkins_admin_password=admin123"
