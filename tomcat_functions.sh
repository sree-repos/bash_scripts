#!/bin/bash

#
# Functions
#
function usage {
  echo "USAGE:
$0 start|stop|restart <DOMAIN> <INSTANCE>"
  exit 1
}

function start {
  echo "Starting Tomcat instance ${DOMAIN}_${INSTANCE}"
  export CFUNC='start'

  if [ "${TCUSER}" == "${CURUSER}" ]; then
    /app/bin/start_tomcat_instance.sh ${DOMAIN} ${INSTANCE}
  else
    sudo -u ${TCUSER} -i /app/bin/start_tomcat_instance.sh ${DOMAIN} ${INSTANCE}
  fi
}

function stop {
  echo "Stopping Tomcat instance ${DOMAIN}_${INSTANCE}"

  #CATALINA_HOME=`grep apache-tomcat /app/domains/${DOMAIN}/${INSTANCE}/bin/setenv.sh |grep LD_LIBRARY|sed -e 's/.*://' -e 's/\/apr.*//'`
  CATALINA_HOME="/opt/tomcat/$(egrep -rio 'apache-tomcat-[^\/"]*' /app/domains/${DOMAIN}/${INSTANCE}/bin/setenv.sh |head -1)"
  CATALINA_OUT="/app/logs/${DOMAIN}_${INSTANCE}.log"
  #CATALINA_PID="${CATALINA_BASE}/var/run/catalina.pid"

  CFUNC='stop'
  export CATALINA_BASE CATALINA_OUT CATALINA_HOME CFUNC

  if [ ! -d ${CATALINA_BASE} ]; then
    echo "Directory ${CATALINA_BASE} doesn't exist"
    exit 1
  fi

  ${CATALINA_HOME}/bin/catalina.sh stop

  # Time to wait before sending TERM signal
  TERM_WAIT=30

  # Time to wait after TERM before sending KILL signal
  KILL_WAIT=10

  sleep 1

  if [[ $? -eq 0 ]]; then
    echo -n "Waiting for instance ${DOMAIN}_${INSTANCE} to exit..."
    sleep 1
    EXIT=0

    for i in `seq 1 $TERM_WAIT`; do
      pgrep -u $TCUSER -f "${DOMAIN}/${INSTANCE} " > /dev/null 2>&1
      if [[ $? -ne 0 ]]; then
        EXIT=1
        break
      fi
      echo -n "."
      sleep 1
    done

    if [[ $EXIT -eq 0 ]]; then
      echo "sending TERM signal to Tomcat"
      pkill -TERM -u $TCUSER -f "${DOMAIN}/${INSTANCE}"
      sleep 1

      pgrep -u $TCUSER -f "${DOMAIN}/${INSTANCE} " > /dev/null 2>&1

      if [[ $? -eq 0 ]]; then
        echo -n "Waiting for Tomcat to exit..."
        sleep 1
        EXIT=0

        for i in `seq 1 $KILL_WAIT`; do
          pgrep -u $TCUSER -f "${DOMAIN}/${INSTANCE} " > /dev/null 2>&1
          if [[ $? -ne 0 ]]; then
            EXIT=1
            break
          fi
          echo -n "."
          sleep 1
        done

        # line feed
        echo ""

        if [[ $EXIT -eq 0 ]]; then
          echo -n "Sending KILL signal to Tomcat"
          pkill -KILL -u $TCUSER -f "${DOMAIN}/${INSTANCE} "
        fi
      fi
    fi
  fi

  rm -f ${CATALINA_PID}
  echo -e "\nInstance ${DOMAIN}_${INSTANCE} shutdown"
}

#
# Main
#
FUNC=$1

case $FUNC in
  start)
    FUNC=start
    ;;
  stop)
    FUNC=stop
    ;;
  restart)
    FUNC=restart
    ;;
  *)
    usage
    ;;
esac

shift

DOMAIN=$1
INSTANCE=$2

export DOMAIN INSTANCE FUNC

if [ -z "${DOMAIN}" ] || [ -z "$INSTANCE" ]; then
  usage
fi

TCUSER=`/opt/puppetlabs/bin/facter --external-dir /etc/facter/facts.d l_tomcat_user`
TCGROUP=$TCUSER

if [ "$TCUSER" == "" ]; then
  echo "Could not determine l_tomcat_user from facter"
  exit 1
fi

CURUSER=`whoami`

CATALINA_BASE="/app/domains/${DOMAIN}/${INSTANCE}"

if [ "${FUNC}" == "start" ]; then
  start
elif [ "${FUNC}" == "restart" ]; then
  stop
  sleep 2
  start
elif [ "${FUNC}" == "stop" ]; then
  stop
fi
