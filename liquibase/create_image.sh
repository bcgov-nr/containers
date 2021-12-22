docker build . --tag bcgov:lb-deployer
docker run -dit -v ~/.m2/repository:/apps_ux/repo --name lb-deployer bcgov:lb-deployer