export JAVA_HOME="/usr/local/tomcat/jre"
export CATALINA_PID="/usr/local/tomcat/work/catalina.pid"

# The following are app specific, so should NOT be in the container image; they should be addressed via the infra-containers-config repo
# export CATALINA_OUT="/apps_ux/logs/DISPATCH/dispatch-api-war/catalina.out"
# export CATALINA_TMPDIR="/apps_data/DISPATCH/dispatch-api-war/tomcat/temp"
# export CATALINA_OPTS="-Dspring.profiles.active=uberwar_bc,uberwar_global,oauth,bc -Dcd_app_logs=/apps_ux/logs/DISPATCH/dispatch-api-war -Djava.awt.headless=true -Xmx2048m -Xms512m"