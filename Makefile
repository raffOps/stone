terraform:
	cd /tmp
	wget https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_linux_amd64.zip
	unzip terraform_0.14.9_linux_amd64.zip
	sudo mv terraform /usr/local/bin/

docker:
	sudo apt-get update
	sudo apt-get install \
				apt-transport-https \
				ca-certificates \
				curl \
				gnupg \
				lsb-release
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io
	sudo docker run hello-world

aws:
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install

