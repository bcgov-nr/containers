# Configuration to run LIQUIBASE migrations

Steps:
1. Create the docker image & container
<<<<<<< HEAD
   1. \# ./create_image.sh
2. Login to the container:
   1. \# ./start_session.sh
3. Get the Ansible collection
   1. (docker)# ./init_ansible.sh
4. Check the settings in the run_playbook.sh
   1. (docker)# vi run_playbook.sh
5. Run the liquibase playbook:
   1. (docker)# ./run_playbook.sh
=======
   1. `# ./create_image.sh`
2. Login to the container:
   1. `# ./start_session.sh `
3. Get the Ansible collection
   1. `(docker)# ./init_ansible.sh`
4. Check the settings in the local_vars.yml
   1. `(docker)# vi local_vars.yml`
5. Run the liquibase playbook:
   1. `(docker)# ./run_playbook.sh`

If the container has been stopped (after host rebooted or Docker stopped) it
can be restarted by running

 `# docker start lb-deployer`
>>>>>>> feature/liquibase
