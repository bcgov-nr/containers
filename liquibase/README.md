# Configuration to run LIQUIBASE migrations

Steps:

1. Create the image:
   
   `docker build . --tag bcgov:lb-deployer`

2. Run the container:

   `docker run -dit -v ~/.m2/repository:/apps_ux/repo --name lb-deployer bcgov:lb-deployer`

2. Enter the container:
   
   `docker exec -it lb-deployer /bin/bash`

3. Get the Ansible collection (within container):
   
   `./init_ansible.sh`

4. Check the settings in the run_playbook.sh (within container):
   
   `vi local_vars.yml`

5. Run the liquibase playbook (within container):
   
   `./run_playbook.sh`

## Troubleshooting

If the container has been stopped (after host rebooted or Docker stopped) it
can be restarted by running

 `# docker start lb-deployer`
